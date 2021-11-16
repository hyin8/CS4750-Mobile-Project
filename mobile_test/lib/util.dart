import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<File> saveFilePermanently(PlatformFile file) async{
  final appStorage = await getApplicationDocumentsDirectory();
  final newFile = File('${appStorage.path}/${file.name}');
  return File(file.path!).copy(newFile.path);
}