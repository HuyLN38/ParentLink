import 'dart:async';
import 'dart:io';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:parent_link/api/apis.dart';
import 'package:parent_link/helper/my_date_util.dart';
import 'package:parent_link/model/chat/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:parent_link/pages/message/widgets/chat_message.dart';
import 'package:parent_link/pages/message/widgets/new_message.dart';
import 'package:parent_link/services/webrtc_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/incoming_call.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final WebRTCService _webRTCService = WebRTCService();
  bool _isInCall = false;
  bool _isMicOn = true;
  bool _isCamOn = true;
  bool _isCameraInitialized = false;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  StreamSubscription<QuerySnapshot>? _incomingCallSubscription;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _setupIncomingCallListener();
  }

  void _setupIncomingCallListener() {
    _incomingCallSubscription = FirebaseFirestore.instance
        .collection('calls')
        .where('receiverId', isEqualTo: Apis.me.id)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _handleIncomingCall(change.doc.id, data['callerId']);
        }
      }
    });
  }

  Future<void> _handleIncomingCall(String callId, String callerId) async {
    // Show incoming call dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => IncomingCallDialog(
        callerName: widget.user.name ?? 'Unknown',
        onAccept: () async {
          Navigator.of(context).pop();
          await _acceptIncomingCall(callId);
        },
        onReject: () async {
          Navigator.of(context).pop();
          await _webRTCService.rejectCall(callId);
        },
      ),
    );
  }

  Future<void> _acceptIncomingCall(String callId) async {
    try {
      // Initialize local video first
      await _initLocalVideo();
      if (!_isCameraInitialized) {
        return;
      }

      setState(() => _isInCall = true);

      await _webRTCService.handleIncomingCall(
        callId,
        _localStream!,
        _localRenderer,
        _remoteRenderer,
        onError: (String error) {
          setState(() {
            _isInCall = false;
            _isCameraInitialized = false;
          });
          _localStream?.dispose();
          _localStream = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Call error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
        onCamera: _showCameraRequestDialog,      
      );
    } catch (e) {
      print('Error accepting call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting call: $e')),
      );
    }
  }

  @override
  void dispose() {
    _incomingCallSubscription?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _webRTCService.dispose();
    super.dispose();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _initLocalVideo() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        }
      });

      if (_localStream != null) {
        _localRenderer.srcObject = _localStream;

        setState(() {
          _isCameraInitialized = true;
          _isCamOn = true;
        });
      }
    } catch (e) {
      print('Error initializing local video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing camera: $e')),
      );
    }
  }

  Future<void> _handleCall() async {
    if (!_isInCall) {
      // Initialize local video first
      await _initLocalVideo();
      if (!_isCameraInitialized) {
        return;
      }

      setState(() => _isInCall = true);

      await _webRTCService.initiateCall(
        widget.user.id!,
        _localStream!,
        _localRenderer,
        _remoteRenderer,
        onCallAccepted: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Call connected')),
          );
        },
        onCallRejected: () {
          setState(() {
            _isInCall = false;
            _isCameraInitialized = false;
          });
          _localStream?.dispose();
          _localStream = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Call was rejected')),
          );
        },
        onCallEnded: () {
          setState(() {
            _isInCall = false;
            _isCameraInitialized = false;
          });
          _localStream?.dispose();
          _localStream = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Call ended')),
          );
        },
        onError: (String error) {
          setState(() {
            _isInCall = false;
            _isCameraInitialized = false;
          });
          _localStream?.dispose();
          _localStream = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Call error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } else {
      await _webRTCService.endCall();
      setState(() {
        _isInCall = false;
        _isCameraInitialized = false;
      });
      _localStream?.dispose();
      _localStream = null;
    }
  }

  void _showCameraRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Please turn Camera on'),
        content: const Text('The caller is asking you to allow the camera. Do you agree?'),
        actions: [
          // Refuse button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              print('[Receiver] Camera request refused.');
              // Update status to Firestore
              FirebaseFirestore.instance
                  .collection('calls')
                  .doc(_webRTCService.currentCallId)
                  .update({'camRequest.fromReceiver': false});
            },
            child: const Text('Refuse'),
          ),
          // Accept button
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _webRTCService.enableCamera(); // Turn on camera
              print('[Receiver] Camera enabled.');
              FirebaseFirestore.instance
                  .collection('calls')
                  .doc(_webRTCService.currentCallId)
                  .update({'camRequest.fromReceiver': true});
            },
            child: const Text('Allow'),
          ),
          // Reject call
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              print('[Receiver] Camera request dialog dismissed.');
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }


  void _toggleCam(){
    if(_localStream != null) {
      //get video track from stream
      final videoTrack = _localStream!.getVideoTracks().first;

      //Set state of camera
      videoTrack.enabled = !videoTrack.enabled;
      setState(() {
        _isCamOn = videoTrack.enabled;
      });
      print('[ChatScreen] Camera is ${_isCamOn ? "On" : "Off"}');
    }
  }
  
  void _toggleMic(){
    if(_localStream != null){
      final audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = !audioTrack.enabled;
      setState(() {
        _isMicOn = audioTrack.enabled;
      });
      print('[ChatScreen] Microphone is ${_isMicOn ? "On" : "Off"}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: _appBar(),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ChatMessages(
                  user: widget.user,
                ),
              ),
              NewMessage(
                user: widget.user,
              ),
            ],
          ),
          if (_isInCall) _buildCallOverlay(),
        ],
      ),
    );
  }

  Widget _buildCallOverlay() {
    return Container(
      color: Colors.black87,
      child: Stack(
        children: [
          // Remote Video (Full Screen)
          Positioned.fill(
            child: RTCVideoView(
              _remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
          // Local Video (Picture in Picture)
          Positioned(
            right: 20,
            top: 20,
            width: 120,
            height: 180,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.hardEdge,
              child: RTCVideoView(
                _localRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),
          // Call Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // On/Off micro
                FloatingActionButton(
                  backgroundColor: _isMicOn ? Colors.grey : Colors.red,
                  onPressed: _toggleMic,
                  child: Icon(_isMicOn ? Icons.mic : Icons.mic_off),
                ),
                const SizedBox(width: 20),

                // On/Off camera
                FloatingActionButton(
                  backgroundColor: _isCamOn ? Colors.grey : Colors.red,
                  onPressed: _toggleCam,
                  child: Icon(_isCamOn ? Icons.videocam : Icons.videocam_off),
                ),
                const SizedBox(width: 20),

                // End call
                FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: _handleCall,
                  child: const Icon(Icons.call_end),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: StreamBuilder(
        stream: Apis.getUserInfo(widget.user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;
          final list = data
              .map(
                (e) => ChatUser.fromJson(e.data()),
          )
              .toList();

          final userImage = widget.user.image;

          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),
                CircleAvatar(
                  backgroundImage: userImage != null && userImage.isNotEmpty
                      ? FileImage(File(userImage))
                      : const AssetImage('assets/img/avatar_mom.png')
                  as ImageProvider,
                  child: userImage != null && userImage.isNotEmpty
                      ? null
                      : const Icon(Icons.person_3_sharp),
                ),
                const SizedBox(width: 10),
                Text(
                      widget.user.name ?? 'Unknown User',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline!
                          ? 'Online'
                          : MyDateUtil.getLastActiveTime(
                          context: context,
                          lastActive: list[0].lastActive!)
                          : MyDateUtil.getLastActiveTime(
                          context: context,
                          lastActive: widget.user.lastActive!),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                      ),
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: _handleCall,
                    icon: Icon(
                      _isInCall ? Icons.call_end : Icons.video_call,
                      size: 30,
                      color: _isInCall ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                ]),
          );
        },
      ),
    );
  }
}
