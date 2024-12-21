import UIKit
import Flutter
import flutter_downloader

let flutterEngine = FlutterEngine(name: "SharedEngine", project: nil, allowHeadlessExecution: true)
var isFlutterEngineRegistered = false

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//    GeneratedPluginRegistrant.register(with: self)
//    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
      
      
      flutterEngine.run()
      GeneratedPluginRegistrant.register(with: flutterEngine)
      FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
      return true
  }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}
