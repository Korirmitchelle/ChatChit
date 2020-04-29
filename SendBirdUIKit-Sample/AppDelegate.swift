
import UIKit
import SendBirdUIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SBUMain.initialize(applicationId: "")
        SBUGlobals.AccessToken = ""
        initializeRemoteNotification()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func initializeRemoteNotification() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert]) { granted, error in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Register a device token to SendBird server.
        SBUMain.registerPush(deviceToken: deviceToken) { success in
            
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void)
    {
            completionHandler( [.alert, .badge, .sound])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        let userInfo = response.notification.request.content.userInfo
        print("info received here \(userInfo)")
        guard let payload: NSDictionary = userInfo["sendbird"] as? NSDictionary,
            let channel: NSDictionary = payload["channel"] as? NSDictionary,
            let channelUrl: String = channel["channel_url"] as? String else { return }
        SBUMain.openChannel(channelUrl: channelUrl, basedOnChannelList: true)
    }
}
