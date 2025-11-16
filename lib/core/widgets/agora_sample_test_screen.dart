import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:mehrab/core/utilities/services/sensitive_app_constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class AgoraCallServiceSampleTest {
  final String appId;
  late final RtcEngine _engine;

  bool isInitialized = false;
  bool isMuted = false;
  bool isSpeakerOn = true;

  Function(int uid)? onUserJoined;
  Function(int uid)? onUserOffline;
  Function()? onJoinSuccess;

  AgoraCallServiceSampleTest({required this.appId});

  /// تهيئة Agora (مرة واحدة فقط)
  Future<void> initialize() async {
    if (isInitialized) return;

    await [Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          onJoinSuccess?.call();
        },
        onUserJoined: (connection, uid, elapsed) {
          onUserJoined?.call(uid);
        },
        onUserOffline: (connection, uid, reason) {
          onUserOffline?.call(uid);
        },
      ),
    );

    isInitialized = true;
  }

  /// الانضمام إلى روم صوتي
  Future<void> joinChannel(String channelName) async {
    await _engine.joinChannel(
      token: "",
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  /// مغادرة الروم
  Future<void> leaveChannel() async {
    await _engine.leaveChannel();
  }

  /// كتم أو تشغيل المايك
  void toggleMute() {
    isMuted = !isMuted;
    _engine.muteLocalAudioStream(isMuted);
  }

  /// تفعيل أو إلغاء مكبر الصوت
  void toggleSpeaker() {
    isSpeakerOn = !isSpeakerOn;
    _engine.setEnableSpeakerphone(isSpeakerOn);
  }

  /// تحرير الموارد عند الإغلاق
  Future<void> dispose() async {
    await _engine.release();
  }
}


class CallPage extends StatefulWidget {
  final String channelName;
  final String appId;

  const CallPage({super.key, required this.channelName, required this.appId});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late AgoraCallServiceSampleTest callService;

  bool joined = false;
  int? remoteUid;

  @override
  void initState() {
    super.initState();
    setupCall();
  }

  Future<void> setupCall() async {
    callService = AgoraCallServiceSampleTest(appId: widget.appId);

    callService.onJoinSuccess = () {
      setState(() => joined = true);
    };

    callService.onUserJoined = (uid) {
      setState(() => remoteUid = uid);
    };

    callService.onUserOffline = (uid) {
      setState(() => remoteUid = null);
    };
    await callService.initialize();
    await callService.joinChannel(widget.channelName);
  }

  @override
  void dispose() {
    callService.leaveChannel();
    callService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusText = joined
        ? (remoteUid != null
        ? "Connected to $remoteUid"
        : "Waiting for user...")
        : "Connecting...";

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // الحالة
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  const Icon(Icons.account_circle,
                      size: 100, color: Colors.white70),
                  const SizedBox(height: 12),
                  Text(
                    widget.channelName,
                    style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statusText,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),

            // الأزرار
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _circleButton(
                    icon: callService.isMuted ? Icons.mic_off : Icons.mic,
                    color: callService.isMuted ? Colors.redAccent : Colors.white,
                    onPressed: () {
                      setState(() => callService.toggleMute());
                    },
                  ),
                  _circleButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    size: 70,
                    onPressed: () {
                      callService.leaveChannel();
                      Navigator.pop(context);
                    },
                  ),
                  _circleButton(
                    icon: callService.isSpeakerOn
                        ? Icons.volume_up
                        : Icons.hearing,
                    color:
                    callService.isSpeakerOn ? Colors.white : Colors.grey,
                    onPressed: () {
                      setState(() => callService.toggleSpeaker());
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 60,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[900],
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}


final appId = SensitiveAppConstants.getCurrentAppId;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final channelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agora Voice Demo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: channelController,
              decoration: const InputDecoration(
                hintText: "Enter Room Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final name = channelController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CallPage(channelName: name, appId: appId),
                    ),
                  );
                }
              },
              child: const Text("Join / Create Room"),
            ),
          ],
        ),
      ),
    );
  }
}
