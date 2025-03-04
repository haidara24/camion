import UIKit
import Flutter
import FirebaseCore
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    if #available(iOS 10.0, *) {
        // UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    } else {
        // Fallback on earlier versions
    }

    GMSServices.provideAPIKey("AIzaSyCl_H8BXqnTm32umdYVQrKMftTiFpRqd-c")
    GeneratedPluginRegistrant.register(with: self)
   
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  @available(iOS 10.0, *)
  override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
  {
      completionHandler([.alert, .badge, .sound])
  }
}
