import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:mobile_test/audio_player.dart';
import 'package:path/path.dart';
import 'util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'sound_recorder.dart';

class SoundBoard extends StatefulWidget {
  const SoundBoard({Key? key}) : super(key: key);

  @override
  _SoundBoardState createState() => _SoundBoardState();
}

class _SoundBoardState extends State<SoundBoard>{
  // -----Object and Variable declaration-----
  List<String> _files = <String>[];
  //Recorder
  final recorder = SoundRecorder();
  //Player
  final player = AudioPlayer();
  //Timer
  Duration duration = Duration();
  Timer? timer;

  //Style settings
  final padStyle = EdgeInsets.all(10);
  final themeColor = Colors.lightBlue;
  final secondThemeColor = Colors.pinkAccent;
  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    backgroundColor: Colors.lightBlue,
    primary: Colors.black87,
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );
  final ButtonStyle elevatedStyle = ElevatedButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
    minimumSize: Size(175,50),
    primary: Colors.white,
    onPrimary: Colors.black,
  );

  // -----End-----

  // -----Overrides-----
  @override
  void initState(){
    super.initState();
    recorder.init();
    player.init();
    initApp();
  }
  @override
  void dispose(){
    recorder.dispose();
    player.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    saveApp();

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("SoundCord"),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              //isScrollable: true,
              tabs: <Widget>[
                Tab(
                    icon: Icon(Icons.apps),
                    text: "Board"
                ),
                Tab(
                    icon: Icon(Icons.audiotrack),
                    text: "Audio Record"
                )
              ],
            ),
          ),
          body: TabBarView(children: [
            buildBoard(context),
            buildAudioRecorder()
          ],
          ),
        )
    );
  }
  // -----End-----



  // -----Custom Widgets-----
  Widget buildAudioRecorder() {
    final isRecording = recorder.isRecording;
    final icon = isRecording ? Icons.stop : Icons.mic;
    final text = isRecording ? 'STOP' : 'START';
    final primary = isRecording ? Colors.red : Colors.white;
    final onPrimary = isRecording ? Colors.white : Colors.black;
    return  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: padStyle,
              decoration: BoxDecoration(
                color:Colors.red,
                borderRadius: BorderRadius.circular(20)
              ),
              width: 150,
              height: 150,
              margin: EdgeInsets.all(10),
              child: Center(child: buildTime()),
            ),
            Container(
              padding: padStyle,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(175,50),
                  primary: primary,
                  onPrimary: onPrimary,
                ),
                icon: Icon(icon),
                label: Text(text),
                onPressed: () async {
                  final isRecording = await recorder.toggleRecording();
                  if(recorder.isRecording){
                    startTimer();
                  }
                  else{
                    stopTimer();
                  }
                  setState(() {});
                },
              ),
            ),
            Container(
              padding: padStyle,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(175,50),
                  primary: Colors.white,
                ),
                icon: Icon(Icons.play_arrow),
                label: Text("Play"),
                onPressed: () async{
                  if(!recorder.isRecording){
                    player.playAudio(recorder.getURL());
                  }
                },
              ),
            )
          ],
        )

    );
  }

  Widget buildBoard(BuildContext context) {
    int curIndex = 0;
    return Scaffold(
      body: ListView.builder(
          itemCount: _files.length,
          itemBuilder: (BuildContext context, int index){
      return ListTile(
        onTap: (){
          if(!player.isPlaying){
            curIndex = index;
          }
          else if(player.isPlaying & (curIndex != index)){
            player.stopAudio();
            return;
          }
          if(!player.isPlaying){
            player.playAudio(_files[index]);
          }
          else if(player.isPlaying & !player.isPaused){
            player.pauseAudio();
          }
          else if(player.isPlaying & player.isPaused){
            player.resumePlayer();
          }
        },
        leading: IconButton(
          icon: Icon(Icons.cancel),
          onPressed: (){
            _files.removeAt(index);
            if(player.isPlaying){
              player.stopAudio();
            }
            setState(() {

            });
          },
        ),
        title: Container(
          height: 50,
          margin: EdgeInsets.only(top: 5, bottom: 5),
          child: Row(
            children: [
              Container(
                  margin: EdgeInsets.only(right:20),
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/sound.jpg'),
                  )
              ),
              Flexible(
                  child: Container(
                    padding: padStyle,
                    child: Text(
                      basename(_files[index]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
              )

            ],
          ),
        ),
        trailing: IconButton(
            icon: Icon(Icons.stop),
            onPressed: (){
                if(player.isPlaying){
                  player.stopAudio();
                }
            },
        )
      );

      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.audio
          );
          if(result != null){
            //File file = File(result.files.single.path!);
            _files.add(result.files.single.path!);
            //final savedFile = await saveFilePermanently(result.files.first);
            //print(savedFile.path);
          }else{

          }
          setState(() {});
        },
        tooltip: 'Add file',
        child: Icon(Icons.add),
      )
    );

  }
  Widget buildPage(String text) {
    return Center(
        child:Text(text)
    );
  }

  Widget buildTime(){
    String twoDigits(int n) => n.toString().padLeft(2,'0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    return Text(
      '$hours:$minutes:$seconds',
      style: TextStyle(fontSize: 30),
    );
  }

  // -----End-----

  // -----Custom Functions-----
  void initApp() async {
    final pref = await SharedPreferences.getInstance();
    _files = (pref.getStringList("files") ?? []);
    setState(() {

    });
  }
  void saveApp() async{
    final pref = await SharedPreferences.getInstance();
    pref.setStringList("files", _files);
  }
  void addTime(){
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
  }
  void stopTimer(){
    setState(() {
      duration = Duration(seconds: 0);
      timer?.cancel();
    });
  }
  void startTimer(){
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }
  // -----End-----

}
