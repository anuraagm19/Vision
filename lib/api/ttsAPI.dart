// import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped }

class ttsAPI {
  late TtsState ttsState;
  var flutterTts = FlutterTts();

  Future init() async {
    ttsState = TtsState.stopped;
    setLanguage();
    double volume = 1.0;
    double pitch = 1.0;
    double rate = 0.75;
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
  }

  Future setLanguage() async{
  await flutterTts.setLanguage("en-US");
  }

  Future speak(String text) async{
    if (text.isNotEmpty) {
      var result = await flutterTts.speak(text);
      if (result == 1) ttsState = TtsState.playing;
    }
  }
  Future stop() async {
    var result = await flutterTts.stop();
    if (result == 1) ttsState = TtsState.stopped;
  }
}
