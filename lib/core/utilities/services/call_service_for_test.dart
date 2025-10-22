/*
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class CallServiceForTest {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  String? currentRoomId;
  StreamSubscription? _roomSubscription;
  StreamSubscription? _callerCandidatesSubscription;
  StreamSubscription? _calleeCandidatesSubscription;

  Function(MediaStream)? onLocalStream;
  Function(MediaStream)? onRemoteStream;
  Function(String)? onError;

  final List<RTCIceCandidate> _pendingCandidates = [];
  bool _remoteDescriptionSet = false;

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun.l.google.com:19302',
          'stun:stun1.l.google.com:19302',
          'stun:stun.relay.metered.ca:80',
        ],
      },
      {
        'urls': [
          'turn:standard.relay.metered.ca:80',
          'turn:standard.relay.metered.ca:80?transport=tcp',
          'turn:standard.relay.metered.ca:443',
          'turn:standard.relay.metered.ca:443?transport=tcp',
        ],
        'username': '55975721735727cc6803f58b',
        'credential': 'JbOVdGZF82HK/EyM',
      },
    ],
    'sdpSemantics': 'unified-plan',
    'iceCandidatePoolSize': 5,
  };

  final Map<String, dynamic> _offerConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': false, // ✅ إلغاء الفيديو
    },
    'optional': [],
  };

  // ✅ صوت فقط - بدون فيديو
  final Map<String, dynamic> _mediaConstraints = {
    'audio': {
      'echoCancellation': true,
      'noiseSuppression': true,
      'autoGainControl': true,
      'sampleRate': 8000,  // ✅ جودة تليفون عادي (يوفر 80%)
      'channelCount': 1,
    },
    'video': false, // ✅ إلغاء الفيديو تماماً
  };

  Future<String> createRoom() async {
    try {
      debugPrint('🚀 بدء إنشاء الغرفة...');
      await _initializeMedia();

      final roomRef = _firestore.collection('rooms').doc();
      currentRoomId = roomRef.id;
      debugPrint('📝 Room ID: $currentRoomId');

      _peerConnection = await createPeerConnection(_configuration);
      _registerPeerConnectionListeners();

      // إضافة الـ tracks
      for (var track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
        debugPrint('✅ Track added: ${track.kind}');
      }

      // معالجة ICE candidates
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) async {
        if (candidate.candidate != null) {
          debugPrint('❄️ Caller ICE Candidate: ${candidate.candidate}');
          try {
            await roomRef.collection('callerCandidates').add(candidate.toMap());
          } catch (e) {
            debugPrint('⚠️ خطأ في إضافة candidate: $e');
          }
        }
      };

      // إنشاء offer
      RTCSessionDescription offer = await _peerConnection!.createOffer(_offerConstraints);
      await _peerConnection!.setLocalDescription(offer);
      debugPrint('✅ Local Description Set (Offer)');

      await roomRef.set({
        'offer': {'type': offer.type, 'sdp': offer.sdp},
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Offer تم حفظه في Firestore');

      // استماع للـ answer
      _roomSubscription = roomRef.snapshots().listen((snapshot) async {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data() as Map<String, dynamic>;

          if (data['answer'] != null && !_remoteDescriptionSet) {
            debugPrint('📥 Answer received');
            try {
              final answer = RTCSessionDescription(
                data['answer']['sdp'],
                data['answer']['type'],
              );
              await _peerConnection!.setRemoteDescription(answer);
              _remoteDescriptionSet = true;
              debugPrint('✅ Remote Description Set (Answer)');

              await _addPendingCandidates();
            } catch (e) {
              debugPrint('❌ خطأ في setRemoteDescription: $e');
              onError?.call('خطأ في الاتصال: $e');
            }
          }
        }
      });

      // استقبال ICE candidates من الطرف الثاني
      _calleeCandidatesSubscription = roomRef
          .collection('calleeCandidates')
          .snapshots()
          .listen((snapshot) async {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data()!;
            final candidate = RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            );

            debugPrint('❄️ Callee ICE Candidate received');

            if (_remoteDescriptionSet) {
              try {
                await _peerConnection!.addCandidate(candidate);
                debugPrint('✅ Candidate added');
              } catch (e) {
                debugPrint('⚠️ خطأ في addCandidate: $e');
              }
            } else {
              _pendingCandidates.add(candidate);
              debugPrint('⏳ Candidate في الانتظار');
            }
          }
        }
      });

      return roomRef.id;
    } catch (e) {
      debugPrint('❌ خطأ في createRoom: $e');
      onError?.call('خطأ أثناء إنشاء الغرفة: $e');
      rethrow;
    }
  }

  Future<void> joinRoom(String roomId) async {
    try {
      debugPrint('🚀 بدء الانضمام للغرفة: $roomId');
      await _initializeMedia();
      currentRoomId = roomId;

      final roomRef = _firestore.collection('rooms').doc(roomId);
      final roomSnapshot = await roomRef.get();

      if (!roomSnapshot.exists) {
        throw Exception('الغرفة غير موجودة');
      }

      final data = roomSnapshot.data() as Map<String, dynamic>;

      if (data['offer'] == null) {
        throw Exception('لا يوجد Offer في الغرفة');
      }

      _peerConnection = await createPeerConnection(_configuration);
      _registerPeerConnectionListeners();

      // إضافة الـ tracks
      for (var track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
        debugPrint('✅ Track added: ${track.kind}');
      }

      // معالجة ICE candidates
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) async {
        if (candidate.candidate != null) {
          debugPrint('❄️ Callee ICE Candidate: ${candidate.candidate}');
          try {
            await roomRef.collection('calleeCandidates').add(candidate.toMap());
          } catch (e) {
            debugPrint('⚠️ خطأ في إضافة candidate: $e');
          }
        }
      };

      // تعيين Remote Description أولاً
      debugPrint('📥 Setting Remote Description (Offer)');
      final offer = RTCSessionDescription(
        data['offer']['sdp'],
        data['offer']['type'],
      );
      await _peerConnection!.setRemoteDescription(offer);
      _remoteDescriptionSet = true;
      debugPrint('✅ Remote Description Set');

      // إنشاء answer
      final answer = await _peerConnection!.createAnswer(_offerConstraints);
      await _peerConnection!.setLocalDescription(answer);
      debugPrint('✅ Local Description Set (Answer)');

      await roomRef.update({
        'answer': {'type': answer.type, 'sdp': answer.sdp},
      });
      debugPrint('✅ Answer تم حفظه في Firestore');

      // استقبال ICE candidates من المتصل
      _callerCandidatesSubscription = roomRef
          .collection('callerCandidates')
          .snapshots()
          .listen((snapshot) async {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data()!;
            final candidate = RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            );

            debugPrint('❄️ Caller ICE Candidate received');

            if (_remoteDescriptionSet) {
              try {
                await _peerConnection!.addCandidate(candidate);
                debugPrint('✅ Candidate added');
              } catch (e) {
                debugPrint('⚠️ خطأ في addCandidate: $e');
              }
            } else {
              _pendingCandidates.add(candidate);
              debugPrint('⏳ Candidate في الانتظار');
            }
          }
        }
      });

      await _addPendingCandidates();

    } catch (e) {
      debugPrint('❌ خطأ في joinRoom: $e');
      onError?.call('خطأ أثناء الانضمام: $e');
      rethrow;
    }
  }

  Future<void> _addPendingCandidates() async {
    if (_pendingCandidates.isNotEmpty && _remoteDescriptionSet) {
      debugPrint('🔄 إضافة ${_pendingCandidates.length} pending candidates');
      for (var candidate in _pendingCandidates) {
        try {
          await _peerConnection!.addCandidate(candidate);
        } catch (e) {
          debugPrint('⚠️ خطأ في addCandidate: $e');
        }
      }
      _pendingCandidates.clear();
      debugPrint('✅ تم إضافة جميع pending candidates');
    }
  }

  Future<void> _initializeMedia() async {
    try {
      debugPrint('🎙️ طلب أذونات الصوت...');
      _localStream = await navigator.mediaDevices.getUserMedia(_mediaConstraints);
      debugPrint('✅ تم الحصول على الصوت');
      onLocalStream?.call(_localStream!);
    } catch (e) {
      debugPrint('❌ فشل الحصول على الصوت: $e');
      onError?.call('فشل الحصول على الصوت: $e');
      rethrow;
    }
  }

  void _registerPeerConnectionListeners() {
    _peerConnection?.onTrack = (event) {
      debugPrint('🎙️ Track received: ${event.track.kind}');
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams.first;
        onRemoteStream?.call(_remoteStream!);
        debugPrint('✅ Remote stream connected');
      }
    };

    _peerConnection?.onIceConnectionState = (state) {
      debugPrint('❄️ ICE Connection State: $state');

      switch (state) {
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
          debugPrint('✅ الاتصال نجح!');
          break;
        case RTCIceConnectionState.RTCIceConnectionStateCompleted:
          debugPrint('✅ الاتصال مكتمل!');
          break;
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          debugPrint('❌ فشل الاتصال');
          onError?.call('فشل الاتصال - تحقق من الشبكة أو إعدادات TURN');
          break;
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
          debugPrint('⚠️ الاتصال انقطع');
          break;
        default:
          break;
      }
    };

    _peerConnection?.onConnectionState = (state) {
      debugPrint('🔌 Connection State: $state');
    };

    _peerConnection?.onIceGatheringState = (state) {
      debugPrint('🧊 ICE Gathering State: $state');
    };

    _peerConnection?.onSignalingState = (state) {
      debugPrint('📡 Signaling State: $state');
    };
  }

  Future<void> hangUp() async {
    debugPrint('📴 إنهاء المكالمة...');

    await _roomSubscription?.cancel();
    await _callerCandidatesSubscription?.cancel();
    await _calleeCandidatesSubscription?.cancel();

    _localStream?.getTracks().forEach((t) => t.stop());
    _remoteStream?.getTracks().forEach((t) => t.stop());
    await _peerConnection?.close();

    if (currentRoomId != null) {
      try {
        final ref = _firestore.collection('rooms').doc(currentRoomId);

        final callerCandidates = await ref.collection('callerCandidates').get();
        for (var doc in callerCandidates.docs) {
          await doc.reference.delete();
        }

        final calleeCandidates = await ref.collection('calleeCandidates').get();
        for (var doc in calleeCandidates.docs) {
          await doc.reference.delete();
        }

        await ref.delete();
        debugPrint('✅ تم حذف الغرفة');
      } catch (e) {
        debugPrint('⚠️ خطأ في حذف الغرفة: $e');
      }
      currentRoomId = null;
    }

    _pendingCandidates.clear();
    _remoteDescriptionSet = false;
  }

  void toggleAudio() {
    if (_localStream != null) {
      final audio = _localStream!.getAudioTracks().first;
      audio.enabled = !audio.enabled;
    }
  }

  bool get isAudioEnabled =>
      _localStream?.getAudioTracks().first.enabled ?? true;
}*/
