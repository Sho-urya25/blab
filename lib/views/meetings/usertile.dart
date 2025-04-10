import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

class ParticipantTile extends StatefulWidget {
  final Participant participant;
  const ParticipantTile({super.key, required this.participant});

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  //declare stream state
  Stream? videoStream;
  Stream? audioStream;

  @override
  void initState() {
    // initial video stream for the participant
    widget.participant.streams.forEach((key, Stream stream) {
      setState(() {
        if (stream.kind == 'video') {
          videoStream = stream;
        }
      });
    });
    _initStreamListeners();
    super.initState();
  }

  _initStreamListeners() {
    widget.participant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == 'video') {
        setState(() => videoStream = stream);
      } else if (stream.kind == 'audio') {
        setState(() => audioStream = stream);
      }
    });

    widget.participant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == 'video') {
        setState(() => videoStream = null);
      } else if (stream.kind == 'audio') {
        setState(() => audioStream = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (videoStream != null) {
      return RTCVideoView(
        videoStream?.renderer as RTCVideoRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      );
    } else {
      return Text("dbddbdbb");
    }
  }
}
