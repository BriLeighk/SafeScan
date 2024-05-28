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
          getSpywareApps(result: result)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func getSpywareApps(result: @escaping FlutterResult) {
    guard let path = Bundle.main.path(forResource: "app-ids-research", ofType: "csv") else {
      result(FlutterError(code: "FileNotFound", message: "CSV file not found",  details: nil))
      return
    }

    do {
      let content = try String(contentsOfFile: path) 
      let rows = content.components(separatedBy: "\n")
      var spywareApps: [[String: String]] = []

      for row in rows {
        let columns = row.components(separatedBy ",")
        if columns.count >= 5 {
          let appID = columns[0]
          let installer = columns[1]
          let type = columns[2]
          let name = columns [3]
          let urlScheme = columns[4]

          if let url = URL(string: urlScheme), UIApplication.shared.canOpenURL(url) {
            let appInfo: [String: String] = [
              "id": appId,
              "installer": installer
              "type": type,
              "name": name,
              "urlScheme": urlScheme
            ]
            spywareApps.append(appInfo)
          }
        }
      }
      result(spywareApps)

    } catch {
      result(FlutterError(code: "FileReadError", message: "Unable to read the CSV file", details: error.localizedDescription))
    }
  }
}
