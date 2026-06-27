import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadCsv(String content) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/easy2_solves.csv');
  await file.writeAsString(content);
  if (Platform.isAndroid || Platform.isIOS) {
    await Share.shareXFiles([XFile(file.path)]);
  } else if (Platform.isLinux) {
    await Process.run('xdg-open', [dir.path]);
  } else if (Platform.isMacOS) {
    await Process.run('open', [dir.path]);
  } else if (Platform.isWindows) {
    await Process.run('explorer', [dir.path]);
  }
}
