import 'package:flutter/widgets.dart';

class LRCLine {
  final Duration timestamp;
  final String text;
  LRCLine({required this.timestamp, required this.text});
}

const musicNoteString = "♫";
List<LRCLine> toLRCLineList(String lrcString, [String gapstring = ""]) {
  final regex = RegExp(r'\[(\d{2}):(\d{2})(?:\.(\d{2}))?\](.*)');
  final lines = lrcString
      .split('\n')
      .where((line) => line.isNotEmpty)
      .map((line) {
        final match = regex.firstMatch(line);
        if (match != null) {
          final minutes = int.parse(match.group(1)!);
          final seconds = int.parse(match.group(2)!);
          final millis = match.group(3) != null
              ? int.parse(match.group(3)!.padRight(2, '0'))
              : 0;
          var text = match.group(4)!.trim();

          if (text == "") {
            text = gapstring;
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

  if ((lines.firstOrNull?.timestamp ?? Duration(seconds: 1)) != Duration.zero) {
    lines.insert(0, LRCLine(timestamp: Duration.zero, text: ""));
  }

  return lines;
}

extension LRCSpans on List<LRCLine> {
  toSpans() {
    List<TextSpan> spans = [];

    for (var element in this) {
      spans.add(TextSpan(text: " ${element.text}."));
    }

    return spans;
  }

  String toPlainText() {
    this;
    return map((e) => e.text).join("\n");
  }

  List<LRCLine> remapPlainText(String text2) {
    final newPlaintext = text2.split("\n");

    List<LRCLine> lines = [];
    Duration lastduration = Duration.zero;
    for (var i = 0; i < newPlaintext.length; i++) {
      final npt = newPlaintext[i].trim();
      if (length - 1 < i) {
        lines.add(
          LRCLine(
            timestamp: lastduration + Duration(milliseconds: i),
            text: npt,
          ),
        );
      } else {
        lines.add(LRCLine(timestamp: this[i].timestamp, text: npt));
      }
    }

    return lines;
  }

  String toLRCString() {
    String two(int n) => n.toString().padLeft(2, '0');
    return map((l) {
      final m = l.timestamp.inMinutes;
      final s = l.timestamp.inSeconds % 60;
      final ms = l.timestamp.inMilliseconds % 100;
      return '[${two(m)}:${two(s)}.${two(ms)}] ${l.text}';
    }).join('\n');
  }

  bool validate() {
    try {
      if (isEmpty) return false;
      if (this[1].text == "") return false;
      if (last.text != "") return false;
    } catch (e) {
      return false;
    }

    return true;
  }
}
