import UIKit
import Flutter
import FirebaseCore
import flutter_callkit_incoming
import PushKit
import CallKit

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {

    // ==================== App Launch ====================
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Initialize Firebase
        FirebaseApp.configure()

        // Register Flutter plugins
        GeneratedPluginRegistrant.register(with: self)

        // Setup notifications
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }

        // Setup VoIP Push Notifications
        self.voipRegistration()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // ==================== VoIP Push Setup ====================
    func voipRegistration() {
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }

    // Called when VoIP token is updated
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print("✅ VoIP token updated")

        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print("📱 VoIP Device Token: \(deviceToken)")

        // You can send this token to your server if needed
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    }

    // Called when VoIP push is received
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("📞 VoIP push received")

        guard type == .voIP else {
            completion()
            return
        }

        // Handle the incoming call from VoIP push
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(flutter_callkit_incoming.Data(args: payload.dictionaryPayload as? [String : Any<>] ?? [:]), fromPushKit: true)

        completion()
    }

    // Called when VoIP token is invalidated
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("⚠️ VoIP token invalidated")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }

    // ==================== Handle Incoming Call from Background/Killed ====================
    override func application(_ application: UIApplication,
                              continue userActivity: NSUserActivity,
                              restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        // Check if this is a call continuation activity
        guard userActivity.activityType == "INStartCallIntent" else {
            return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
        }

        print("📞 Handling incoming call from background/killed state")

        // Get the call handle
        if let handle = userActivity.startCallHandle {
            // Handle the call
            SwiftFlutterCallkitIncomingPlugin.sharedInstance?.handleCall(handle)
        }

        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}

// ==================== Extension for Call Handle ====================
extension NSUserActivity {
    var startCallHandle: String? {
        guard let interaction = interaction,
              let startCallIntent = interaction.intent as? INStartCallIntent,
              let person = startCallIntent.contacts?.first,
              let handle = person.personHandle?.value else {
            return nil
        }
        return handle
    }
}