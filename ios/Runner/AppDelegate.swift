import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let handChannelName = "asl/offline/landmarks"
  private let faceChannelName = "asl/offline/face"
  private let handBridge = HandLandmarkerBridge()
  private let faceBridge = FaceLandmarkerBridge()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let handChannel = FlutterMethodChannel(
      name: handChannelName,
      binaryMessenger: controller.binaryMessenger
    )
    let faceChannel = FlutterMethodChannel(
      name: faceChannelName,
      binaryMessenger: controller.binaryMessenger
    )

    handChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self else { return }
      switch call.method {
      case "initializeHandLandmarker":
        guard let modelPath = Bundle.main.path(forResource: "hand_landmarker", ofType: "task") else {
          result(FlutterError(code: "model_missing", message: "hand_landmarker.task not found", details: nil))
          return
        }
        do {
          try self.handBridge.initialize(modelPath: modelPath)
          result(nil)
        } catch {
          result(FlutterError(code: "init_failed", message: "Failed to initialize hand landmarker", details: error.localizedDescription))
        }
      case "processFrame":
        guard
          let args = call.arguments as? [String: Any],
          let typedData = args["bytes"] as? FlutterStandardTypedData
        else {
          result(FlutterError(code: "bad_args", message: "Missing bytes", details: nil))
          return
        }
        let payload = self.handBridge.processFrame(frameBytes: typedData.data)
        result(payload)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    faceChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self else { return }
      switch call.method {
      case "initializeFaceLandmarker":
        guard let modelPath = Bundle.main.path(forResource: "face_landmarker", ofType: "task") else {
          result(FlutterError(code: "model_missing", message: "face_landmarker.task not found", details: nil))
          return
        }
        do {
          try self.faceBridge.initialize(modelPath: modelPath)
          result(nil)
        } catch {
          result(FlutterError(
            code: "init_failed",
            message: "Failed to initialize face landmarker. Ensure face_landmarker.task is in the Runner bundle.",
            details: error.localizedDescription
          ))
        }
      case "isFaceLandmarkerInitialized":
        result(self.faceBridge.isInitialized())
      case "processFaceFrame":
        guard
          let args = call.arguments as? [String: Any],
          let typedData = args["bytes"] as? FlutterStandardTypedData
        else {
          result(FlutterError(code: "bad_args", message: "Missing bytes", details: nil))
          return
        }
        let payload = self.faceBridge.processFrame(frameBytes: typedData.data)
        result(payload)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
