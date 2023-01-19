import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:unige_app/screens/ApplicationData.dart';
import 'package:video_player/video_player.dart';

class VideoItems extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool looping;
  final bool autoplay;

  VideoItems({
    required this.videoPlayerController,
    required this.looping,
    required this.autoplay,
  });

  @override
  _VideoItemsState createState() => _VideoItemsState();
}

class _VideoItemsState extends State<VideoItems> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      autoInitialize: true,
      fullScreenByDefault: true,
      allowFullScreen: false,
      showControls: true,
      autoPlay: widget.autoplay,
      aspectRatio:
          ApplicationData.getScreenHeight() / ApplicationData.getScreenWidth(),
      looping: widget.looping,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _chewieController.dispose();
  }

  double videoContainerRatio = 0.5;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => disposeController(),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Chewie(
          controller: _chewieController,
        ),
      ),
    );
  }

  disposeController() {
    Navigator.pop(context);
    widget.videoPlayerController.dispose();
    dispose();
  }
}
