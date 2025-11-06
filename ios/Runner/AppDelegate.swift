import UIKit
import Flutter
import FirebaseCore
import flutter_callkit_incoming
import PushKit
import CallKit
import Intents

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {

    // Keep reference for VoIP registration
    var voipRegistry: PKPushRegistry?

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
        voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry?.delegate = self
        voipRegistry?.desiredPushTypes = [.voIP]
        print("✅ VoIP registry initialized")
    }

    // Called when VoIP token is updated
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print("📱 VoIP Device Token: \(deviceToken)")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
    }

    // Called when VoIP push is received
    func pushRegistry(
        _ registry: PKPushRegistry,
        didReceiveIncomingPushWith payload: PKPushPayload,
        for type: PKPushType,
        completion: @escaping () -> Void
    ) {
        print("📞 VoIP push received")

        guard type == .voIP else {
            completion()
            return
        }

        // Safely convert payload keys
        var callData: [String: Any] = [:]
        for (key, value) in payload.dictionaryPayload {
            if let stringKey = key as? String {
                callData[stringKey] = value
            }
        }

        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(
            flutter_callkit_incoming.Data(args: callData),
            fromPushKit: true
        )

        completion()
    }

    // Called when VoIP token is invalidated
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("⚠️ VoIP token invalidated")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
    }

    // ==================== Handle Incoming Call from Background/Killed ====================
    override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {

        // Check if this is a call continuation activity
        guard userActivity.activityType == "INStartCallIntent" else {
            return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
        }

        print("📞 Handling incoming call from background/killed state")
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
