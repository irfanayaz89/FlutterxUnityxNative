import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  var channel: FlutterMethodChannel? = nil
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    channel = FlutterMethodChannel(name: "com.flutterxunity.unityview/channel",
                                   binaryMessenger: controller.binaryMessenger)
    
    channel?.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in

      guard call.method == "openUnityView" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let swiftViewController : SwiftViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "swiftVC") as! SwiftViewController
        swiftViewController.callback = {
            [weak self] in
            self?.swiftViewControllerDismissed()
        }
      swiftViewController.modalPresentationStyle = .fullScreen
      controller.present(swiftViewController, animated: true)
    })
    
    UnityEmbeddedSwift.setHostMainWindow(window)
    UnityEmbeddedSwift.setLaunchinOptions(launchOptions)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  func swiftViewControllerDismissed() {
    channel?.invokeMethod("unityViewFinished", arguments: nil)
  }
}
