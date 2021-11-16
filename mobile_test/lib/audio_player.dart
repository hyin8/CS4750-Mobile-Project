import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioPlayer{

  FlutterSoundPlayer? _player;
  bool _isPlayerInit = false;
  bool isPlaying = false;
  bool isPaused = false;

  Future init() async{
    _player = FlutterSoundPlayer();
    await _player!.openAudioSession();
    _isPlayerInit = true;
  }

  void dispose() async{
    _player!.closeAudioSession();
    _player = null;
    _isPlayerInit = false;
  }

  Future playAudio(String? path) async{
    if(!_isPlayerInit) return;
    _player!.startPlayer(fromURI: path);
    isPlaying = true;

  }
  Future pauseAudio() async{
    if(!_isPlayerInit) return;
    await _player!.pausePlayer();
    isPaused = true;
  }
  Future resumePlayer() async{
    if(!_isPlayerInit) return;
    await _player!.resumePlayer();
    isPaused = false;
  }
  Future stopAudio() async{
    if(!_isPlayerInit) return;
    await _player!.stopPlayer();
    isPlaying = false;
    isPaused = false;

  }


}