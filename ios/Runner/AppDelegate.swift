import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String
      ?? Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
      let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty,
         !trimmed.contains("$("),
         trimmed != "YOUR_GOOGLE_MAPS_API_KEY" {
        GMSServices.provideAPIKey(trimmed)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
