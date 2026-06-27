// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> downloadCsv(String content) async {
  final blob = html.Blob([content], 'text/csv; charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', 'easy2_solves.csv')
    ..click();
  html.Url.revokeObjectUrl(url);
}
