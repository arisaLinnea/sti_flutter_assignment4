import Flutter
import UIKit

// This is required for calling FlutterLocalNotificationsPlugin.setPluginRegistrantCallback method.
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 9.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
// This is required to make any communication available in the action isolate.
  FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
    GeneratedPluginRegistrant.register(with: registry)
  }
    /*
     // Register actions
    let action1 = UNNotificationAction(identifier: "action1", title: "Action 1", options: [])
    let action2 = UNNotificationAction(identifier: "action2", title: "Action 2", options: [])
    
    let category = UNNotificationCategory(identifier: "myCategory", actions: [action1, action2], intentIdentifiers: [], options: [])
    UNUserNotificationCenter.current().setNotificationCategories([category])
    */
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
