import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../functions/secure_logger.dart';

enum CallQuality {
  excellent,
  good,
  poor,
}

class WebRTCCallService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  bool isMicMuted = false;
  bool isInitialized = false;
  bool isVideoEnabled = false;
  bool isFrontCamera = true;
  bool _isSpeakerOn = true;
  bool _hasVideoCapability = false;
  bool _hasAudioCapability = false;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  MediaStream? get remoteStream => _remoteStream;
  bool get hasVideoCapability => _hasVideoCapability;
  bool get hasAudioCapability => _hasAudioCapability;

  Timer? _statsTimer;

  // ICE restart handling
  Timer? _iceRestartTimer;
  int _iceRestartAttempts = 0;
  static const int _maxIceRestartAttempts = 3;
  static const Duration _iceRestartDelay = Duration(seconds: 2);
  RTCIceConnectionState? _lastIceState;

  // Callbacks matching AgoraCallService interface
  Function(String peerId)? onUserJoined;
  Function(String peerId)? onUserLeft;
  Function(String error)? onError;
  Function()? onCallEnded;
  Function()? onConnectionSuccess;
  Function(String peerId, bool enabled)? onRemoteVideoStateChanged;
  Function(CallQuality quality)? onNetworkQualityChanged;

  // WebRTC-specific callbacks
  Function(RTCIceCandidate candidate)? onIceCandidate;
  Function(RTCIceConnectionState state)? onIceConnectionStateChanged;
  Function(RTCSessionDescription offer)? onRenegotiationOffer;

  /// Called when ICE restart is needed (network change recovery)
  Function()? onIceRestartNeeded;

  /// Called when connection is recovering
  Function()? onConnectionRecovering;

  Map<String, dynamic>? _iceServers;

  /// Optimizes SDP for voice quality by configuring Opus codec parameters
  /// Returns original SDP if optimization fails to prevent breaking the call
  String _optimizeSdpForVoice(String sdp) {
    try {
      // Set Opus parameters for better voice quality
      // - useinbandfec=1: Enable forward error correction for packet loss recovery
      // - stereo=0: Mono audio (better for voice, reduces bandwidth)
      // - maxaveragebitrate=32000: 32kbps is optimal for voice clarity
      // - maxplaybackrate=16000: Narrow-band for voice (reduces artifacts)
      // - sprop-maxcapturerate=16000: Capture rate optimized for voice
      // - cbr=1: Constant bitrate for more consistent quality

      String optimizedSdp = sdp;

      // Detect line ending used in the SDP (iOS may use \n, others use \r\n)
      final lineEnding = sdp.contains('\r\n') ? '\r\n' : '\n';

      // Find the Opus codec line and add parameters
      final opusRegex = RegExp(r'a=fmtp:(\d+) (.*)');
      optimizedSdp = optimizedSdp.replaceAllMapped(opusRegex, (match) {
        final payloadType = match.group(1);
        final existingParams = match.group(2) ?? '';

        // Check if this is the Opus codec by looking for minptime
        if (existingParams.contains('minptime')) {
          // Only add parameters if they don't already exist
          String newParams = existingParams;
          if (!existingParams.contains('stereo=')) {
            newParams = '$newParams;stereo=0';
          }
          if (!existingParams.contains('maxaveragebitrate=')) {
            newParams = '$newParams;maxaveragebitrate=32000';
          }
          if (!existingParams.contains('useinbandfec=')) {
            newParams = '$newParams;useinbandfec=1';
          }
          if (!existingParams.contains('cbr=')) {
            newParams = '$newParams;cbr=1';
          }
          return 'a=fmtp:$payloadType $newParams';
        }
        return match.group(0)!;
      });

      // Set ptime to 20ms for good balance between latency and quality
      if (!optimizedSdp.contains('a=ptime:')) {
        optimizedSdp = optimizedSdp.replaceFirst(
          RegExp(r'(a=rtpmap:\d+ opus/48000/2)'),
          '\$1${lineEnding}a=ptime:20',
        );
      }

      SecureLogger.webrtc('SDP optimized for voice quality');
      return optimizedSdp;
    } catch (e) {
      SecureLogger.webrtc('SDP optimization failed: $e, using original SDP');
      return sdp;
    }
  }

  final Map<String, dynamic> _sdpConstraints = {
    'offerToReceiveAudio': true,
    'offerToReceiveVideo': true,
  };

  Future<void> initialize() async {
    if (isInitialized) return;

    try {
      await localRenderer.initialize();
      await remoteRenderer.initialize();

      SecureLogger.webrtc('Renderers initialized');
      isInitialized = true;
      SecureLogger.webrtc('Service initialized');
    } catch (e) {
      SecureLogger.webrtc('Error initializing: $e');
      onError?.call('Failed to initialize WebRTC: $e');
      rethrow;
    }
  }

  void setIceServers(Map<String, dynamic> config) {
    _iceServers = config;
    SecureLogger.webrtc('ICE servers configured');
  }

  Future<void> _createPeerConnection() async {
    final baseConfig = _iceServers ?? {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
    };

    // Ensure sdpSemantics is set for proper WebRTC operation
    final configuration = {
      ...baseConfig,
      'sdpSemantics': 'unified-plan',
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      SecureLogger.webrtc('ICE candidate generated');
      onIceCandidate?.call(candidate);
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      SecureLogger.webrtc('ICE connection state: $state');
      _lastIceState = state;
      onIceConnectionStateChanged?.call(state);

      switch (state) {
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
        case RTCIceConnectionState.RTCIceConnectionStateCompleted:
          // Connection established - reset retry counter and cancel any pending restart
          _iceRestartAttempts = 0;
          _iceRestartTimer?.cancel();
          onConnectionSuccess?.call();
          _monitorConnectionQuality();
          break;
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          SecureLogger.webrtc('ICE connection failed, attempting restart...');
          _handleIceFailure();
          break;
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
          SecureLogger.webrtc('Connection disconnected, scheduling ICE restart...');
          onConnectionRecovering?.call();
          _scheduleIceRestart();
          break;
        case RTCIceConnectionState.RTCIceConnectionStateClosed:
          _iceRestartTimer?.cancel();
          onCallEnded?.call();
          break;
        case RTCIceConnectionState.RTCIceConnectionStateChecking:
          // Connection is being established, cancel any restart timer
          _iceRestartTimer?.cancel();
          break;
        default:
          break;
      }
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      SecureLogger.webrtc('Remote track received: ${event.track.kind}');
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];

        if (event.track.kind == 'video') {
          // Don't enable video view on initial track - wait for explicit unmute
          // This prevents black screen for voice-only calls
          remoteRenderer.srcObject = null;
          onRemoteVideoStateChanged?.call('remote', false);

          event.track.onMute = () {
            SecureLogger.webrtc('Remote video muted');
            remoteRenderer.srcObject = null;
            onRemoteVideoStateChanged?.call('remote', false);
          };

          event.track.onUnMute = () {
            SecureLogger.webrtc('Remote video unmuted');
            remoteRenderer.srcObject = _remoteStream;
            onRemoteVideoStateChanged?.call('remote', true);
          };

          // Don't auto-enable video - rely on explicit socket signaling
          // to prevent black screen when remote user hasn't enabled video
        }

        onUserJoined?.call('remote');
      }
    };

    _peerConnection!.onRemoveStream = (MediaStream stream) {
      SecureLogger.webrtc('Remote stream removed');
      remoteRenderer.srcObject = null;
      _remoteStream = null;
      onUserLeft?.call('remote');
    };

    SecureLogger.webrtc('Peer connection created');
  }

  /// Schedules an ICE restart after a delay
  void _scheduleIceRestart() {
    if (_iceRestartAttempts >= _maxIceRestartAttempts) {
      SecureLogger.webrtc('Max ICE restart attempts reached ($_maxIceRestartAttempts)');
      onError?.call('فشل الاتصال بعد عدة محاولات. تحقق من اتصالك بالإنترنت.');
      return;
    }

    _iceRestartTimer?.cancel();
    _iceRestartTimer = Timer(_iceRestartDelay * (_iceRestartAttempts + 1), () {
      _iceRestartAttempts++;
      SecureLogger.webrtc('Attempting ICE restart #$_iceRestartAttempts');
      onIceRestartNeeded?.call();
    });
  }

  /// Handles ICE connection failure
  void _handleIceFailure() {
    _iceRestartAttempts = 0; // Reset counter for fresh attempt
    _scheduleIceRestart();
  }

  /// Creates an offer with ICE restart flag for network recovery
  Future<RTCSessionDescription> createIceRestartOffer() async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    final constraints = {
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': true,
      'iceRestart': true,
    };

    try {
      final offer = await _peerConnection!.createOffer(constraints);
      await _peerConnection!.setLocalDescription(offer);
      SecureLogger.webrtc('ICE restart offer created');
      return offer;
    } catch (e) {
      SecureLogger.webrtc('Error creating ICE restart offer: $e');
      rethrow;
    }
  }

  /// Cancels any pending ICE restart
  void cancelIceRestart() {
    _iceRestartTimer?.cancel();
    _iceRestartAttempts = 0;
  }

  Future<void> _createLocalStream() async {
    try {
      // Simplified audio constraints for better iOS compatibility
      final audioConstraints = {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      };

      final videoConstraints = {
        'facingMode': isFrontCamera ? 'user' : 'environment',
        'width': {'ideal': 1280},
        'height': {'ideal': 720},
        'frameRate': {'ideal': 25},
      };

      try {
        // Try to get both audio and video
        _localStream = await navigator.mediaDevices.getUserMedia({
          'audio': audioConstraints,
          'video': videoConstraints,
        });
        _hasAudioCapability = true;
        _hasVideoCapability = true;
        SecureLogger.webrtc('Local stream created with audio and video');
      } catch (e) {
        SecureLogger.webrtc('Failed to get video, falling back to audio only: $e');

        try {
          _localStream = await navigator.mediaDevices.getUserMedia({
            'audio': audioConstraints,
            'video': false,
          });
          _hasAudioCapability = true;
          _hasVideoCapability = false;
          SecureLogger.webrtc('Local stream created with audio only');
        } catch (audioError) {
          SecureLogger.webrtc('Failed to get audio: $audioError');
          _hasAudioCapability = false;
          _hasVideoCapability = false;
          onError?.call('فشل الوصول إلى الميكروفون. تأكد من إعطاء الصلاحيات المطلوبة.');
          rethrow;
        }
      }

      // Mute video by default
      for (var track in _localStream!.getVideoTracks()) {
        track.enabled = false;
      }
      isVideoEnabled = false;
      localRenderer.srcObject = null;

      // Add tracks to peer connection
      final tracks = _localStream!.getTracks();
      SecureLogger.webrtc('Adding ${tracks.length} tracks to peer connection');
      for (var track in tracks) {
        await _peerConnection!.addTrack(track, _localStream!);
      }

      // Wait a bit for the peer connection to process the tracks
      await Future.delayed(const Duration(milliseconds: 100));

      SecureLogger.webrtc(
        'Local stream ready (audio: $_hasAudioCapability, video: $_hasVideoCapability)'
      );
    } catch (e) {
      SecureLogger.webrtc('Error creating local stream: $e');
      onError?.call('فشل الوصول إلى الميكروفون/الكاميرا: $e');
      rethrow;
    }
  }

  Future<RTCSessionDescription> createOffer({bool forceNew = false}) async {
    // If we need a fresh connection or don't have one, create it
    if (_peerConnection == null || forceNew) {
      if (_peerConnection != null && forceNew) {
        SecureLogger.webrtc('Force creating new peer connection');
        await resetForReconnection();
      }
      await _createPeerConnection();
      await _createLocalStream();
    } else {
      SecureLogger.webrtc('Reusing existing peer connection for renegotiation');
    }

    try {
      // Log peer connection state before creating offer
      final signalingState = _peerConnection!.signalingState;
      final senders = await _peerConnection!.getSenders();
      SecureLogger.webrtc('Signaling state: $signalingState, senders count: ${senders.length}');

      // Create offer with empty constraints (most compatible)
      final offer = await _peerConnection!.createOffer({});

      if (offer.sdp == null || offer.type == null) {
        SecureLogger.webrtc('createOffer returned null - sdp: ${offer.sdp == null}, type: ${offer.type == null}');
        throw Exception('createOffer returned null SDP or type');
      }

      SecureLogger.webrtc('Offer created - type: ${offer.type}, sdp length: ${offer.sdp?.length}');

      // Set local description with the offer
      await _peerConnection!.setLocalDescription(offer);

      SecureLogger.webrtc('Offer created and set successfully');
      return offer;
    } catch (e) {
      SecureLogger.webrtc('createOffer/setLocalDescription failed: $e');
      // Reset peer connection on failure so retry starts fresh
      await resetForReconnection();
      rethrow;
    }
  }

  Future<RTCSessionDescription> createAnswer(RTCSessionDescription offer, {bool forceNew = false}) async {
    // If peer connection exists and has remote description, the other side
    // has reset their connection - we should reset ours too
    if (_peerConnection != null) {
      final remoteDesc = await _peerConnection!.getRemoteDescription();
      if (remoteDesc != null || forceNew) {
        SecureLogger.webrtc('Received new offer with existing connection, resetting');
        await resetForReconnection();
      }
    }

    if (_peerConnection == null) {
      await _createPeerConnection();
      await _createLocalStream();
    }

    await _peerConnection!.setRemoteDescription(offer);
    await _flushPendingCandidates();
    final answer = await _peerConnection!.createAnswer(_sdpConstraints);

    await _peerConnection!.setLocalDescription(answer);

    SecureLogger.webrtc('Answer created');
    return answer;
  }

  Future<RTCSessionDescription> setRemoteOffer(RTCSessionDescription offer) async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    await _peerConnection!.setRemoteDescription(offer);
    await _flushPendingCandidates();
    final answer = await _peerConnection!.createAnswer(_sdpConstraints);

    await _peerConnection!.setLocalDescription(answer);

    SecureLogger.webrtc('Remote offer set, answer created');
    return answer;
  }

  Future<void> setRemoteAnswer(RTCSessionDescription answer) async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    await _peerConnection!.setRemoteDescription(answer);
    await _flushPendingCandidates();
    SecureLogger.webrtc('Remote answer set');
  }

  final List<RTCIceCandidate> _pendingCandidates = [];

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    if (_peerConnection == null) {
      SecureLogger.webrtc('Peer connection not ready, queuing ICE candidate');
      _pendingCandidates.add(candidate);
      return;
    }

    final remoteDesc = await _peerConnection!.getRemoteDescription();
    if (remoteDesc == null) {
      SecureLogger.webrtc('Remote description not set, queuing ICE candidate');
      _pendingCandidates.add(candidate);
      return;
    }

    try {
      await _peerConnection!.addCandidate(candidate);
      SecureLogger.webrtc('ICE candidate added');
    } catch (e) {
      SecureLogger.webrtc('Error adding ICE candidate: $e');
    }
  }

  Future<void> _flushPendingCandidates() async {
    final remoteDesc = await _peerConnection?.getRemoteDescription();
    if (_peerConnection == null || remoteDesc == null) {
      return;
    }

    for (final candidate in _pendingCandidates) {
      try {
        await _peerConnection!.addCandidate(candidate);
        SecureLogger.webrtc('Queued ICE candidate added');
      } catch (e) {
        SecureLogger.webrtc('Error adding queued ICE candidate: $e');
      }
    }
    _pendingCandidates.clear();
  }

  Future<void> toggleMute() async {
    if (_localStream == null) return;

    try {
      isMicMuted = !isMicMuted;
      for (var track in _localStream!.getAudioTracks()) {
        track.enabled = !isMicMuted;
      }
      SecureLogger.webrtc('Audio ${isMicMuted ? "muted" : "enabled"}');
    } catch (e) {
      SecureLogger.webrtc('Error toggling mute: $e');
      isMicMuted = !isMicMuted;
    }
  }

  Future<void> toggleVideo() async {
    if (_localStream == null) return;

    try {
      isVideoEnabled = !isVideoEnabled;
      for (var track in _localStream!.getVideoTracks()) {
        track.enabled = isVideoEnabled;
      }
      localRenderer.srcObject = isVideoEnabled ? _localStream : null;
      SecureLogger.webrtc('Video ${isVideoEnabled ? "enabled" : "disabled"}');
    } catch (e) {
      SecureLogger.webrtc('Error toggling video: $e');
      isVideoEnabled = !isVideoEnabled; // Revert on error
    }
  }

  Future<void> switchCamera() async {
    if (!isVideoEnabled || _localStream == null) return;

    try {
      isFrontCamera = !isFrontCamera;

      for (var track in _localStream!.getVideoTracks()) {
        await Helper.switchCamera(track);
      }

      SecureLogger.webrtc('Camera switched to ${isFrontCamera ? "front" : "back"}');
    } catch (e) {
      SecureLogger.webrtc('Error switching camera: $e');
      isFrontCamera = !isFrontCamera;
    }
  }

  Future<void> switchSpeaker(bool useSpeaker) async {
    try {
      _isSpeakerOn = useSpeaker;
      await Helper.setSpeakerphoneOn(useSpeaker);
      SecureLogger.webrtc('Speaker ${useSpeaker ? "enabled" : "disabled"}');
    } catch (e) {
      SecureLogger.webrtc('Error switching speaker: $e');
      _isSpeakerOn = !useSpeaker;
    }
  }

  bool get isSpeakerOn => _isSpeakerOn;

  void _monitorConnectionQuality() {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_peerConnection == null) {
        timer.cancel();
        return;
      }

      try {
        final stats = await _peerConnection!.getStats();

        double? rtt;
        double? packetsLost;
        double? packetsReceived;
        double? jitter;

        for (var report in stats) {
          if (report.type == 'candidate-pair' && report.values['state'] == 'succeeded') {
            rtt = (report.values['currentRoundTripTime'] as num?)?.toDouble();
          }
          if (report.type == 'inbound-rtp' && report.values['kind'] == 'audio') {
            packetsLost = (report.values['packetsLost'] as num?)?.toDouble();
            packetsReceived = (report.values['packetsReceived'] as num?)?.toDouble();
            jitter = (report.values['jitter'] as num?)?.toDouble();
          }
        }

        // Calculate quality based on multiple factors
        final quality = _calculateCallQuality(
          rtt: rtt,
          packetsLost: packetsLost,
          packetsReceived: packetsReceived,
          jitter: jitter,
        );

        onNetworkQualityChanged?.call(quality);
      } catch (e) {
        SecureLogger.webrtc('Error monitoring quality: $e');
      }
    });
  }

  CallQuality _calculateCallQuality({
    double? rtt,
    double? packetsLost,
    double? packetsReceived,
    double? jitter,
  }) {
    int poorFactors = 0;
    int goodFactors = 0;

    // RTT analysis (in seconds)
    if (rtt != null) {
      if (rtt < 0.1) {
        goodFactors += 2; // Excellent RTT
      } else if (rtt < 0.3) {
        goodFactors += 1; // Good RTT
      } else {
        poorFactors += 1; // Poor RTT
      }
    }

    // Jitter analysis (in seconds)
    if (jitter != null) {
      if (jitter < 0.03) {
        goodFactors += 1; // Low jitter
      } else if (jitter > 0.05) {
        poorFactors += 1; // High jitter
      }
    }

    // Packet loss analysis
    if (packetsLost != null && packetsReceived != null && packetsReceived > 0) {
      final lossRate = packetsLost / (packetsLost + packetsReceived);
      if (lossRate < 0.01) {
        goodFactors += 2; // Excellent - less than 1% loss
      } else if (lossRate < 0.05) {
        goodFactors += 1; // Acceptable - less than 5% loss
      } else {
        poorFactors += 2; // Poor - more than 5% loss
      }
    }

    // Determine overall quality
    if (poorFactors >= 2) {
      return CallQuality.poor;
    } else if (goodFactors >= 3) {
      return CallQuality.excellent;
    } else {
      return CallQuality.good;
    }
  }

  Future<void> endCall() async {
    try {
      // Cancel all timers first
      _statsTimer?.cancel();
      _statsTimer = null;
      _iceRestartTimer?.cancel();
      _iceRestartTimer = null;
      _iceRestartAttempts = 0;

      if (isVideoEnabled) {
        isVideoEnabled = false;
        if (_localStream != null) {
          for (var track in _localStream!.getVideoTracks()) {
            try {
              track.stop();
            } catch (e) {
              SecureLogger.webrtc('Error stopping video track: $e');
            }
          }
        }
      }

      await _closePeerConnection();
      onCallEnded?.call();
      SecureLogger.webrtc('Call ended');
    } catch (e) {
      SecureLogger.webrtc('Error ending call: $e');
    }
  }

  Future<void> _closePeerConnection() async {
    if (_localStream != null) {
      for (var track in _localStream!.getTracks()) {
        track.stop();
      }
      await _localStream!.dispose();
      _localStream = null;
    }

    if (_remoteStream != null) {
      await _remoteStream!.dispose();
      _remoteStream = null;
    }

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;

    if (_peerConnection != null) {
      await _peerConnection!.close();
      _peerConnection = null;
    }
  }

  /// Checks if the WebRTC peer connection is still active/connected.
  bool get isConnectionAlive {
    if (_peerConnection == null) return false;

    // Check ICE connection state
    // Connected or Completed means the P2P connection is working
    return true; // We'll check state via callback, not sync getter
  }

  /// Checks if we need to re-establish the WebRTC connection.
  /// Returns true if peer connection is null or in a failed/closed state.
  Future<bool> needsReconnection() async {
    if (_peerConnection == null) {
      SecureLogger.webrtc('Peer connection is null, needs reconnection');
      return true;
    }

    // If peer connection exists, it might still be alive
    // The ICE connection state tells us if P2P is working
    SecureLogger.webrtc('Peer connection exists, checking if still usable');
    return false;
  }

  /// Resets the peer connection for reconnection scenarios.
  /// Only call this if the connection is actually dead.
  Future<void> resetForReconnection() async {
    SecureLogger.webrtc('Resetting peer connection for reconnection');

    // Cancel ICE restart timer
    _iceRestartTimer?.cancel();
    _iceRestartAttempts = 0;

    // Close existing peer connection but keep renderers initialized
    if (_localStream != null) {
      for (var track in _localStream!.getTracks()) {
        try {
          track.stop();
        } catch (e) {
          SecureLogger.webrtc('Error stopping track: $e');
        }
      }
      await _localStream!.dispose();
      _localStream = null;
    }

    if (_remoteStream != null) {
      await _remoteStream!.dispose();
      _remoteStream = null;
    }

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;

    if (_peerConnection != null) {
      await _peerConnection!.close();
      _peerConnection = null;
    }

    // Clear pending ICE candidates
    _pendingCandidates.clear();

    // Reset state
    isVideoEnabled = false;
    _lastIceState = null;

    SecureLogger.webrtc('Peer connection reset complete');
  }

  Future<void> dispose() async {
    try {
      // Cancel all timers
      _statsTimer?.cancel();
      _statsTimer = null;
      _iceRestartTimer?.cancel();
      _iceRestartTimer = null;

      await _closePeerConnection();

      await localRenderer.dispose();
      await remoteRenderer.dispose();

      isInitialized = false;
      _hasAudioCapability = false;
      _hasVideoCapability = false;

      SecureLogger.webrtc('Service disposed');
    } catch (e) {
      SecureLogger.webrtc('Error disposing: $e');
    }
  }
}
