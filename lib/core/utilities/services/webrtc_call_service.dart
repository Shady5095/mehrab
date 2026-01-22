import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

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

  Map<String, dynamic>? _iceServers;

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  final Map<String, dynamic> _mediaConstraints = {
    'audio': {
      'echoCancellation': true,
      'noiseSuppression': true,
      'autoGainControl': true,
    },
    'video': false,
  };

  Future<void> initialize() async {
    if (isInitialized) return;

    try {
      await localRenderer.initialize();
      await remoteRenderer.initialize();

      debugPrint('WebRTC: Renderers initialized');
      isInitialized = true;
      debugPrint('WebRTC: Service initialized');
    } catch (e) {
      debugPrint('WebRTC Error initializing: $e');
      onError?.call('Failed to initialize WebRTC: $e');
      rethrow;
    }
  }

  void setIceServers(Map<String, dynamic> config) {
    _iceServers = config;
    debugPrint('WebRTC: ICE servers configured');
  }

  Future<void> _createPeerConnection() async {
    final configuration = _iceServers ?? {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(configuration, _constraints);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      debugPrint('WebRTC: ICE candidate generated');
      onIceCandidate?.call(candidate);
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('WebRTC: ICE connection state: $state');
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
          debugPrint('WebRTC: Connection disconnected, may reconnect...');
          break;
        case RTCIceConnectionState.RTCIceConnectionStateClosed:
          onCallEnded?.call();
          break;
        default:
          break;
      }
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      debugPrint('WebRTC: Remote track received: ${event.track.kind}');
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        remoteRenderer.srcObject = _remoteStream;

        if (event.track.kind == 'video') {
          onRemoteVideoStateChanged?.call('remote', event.track.enabled);
        }

        onUserJoined?.call('remote');
      }
    };

    _peerConnection!.onRemoveStream = (MediaStream stream) {
      debugPrint('WebRTC: Remote stream removed');
      remoteRenderer.srcObject = null;
      _remoteStream = null;
      onUserLeft?.call('remote');
    };

    debugPrint('WebRTC: Peer connection created');
  }

  Future<void> _createLocalStream() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia(_mediaConstraints);
      localRenderer.srcObject = _localStream;

      for (var track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }

      debugPrint('WebRTC: Local stream created');
    } catch (e) {
      debugPrint('WebRTC Error creating local stream: $e');
      onError?.call('Failed to access microphone: $e');
      rethrow;
    }
  }

  Future<RTCSessionDescription> createOffer() async {
    await _createPeerConnection();
    await _createLocalStream();

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    debugPrint('WebRTC: Offer created');
    return offer;
  }

  Future<RTCSessionDescription> createAnswer(RTCSessionDescription offer) async {
    await _createPeerConnection();
    await _createLocalStream();

    await _peerConnection!.setRemoteDescription(offer);
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    debugPrint('WebRTC: Answer created');
    return answer;
  }

  Future<void> setRemoteAnswer(RTCSessionDescription answer) async {
    if (_peerConnection == null) {
      throw Exception('Peer connection not initialized');
    }

    await _peerConnection!.setRemoteDescription(answer);
    debugPrint('WebRTC: Remote answer set');
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    if (_peerConnection == null) {
      debugPrint('WebRTC: Peer connection not ready, queuing ICE candidate');
      return;
    }

    try {
      await _peerConnection!.addCandidate(candidate);
      debugPrint('WebRTC: ICE candidate added');
    } catch (e) {
      debugPrint('WebRTC Error adding ICE candidate: $e');
    }
  }

  Future<void> toggleMute() async {
    if (_localStream == null) return;

    try {
      isMicMuted = !isMicMuted;
      for (var track in _localStream!.getAudioTracks()) {
        track.enabled = !isMicMuted;
      }
      debugPrint('WebRTC: Audio ${isMicMuted ? "muted" : "enabled"}');
    } catch (e) {
      debugPrint('WebRTC Error toggling mute: $e');
      isMicMuted = !isMicMuted;
    }
  }

  Future<void> toggleVideo() async {
    try {
      isVideoEnabled = !isVideoEnabled;

      if (isVideoEnabled) {
        final videoConstraints = {
          'audio': {
            'echoCancellation': true,
            'noiseSuppression': true,
            'autoGainControl': true,
          },
          'video': {
            'facingMode': isFrontCamera ? 'user' : 'environment',
            'width': {'ideal': 1280},
            'height': {'ideal': 720},
            'frameRate': {'ideal': 25},
          },
        };

        if (_localStream != null) {
          for (var track in _localStream!.getVideoTracks()) {
            track.stop();
            _localStream!.removeTrack(track);
          }
        }

        final newStream = await navigator.mediaDevices.getUserMedia(videoConstraints);

        for (var track in newStream.getVideoTracks()) {
          if (_localStream != null) {
            _localStream!.addTrack(track);
          }

          final senders = await _peerConnection?.getSenders();
          final videoSender = senders?.firstWhere(
            (s) => s.track?.kind == 'video',
            orElse: () => senders.first,
          );
          if (videoSender != null) {
            await videoSender.replaceTrack(track);
          } else {
            await _peerConnection?.addTrack(track, _localStream!);
          }
        }

        localRenderer.srcObject = _localStream;
      } else {
        if (_localStream != null) {
          for (var track in _localStream!.getVideoTracks()) {
            track.enabled = false;
            track.stop();

            final senders = await _peerConnection?.getSenders();
            final videoSender = senders?.firstWhere(
              (s) => s.track?.kind == 'video',
              orElse: () => senders.first,
            );
            if (videoSender != null) {
              await videoSender.replaceTrack(null);
            }

            _localStream!.removeTrack(track);
          }
        }
      }

      debugPrint('WebRTC: Video ${isVideoEnabled ? "enabled" : "disabled"}');
    } catch (e) {
      debugPrint('WebRTC Error toggling video: $e');
      isVideoEnabled = !isVideoEnabled;
      rethrow;
    }
  }

  Future<void> switchCamera() async {
    if (!isVideoEnabled || _localStream == null) return;

    try {
      isFrontCamera = !isFrontCamera;

      for (var track in _localStream!.getVideoTracks()) {
        await Helper.switchCamera(track);
      }

      debugPrint('WebRTC: Camera switched to ${isFrontCamera ? "front" : "back"}');
    } catch (e) {
      debugPrint('WebRTC Error switching camera: $e');
      isFrontCamera = !isFrontCamera;
    }
  }

  Future<void> switchSpeaker(bool useSpeaker) async {
    try {
      _isSpeakerOn = useSpeaker;
      await Helper.setSpeakerphoneOn(useSpeaker);
      debugPrint('WebRTC: Speaker ${useSpeaker ? "enabled" : "disabled"}');
    } catch (e) {
      debugPrint('WebRTC Error switching speaker: $e');
      _isSpeakerOn = !useSpeaker;
    }
  }

  bool get isSpeakerOn => _isSpeakerOn;

  void _monitorConnectionQuality() {
    Future.delayed(const Duration(seconds: 2), () async {
      if (_peerConnection == null) return;

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

        _monitorConnectionQuality();
      } catch (e) {
        debugPrint('WebRTC Error monitoring quality: $e');
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
      debugPrint('WebRTC: Call ended');
    } catch (e) {
      debugPrint('WebRTC Error ending call: $e');
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
      await _closePeerConnection();

      await localRenderer.dispose();
      await remoteRenderer.dispose();

      isInitialized = false;
      debugPrint('WebRTC: Service disposed');
    } catch (e) {
      debugPrint('WebRTC Error disposing: $e');
    }
  }
}
