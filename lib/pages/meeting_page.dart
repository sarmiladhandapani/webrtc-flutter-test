import 'package:flutter/material.dart';
import 'package:flutter_webrtc_wrapper/flutter_webrtc_wrapper.dart';
import 'package:webrtc_test/models/meeting_details.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_test/pages/home_screen.dart';
import 'package:webrtc_test/utils/user.utils.dart';
import 'package:webrtc_test/widgets/control_panel.dart';
import 'package:webrtc_test/widgets/remote_connection.dart';

class MeetingPage extends StatefulWidget {
  final String? meetingId;
  final String? name;
  final MeetingDetail meetingDetail;
  const MeetingPage(
      {required this.meetingDetail, this.meetingId, this.name, Key? key})
      : super(key: key);

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final Map<String, dynamic> mediaConstraints = {'audio': true, 'video': true};
  bool isConnectionFailed = false;
  WebRTCMeetingHelper? meetingHelper;
  late RTCPeerConnection _peerConnection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: buildMeetingRoom(),
      bottomNavigationBar: ControlPanel(
        onAudioToggle: onAudioToggle,
        onVideoToggle: onVideoToggle,
        videoEnabled: isVideoEnabled(),
        audioEnabled: isAudioEnabled(),
        isConnectionFailed: isConnectionFailed,
        onReconnect: handleReconnect,
        onMeetingEnd: onMeetingEnd,
      ),
    );
  }

  void startMeeting() async {
    final String userId = await loadUserId();

    print('-------------------------');
    print(widget.meetingDetail.id);
    meetingHelper = WebRTCMeetingHelper(
      url: 'http://192.168.1.5:4000',
      meetingId: widget.meetingDetail.id,
      userId: userId,
      name: widget.name,
    );

    MediaStream _localStream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = _localStream;
    meetingHelper!.stream = _localStream;

    meetingHelper!.on('open', context, (ev, context) {
      print('--------=============================OPEN');
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on('connection', context, (ev, context) {
      print('--------=============================CONNECTION');
      print('--------=============================$ev');
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on('user-left', context, (ev, context) {
      print('--------=============================LEFT');
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on('video-toggle', context, (ev, context) {
      print('--------=============================VTOG');
      setState(() {});
    });
    meetingHelper!.on('audio-toggle', context, (ev, context) {
      print('--------=============================ATOG');
      setState(() {});
    });
    meetingHelper!.on('meeting-ended', context, (ev, context) {
      print('--------=============================END');
      onMeetingEnd();
    });
    meetingHelper!.on('candidate', context, (ev, context) {
      print('--------=============================CANDIDATE');
    });
    meetingHelper!.on('connection-setting-changed', context, (ev, context) {
      print('--------=============================CON_SET_CH');
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on('stream-changed', context, (ev, context) {
      print('--------=============================STR_CH');
      setState(() {
        isConnectionFailed = false;
      });
    });
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    _initializePeerConnection();
  }

  void _initializePeerConnection() async {
    _peerConnection = await createPeerConnection({});
    // Get access to the camera and microphone
    final mediaStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'facingMode': 'user', // use the front-facing camera
      }
    });

    mediaStream.getTracks().forEach((track) {
      _peerConnection.addTrack(track, mediaStream);
    });
    _localRenderer.srcObject = mediaStream;

    // Set up the remote video renderer
    _peerConnection.onTrack = (event) {
      print('----------------------------------ENET $event');
      if (event.track.kind == 'video') {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    final offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);

  }

  @override
  void initState() {
    initRenderers();

    startMeeting();
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
    _localRenderer.dispose();
    _peerConnection.dispose();
    _remoteRenderer.dispose();
    if (meetingHelper != null) {
      meetingHelper!.destroy();
      meetingHelper = null;
    }
  }

  void onMeetingEnd() {
    if (meetingHelper != null) {
      meetingHelper!.endMeeting();
      meetingHelper = null;
      goToHomePage();
    }
  }

  void onAudioToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleAudio();
      });
    }
  }

  void onVideoToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleVideo();
      });
    }
  }

  void handleReconnect() {
    if (meetingHelper != null) {
      meetingHelper!.reconnect();
    }
  }

  bool isVideoEnabled() {
    return meetingHelper?.videoEnabled ?? false;
  }

  bool isAudioEnabled() {
    return meetingHelper?.audioEnabled ?? false;
  }

  void goToHomePage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  Widget buildMeetingRoom() {
    return Stack(
      children: [
        // meetingHelper != null && meetingHelper!.connections.isNotEmpty
        //     ? GridView.count(
        //         crossAxisCount: meetingHelper!.connections.length,
        //         children:
        //             List.generate(meetingHelper!.connections.length, (index) {
        //           return Padding(
        //             padding: const EdgeInsets.all(1),
        //             child: RemoteConnection(
        //               renderer: meetingHelper!.connections[index].renderer,
        //               connection: meetingHelper!.connections[index],
        //             ),
        //           );
        //         }),
        //       )
        // true
        //     ? Positioned(
        //         bottom: 10,
        //         right: 0,
        //         child: SizedBox(
        //           width: 150,
        //           height: 200,
        //           child: RTCVideoView(_remoteRenderer),
        //         ),
        //       )
        //     : const Center(
        //         child: Padding(
        //           padding: EdgeInsets.all(10),
        //           child: Text(
        //             'Waiting for participants to join the meeting',
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //               color: Colors.grey,
        //               fontSize: 24,
        //             ),
        //           ),
        //         ),
        //       ),
        // Positioned(
        //   bottom: 10,
        //   right: 0,
        //   child: SizedBox(
        //     width: 150,
        //     height: 200,
        //     child: RTCVideoView(_localRenderer),
        //   ),
        // ),
        RTCVideoView(
          _localRenderer,
          mirror: true,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        ),
        RTCVideoView(_remoteRenderer),
      ],
    );
  }
}
