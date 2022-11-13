import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioPlayer player = AudioPlayer();
  PlayerState playerState = PlayerState.paused;
  String playerSource =
      "https://soundcloud.com/fm_freemusic/lounge-ambient-chillout-music-background-music-for-calm-mind-and-relaxation?utm_source=clipboard&utm_medium=text&utm_campaign=social_sharing";

  @override
  void initState() {
    super.initState();

    player.onPlayerStateChanged.listen((PlayerState p) {
      setState(() {
        playerState = p;
      });
      print("Player state is $playerState");
    });
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
    player.dispose();
  }

  playMusic() async {
    print("yaha");
    await player.play(AssetSource(playerSource));
  }

  pauseMusic() async {
    await player.pause();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  playerSource = "audio/cow.mp3";

                  playerState == PlayerState.playing
                      ? pauseMusic()
                      : playMusic();
                },
                child: Text('Cow'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  playerSource = "audio/horse.mp3";

                  playerState == PlayerState.playing
                      ? pauseMusic()
                      : playMusic();
                },
                child: Text('Horse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
