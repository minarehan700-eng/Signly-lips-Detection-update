package com.example.mobile_offline

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult
import java.io.ByteArrayInputStream

class HandLandmarkerBridge(private val context: Context) {
    private var handLandmarker: HandLandmarker? = null
    private val processLock = Any()

    fun isInitialized(): Boolean = synchronized(processLock) { handLandmarker != null }

    fun initialize(modelAssetPath: String = "hand_landmarker.task") {
        synchronized(processLock) {
            if (handLandmarker != null) return

            // Load MediaPipe vision task classes on this thread before any background work.
            // BaseVisionTaskApi.<clinit> SIGSEGVs on Android 16 if first touched off-main.
            Class.forName("com.google.mediapipe.tasks.vision.core.BaseVisionTaskApi")

            // Fail fast with a clear message if the model asset is missing.
            context.assets.open(modelAssetPath).use { }

            val baseOptions = BaseOptions.builder()
                .setModelAssetPath(modelAssetPath)
                .build()

            val options = HandLandmarker.HandLandmarkerOptions.builder()
                .setBaseOptions(baseOptions)
                .setRunningMode(RunningMode.IMAGE)
                .setNumHands(1)
                .setMinHandDetectionConfidence(0.6f)
                .setMinHandPresenceConfidence(0.6f)
                .setMinTrackingConfidence(0.6f)
                .build()
            handLandmarker = HandLandmarker.createFromOptions(context, options)
        }
    }

    fun processFrame(frameBytes: ByteArray): Map<String, Any>? {
        if (frameBytes.isEmpty()) return null

        synchronized(processLock) {
            val landmarker = handLandmarker ?: return null

            var bitmap: Bitmap? = null
            try {
                val decodeOptions = BitmapFactory.Options().apply {
                    inPreferredConfig = Bitmap.Config.ARGB_8888
                }
                bitmap = BitmapFactory.decodeStream(ByteArrayInputStream(frameBytes), null, decodeOptions)
                    ?: return null
                if (bitmap.width <= 0 || bitmap.height <= 0) return null

                val softwareBitmap = ensureSoftwareBitmap(bitmap)
                if (softwareBitmap !== bitmap) {
                    bitmap.recycle()
                    bitmap = softwareBitmap
                }

                val mpImage = BitmapImageBuilder(softwareBitmap).build()
                val result: HandLandmarkerResult = landmarker.detect(mpImage)
                if (result.landmarks().isEmpty()) {
                    return null
                }

                val firstHand = result.landmarks()[0]
                val xs = firstHand.map { it.x().toDouble() }
                val ys = firstHand.map { it.y().toDouble() }
                if (xs.size < 21 || ys.size < 21) {
                    return null
                }

                val minX = xs.minOrNull() ?: return null
                val minY = ys.minOrNull() ?: return null
                val features = ArrayList<Double>(42)
                for (i in 0 until 21) {
                    features.add(xs[i] - minX)
                    features.add(ys[i] - minY)
                }

                val span = features.maxOrNull() ?: 0.0
                val handScore = result.handednesses()
                    .firstOrNull()
                    ?.firstOrNull()
                    ?.score()
                    ?.toDouble() ?: 0.0

                return mapOf(
                    "features42" to features,
                    "handScore" to handScore,
                    "span" to span,
                    "ts" to System.currentTimeMillis()
                )
            } catch (_: Exception) {
                return null
            } finally {
                bitmap?.recycle()
            }
        }
    }

    fun close() {
        synchronized(processLock) {
            handLandmarker?.close()
            handLandmarker = null
        }
    }

    private fun ensureSoftwareBitmap(source: Bitmap): Bitmap {
        if (source.config == Bitmap.Config.ARGB_8888 && !source.isRecycled) {
            return source
        }
        return source.copy(Bitmap.Config.ARGB_8888, false) ?: source
    }
}
