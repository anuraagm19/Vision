
import 'package:flutter/material.dart';
import './providers/note_provider.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';
import './widget/textRecongnitionWidget.dart';
import 'package:audioplayers/audioplayers.dart';

late DbNoteProvider noteProvider;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  platformInit();
  
  var packageName = 'com.example.myboi';

  var databaseFactory = getDatabaseFactory(packageName: packageName);

  noteProvider = DbNoteProvider(databaseFactory);
  // devPrint('/notepad Starting');
  await noteProvider.ready;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String title = 'Text Recognition';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(primaryColor: Colors.lightBlueAccent),
        home: MainPage(title: title),
      );
}

class MainPage extends StatefulWidget {
  final String title;

  const MainPage({
    required this.title,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  late final AudioCache _audioCache;
  late AudioPlayer player;
  @override
  void initState() {
    ForInstructions(context);
    super.initState();
    _audioCache = AudioCache(
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );
  }
 Future ForInstructions(BuildContext context) async {
   await Future.delayed(Duration(seconds: 1));
   player = await _audioCache.play('ForInstructions.mp3');
 }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
          
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const SizedBox(height: 15),
              TextRecognitionWidget(),
              const SizedBox(height: 15),
            ],
          ),
        ),
      );
}
