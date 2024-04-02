import Flutter
import UIKit

public class SwiftSpywareAppChecker: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "samples.flutter.dev/spyware", binaryMessenger: registrar.messenger())
    let instance = SwiftSpywareAppChecker()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getSpywareApps" {
      // Still need to implement the app-retrieving logic
      // It seems this can only be done using URL schemes. Example:
        // let appURL = URL(string: "app-scheme://")!
        // let appInstalled = UIApplication.shared.canOpenURL(appURL)
      
      result(["iOS functionality specifics need handling"])
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}
