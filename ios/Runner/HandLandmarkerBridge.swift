import Foundation
import MediaPipeTasksVision
import UIKit

final class HandLandmarkerBridge {
  private var handLandmarker: HandLandmarker?

  func initialize(modelPath: String) throws {
    if handLandmarker != nil { return }

    let baseOptions = BaseOptions(modelAssetPath: modelPath)
    var options = HandLandmarkerOptions()
    options.baseOptions = baseOptions
    options.runningMode = .image
    options.numHands = 1
    options.minHandDetectionConfidence = 0.6
    options.minTrackingConfidence = 0.6
    options.minHandPresenceConfidence = 0.6
    handLandmarker = try HandLandmarker(options: options)
  }

  func processFrame(frameBytes: Data) -> [String: Any]? {
    guard !frameBytes.isEmpty else { return nil }
    guard let handLandmarker else { return nil }
    guard let image = UIImage(data: frameBytes), let cgImage = image.cgImage else {
      return nil
    }
    guard cgImage.width > 0, cgImage.height > 0 else { return nil }

    let mpImage = try? MPImage(uiImage: UIImage(cgImage: cgImage))
    guard let mpImage else { return nil }
    guard let result = try? handLandmarker.detect(image: mpImage) else { return nil }
    guard let hand = result.landmarks.first else { return nil }
    if hand.count < 21 { return nil }

    let xs = hand.map { Double($0.x) }
    let ys = hand.map { Double($0.y) }
    guard let minX = xs.min(), let minY = ys.min() else { return nil }

    var features: [Double] = []
    features.reserveCapacity(42)
    for i in 0..<21 {
      features.append(xs[i] - minX)
      features.append(ys[i] - minY)
    }

    let span = features.max() ?? 0
    let handScore = result.handedness.first?.first?.score ?? 0

    return [
      "features42": features,
      "handScore": handScore,
      "span": span,
      "ts": Int(Date().timeIntervalSince1970 * 1000)
    ]
  }
}
