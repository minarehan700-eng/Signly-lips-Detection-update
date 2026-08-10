package com.example.mobile_offline

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val handChannelName = "asl/offline/landmarks"
    private val faceChannelName = "asl/offline/face"
    private lateinit var handBridge: HandLandmarkerBridge
    private lateinit var faceBridge: FaceLandmarkerBridge
    private val frameExecutor = Executors.newSingleThreadExecutor()
    private val faceFrameExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        handBridge = HandLandmarkerBridge(this)
        faceBridge = FaceLandmarkerBridge(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, handChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "initializeHandLandmarker" -> {
                        // MediaPipe JNI/static init must run on the main thread (crashes on
                        // background executors on Android 15/16 with 16 KB page sizes).
                        mainHandler.post {
                            if (isFinishing) {
                                result.error("init_failed", "Activity is finishing", null)
                                return@post
                            }
                            try {
                                handBridge.initialize()
                                result.success(null)
                            } catch (e: Exception) {
                                result.error(
                                    "init_failed",
                                    "Failed to initialize hand landmarker. Ensure android/app/src/main/assets/hand_landmarker.task exists. Root error: ${e.message}",
                                    null
                                )
                            }
                        }
                    }
                    "isHandLandmarkerInitialized" -> {
                        result.success(handBridge.isInitialized())
                    }
                    "processFrame" -> {
                        if (!handBridge.isInitialized()) {
                            result.success(null)
                            return@setMethodCallHandler
                        }

                        val bytes = call.argument<ByteArray>("bytes")
                        if (bytes == null) {
                            result.error("bad_args", "Missing frame bytes", null)
                            return@setMethodCallHandler
                        }

                        frameExecutor.execute {
                            val payload = try {
                                handBridge.processFrame(bytes)
                            } catch (_: Exception) {
                                null
                            }
                            if (!isFinishing) {
                                mainHandler.post { result.success(payload) }
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, faceChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "initializeFaceLandmarker" -> {
                        mainHandler.post {
                            if (isFinishing) {
                                result.error("init_failed", "Activity is finishing", null)
                                return@post
                            }
                            try {
                                faceBridge.initialize()
                                result.success(null)
                            } catch (e: Exception) {
                                result.error(
                                    "init_failed",
                                    "Failed to initialize face landmarker. Ensure android/app/src/main/assets/face_landmarker.task exists. Root error: ${e.message}",
                                    null
                                )
                            }
                        }
                    }
                    "isFaceLandmarkerInitialized" -> {
                        result.success(faceBridge.isInitialized())
                    }
                    "processFaceFrame" -> {
                        if (!faceBridge.isInitialized()) {
                            result.success(
                                mapOf(
                                    "faceDetected" to false,
                                    "mouthOpen" to 0.0,
                                    "mouthPucker" to 0.0,
                                    "smile" to 0.0,
                                    "mouthClose" to 0.0,
                                    "mouthFunnel" to 0.0,
                                    "mouthStretch" to 0.0,
                                    "ts" to System.currentTimeMillis()
                                )
                            )
                            return@setMethodCallHandler
                        }

                        val bytes = call.argument<ByteArray>("bytes")
                        if (bytes == null) {
                            result.error("bad_args", "Missing frame bytes", null)
                            return@setMethodCallHandler
                        }

                        faceFrameExecutor.execute {
                            val payload = try {
                                faceBridge.processFrame(bytes)
                            } catch (_: Exception) {
                                mapOf(
                                    "faceDetected" to false,
                                    "mouthOpen" to 0.0,
                                    "mouthPucker" to 0.0,
                                    "smile" to 0.0,
                                    "mouthClose" to 0.0,
                                    "mouthFunnel" to 0.0,
                                    "mouthStretch" to 0.0,
                                    "ts" to System.currentTimeMillis()
                                )
                            }
                            if (!isFinishing) {
                                mainHandler.post { result.success(payload) }
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        frameExecutor.shutdown()
        faceFrameExecutor.shutdown()
        handBridge.close()
        faceBridge.close()
        super.onDestroy()
    }
}
