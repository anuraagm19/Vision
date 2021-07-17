import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clipboard/clipboard.dart';
import '../screens/notes_list.dart';
import '../main.dart';
import '../model/model.dart';
import '../api/googleMLAPI.dart';
import '../api/ttsAPI.dart';


class TextRecognitionWidget extends StatefulWidget {
  const TextRecognitionWidget({
    Key? key,
  }) : super(key: key);

  @override
  _TextRecognitionWidgetState createState() => _TextRecognitionWidgetState();
}

class _TextRecognitionWidgetState extends State<TextRecognitionWidget> {
  String text = '';
  dynamic image;
  late final AudioCache _audioCache;
  late AudioPlayer player;
  @override
  void initState() {
    super.initState();
    _audioCache = AudioCache(
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
          child: Home(text, image),
          onLongPress: saveNote,
          onDoubleTap: () => ttsAPI().speak(text),
          onTap: stop,
          onHorizontalDragUpdate: (details) {
            OpeningNotes();
            if (details.delta.dx > 16) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NoteListPage()),
              );
            } else if (details.delta.dx < -16) pickImage();
          },
          onVerticalDragUpdate: (details) async {
            if (details.delta.dy < -16) {
              HomeInstructions();
            }
          }),
    );
  }

  // Widget buildImage() => Container(
  //       alignment: Alignment.center,
  //       child: image != null
  //           ? Image.file(image)
  //           : Icon(Icons.photo, size: 300, color: Colors.black),
  //     );

  Future pickImage() async {
    await ttsAPI().init();
    OpeningCamera();
    final file = await ImagePicker().getImage(source: ImageSource.camera);
    if (file != null) {
      setImage(File(file.path));
      showDialog(
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
        context: context,
      );
      final text = await googleMLAPI.recogniseText(image);
      setText(text);
      print(text);
      Navigator.of(context).pop();
      ImageCaptured();
    } else {
      print('No image selected.');
      clear();
    }
  }

  Future saveNote() async {
    if (text.isNotEmpty) {
      noteProvider.saveNote(DbNote()..content.v = text);
      _audioCache.play('NoteSaved.mp3');
    } else {
      print("No text");
    }
  }

  Future func() async {
    player = await _audioCache.play("ForInstructions.mp3");
  }

  Future stop() async {
    await ttsAPI().stop();
    player.stop();
  }

  void copyToClipboard() {
    if (text.trim() != '') {
      FlutterClipboard.copy(text);
    }
  }

  Future OpeningNotes() async {
    player = await _audioCache.play("OpeningNotes.mp3");
  }

  Future HomeInstructions() async {
    player = await _audioCache.play("HomeInstructions.mp3");
  }

  Future OpeningCamera() async {
    player = await _audioCache.play("OpeningCamera.mp3");
  }

  Future ImageCaptured() async {
    player = await _audioCache.play("ImageCaptured.mp3");
  }
  // void playInstructions(){
  //   cache.play("instructions.mp3");
  //   print("aaa");
  //   // cacheState=CacheState.stopped;
  // }

  void setImage(dynamic newImage) {
    setState(() {
      image = newImage;
    });
  }

  void setText(String newText) {
    setState(() {
      text = newText;
    });
  }

  void clear() {
    setImage(null);
    setText('');
  }
}

class Home extends StatelessWidget {
  final String text;
  dynamic image;
  Home(this.text, this.image);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            image != null
                ? Image.file(image, height: 300, width: 300, fit: BoxFit.cover)
                : Icon(Icons.photo, size: 300, color: Colors.black),
            const SizedBox(
              height: 30,
            ),
            ListTile(
              title: new Center(child: Text('Scanned Text\n')),
              subtitle: Text(
                text != null ? text : 'No text detected',
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
                maxLines: 15,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
