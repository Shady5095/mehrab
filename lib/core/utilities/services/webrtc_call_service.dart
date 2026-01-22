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

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  MediaStream? get remoteStream => _remoteStream;

  Timer? _statsTimer;
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

  Map<String, dynamic>? _iceServers;

  final Map<String, dynamic> _sdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
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
    final configuration = _iceServers ?? {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      SecureLogger.webrtc('ICE candidate generated');
      onIceCandidate?.call(candidate);
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      SecureLogger.webrtc('ICE connection state: $state');
      onIceConnectionStateChanged?.call(state);

      switch (state) {
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
        case RTCIceConnectionState.RTCIceConnectionStateCompleted:
          onConnectionSuccess?.call();
          _monitorConnectionQuality();
          break;
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          onError?.call('Connection failed');
          break;
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
          SecureLogger.webrtc('Connection disconnected, may reconnect...');
          break;
        case RTCIceConnectionState.RTCIceConnectionStateClosed:
          onCallEnded?.call();
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

  Future<void> _createLocalStream() async {
    try {
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
      } catch (e) {
        SecureLogger.webrtc('Failed to get video, falling back to audio only: $e');
        _localStream = await navigator.mediaDevices.getUserMedia({
          'audio': audioConstraints,
          'video': false,
        });
      }

      // Mute video by default
      for (var track in _localStream!.getVideoTracks()) {
        track.enabled = false;
      }
      isVideoEnabled = false;
      localRenderer.srcObject = null;

      for (var track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }

      SecureLogger.webrtc('Local stream created with audio and video (video muted)');
    } catch (e) {
      SecureLogger.webrtc('Error creating local stream: $e');
      onError?.call('Failed to access microphone/camera: $e');
      rethrow;
    }
  }

  Future<RTCSessionDescription> createOffer() async {
    await _createPeerConnection();
    await _createLocalStream();

    final offer = await _peerConnection!.createOffer(_sdpConstraints);
    await _peerConnection!.setLocalDescription(offer);

    SecureLogger.webrtc('Offer created');
    return offer;
  }

  Future<RTCSessionDescription> createAnswer(RTCSessionDescription offer) async {
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

        for (var report in stats) {
          if (report.type == 'candidate-pair' && report.values['state'] == 'succeeded') {
            rtt = (report.values['currentRoundTripTime'] as num?)?.toDouble();
          }
          if (report.type == 'inbound-rtp' && report.values['kind'] == 'audio') {
            packetsLost = (report.values['packetsLost'] as num?)?.toDouble();
            packetsReceived = (report.values['packetsReceived'] as num?)?.toDouble();
          }
        }

        if (rtt != null || (packetsLost != null && packetsReceived != null)) {
          CallQuality quality;

          if (rtt != null) {
            if (rtt < 0.1) {
              quality = CallQuality.excellent;
            } else if (rtt < 0.3) {
              quality = CallQuality.good;
            } else {
              quality = CallQuality.poor;
            }
          } else if (packetsLost != null && packetsReceived != null && packetsReceived > 0) {
            final lossRate = packetsLost / (packetsLost + packetsReceived);
            if (lossRate < 0.01) {
              quality = CallQuality.excellent;
            } else if (lossRate < 0.05) {
              quality = CallQuality.good;
            } else {
              quality = CallQuality.poor;
            }
          } else {
            quality = CallQuality.good;
          }

          onNetworkQualityChanged?.call(quality);
        }
      } catch (e) {
        SecureLogger.webrtc('Error monitoring quality: $e');
      }
    });
  }

  Future<void> endCall() async {
    try {
      if (isVideoEnabled) {
        isVideoEnabled = false;
        if (_localStream != null) {
          for (var track in _localStream!.getVideoTracks()) {
            track.stop();
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

  Future<void> dispose() async {
    try {
      _statsTimer?.cancel();
      await _closePeerConnection();

      await localRenderer.dispose();
      await remoteRenderer.dispose();

      isInitialized = false;
      SecureLogger.webrtc('Service disposed');
    } catch (e) {
      SecureLogger.webrtc('Error disposing: $e');
    }
  }
}
