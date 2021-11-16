import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class SoundRecorder{
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInit = false;
  bool get isRecording => _audioRecorder!.isRecording;
  final name = 'audio.aac';
  String? url;

  Future init() async{
    _audioRecorder = FlutterSoundRecorder();

    final status = await Permission.microphone.request();
    if(status != PermissionStatus.granted){
      throw RecordingPermissionException("Microphone permission Denied");
    }
    await _audioRecorder!.openAudioSession();
    _isRecorderInit = true;

  }

  void dispose(){
    _audioRecorder!.closeAudioSession();
    _audioRecorder = null;
    _isRecorderInit =false;
  }

  Future _record() async {
    if(!_isRecorderInit) return;

    //final directory = await getApplicationDocumentsDirectory();
    final directory = await getApplicationDocumentsDirectory();
    String savePath = '${directory.path}/' + name;

    print("Save Path: " + savePath);

    await _audioRecorder!.startRecorder(toFile: savePath);
  }
  Future _stop() async{
    if(!_isRecorderInit) return;
    url = await _audioRecorder!.stopRecorder();
  }
  Future toggleRecording() async{
    if (_audioRecorder!.isStopped){
      await _record();
    }
    else{
      await _stop();
    }
  }
  String? getURL(){
    return url;
  }

}