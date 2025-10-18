import 'package:flutter/widgets.dart';

class LRCLine {
  final Duration timestamp;
  final String text;
  LRCLine({required this.timestamp, required this.text});
}

List<LRCLine> toLRCLineList(String lrcString) {
  final regex = RegExp(r'\[(\d{2}):(\d{2})(?:\.(\d{2,3}))?\](.*)');
  final lines = lrcString
      .split('\n')
      .where((line) => line.isNotEmpty)
      .map((line) {
        final match = regex.firstMatch(line);
        if (match != null) {
          final minutes = int.parse(match.group(1)!);
          final seconds = int.parse(match.group(2)!);
          final millis = match.group(3) != null
              ? int.parse(match.group(3)!.padRight(3, '0'))
              : 0;
          var text = match.group(4)!.trim();

          if (text == "") {
            text = "♫";
          }
          return LRCLine(
            timestamp: Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: millis,
            ),
            text: text,
          );
        }
        return null;
      })
      .whereType<LRCLine>()
      .toList();

  lines.insert(0, LRCLine(timestamp: Duration.zero, text: ""));

  return lines;
}

/// Format to standard LRC string
String toLRCString(List<LRCLine> lines) {
  String two(int n) => n.toString().padLeft(2, '0');
  String three(int n) => n.toString().padLeft(3, '0');
  return lines
      .map((l) {
        final m = l.timestamp.inMinutes;
        final s = l.timestamp.inSeconds % 60;
        final ms = l.timestamp.inMilliseconds % 1000;
        return '[${two(m)}:${two(s)}.${three(ms)}]${l.text}';
      })
      .join('\n');
}



extension LRCSpans on List<LRCLine> {
  toSpans() {
    List<TextSpan> spans = [];

    for (var element in this) {
      spans.add(TextSpan(text: " ${element.text}."));
    }

    return spans;
  }
}
