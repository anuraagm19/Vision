import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import '../main.dart';
import '../model/model.dart';
import '../api/ttsAPI.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:audioplayers/audioplayers.dart';

// import 'package:tekartik_notepad_sqflite_app/page/edit_page.dart';
// import 'package:tekartik_notepad_sqflite_app/page/note_page.dart';
// import 'package:tekartik_common_utils/common_utils_import.dart';

class NoteListPage extends StatefulWidget {
  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
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
    // print("Back To old Screen");
    ttsAPI().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
          title: Text(
        'Saved Notes',
      )),
      body: StreamBuilder<List<DbNote?>>(
        stream: noteProvider.onNotes(),
        builder: (context, snapshot) {
          var notes = snapshot.data;
          if (notes == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          ttsAPI().init();
          return Container(
              child: Padding(
                  padding: new EdgeInsets.all(10.0),
                  child: CarouselSlider(
                    items: notes
                        .map((item) => Container(
                              // height: 800,
                              child: Center(
                                child: GestureDetector(
                                    onDoubleTap: () => ttsAPI()
                                        .speak(item!.content.toString()),
                                    onTap: stop,
                                    onLongPress: () {
                                      NoteDeleted();
                                      delete(item);
                                    },
                                    onVerticalDragUpdate: (details) {
                                      if (details.delta.dy > 16) {
                                        CopiedToClipboard();
                                        copyToClipboard(
                                            item!.content.toString());
                                      }
                                      if (details.delta.dy < -16) {
                                        NotesInstructions();
                                      }
                                    },
                                    child: NoteCard(item!.content.toString())),
                              ),
                            ))
                        .toList(),
                    options: CarouselOptions(
                      height: 800,
                      viewportFraction: 0.9,
                      enableInfiniteScroll: false,
                    ),
                  )));
        },
      ),
    );
  }

  Future stop() async {
    await ttsAPI().stop();
    player.stop();
  }

  Future CopiedToClipboard() async {
    player = await _audioCache.play("CopiedToClipboard.mp3");
  }

  Future NoteDeleted() async {
    player = await _audioCache.play("NoteDeleted.mp3");
  }

  Future NotesInstructions() async {
    player = await _audioCache.play("NotesInstructions.mp3");
  }
}

class NoteCard extends StatelessWidget {
  final String text;
  NoteCard(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 400,
        child: Card(
          // color: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 30.0, bottom: 30, left: 30.0, right: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _NoteText(text),
              ],
            ),
          ),
        ));
  }
}

class _NoteText extends StatelessWidget {
  final String _text;

  _NoteText(this._text);

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: Text(
      _text,
      style: TextStyle(color: Colors.grey.shade600),
      maxLines: 40,
      overflow: TextOverflow.ellipsis,
    ));
  }
}

void copyToClipboard(String text) {
  if (text.trim() != '') {
    FlutterClipboard.copy(text);
  }
}

Future delete(DbNote? item) async {
  await noteProvider.deleteNote(item!.id.v);
  // print('neee');
}


// Future _onTapHandler(DbNote note) async {
//   // HapticFeedback.heavyImpact();
//   await ttsAPI().speak((note.content.v ?? '').toString());
// }
