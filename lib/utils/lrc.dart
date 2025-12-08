import 'package:flutter/widgets.dart';

class Line {
  get text => null;
}

class LRCLine implements Line {
  final Duration timestamp;
  @override
  final String text;
  LRCLine({required this.timestamp, required this.text});
}

class EmptyLine implements Line {
  @override
  get text => "\n";
}

const musicNoteString = "♫";
List<Line> toLRCLineList(String lrcString, [String gapstring = ""]) {
  final regex = RegExp(r'\[(\d{2}):(\d{2})(?:\.(\d{2}))?\](.*)');
  final lines = lrcString
      .split('\n')
      .map((line) {
        if (line.isEmpty) return EmptyLine();
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

extension LRCString on List<Line> {
  String toPlainText() {
    this;
    return map((e) => e.text).join("\n");
  }

  List<Line> remapPlainText(String text2) {
    final newPlaintext = text2.split("\n");

    List<Line> lines = [];
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
        if (this[i] is LRCLine) {
          lines.add(
            LRCLine(timestamp: (this[i] as LRCLine).timestamp, text: npt),
          );
        } else {
          lines.add(EmptyLine());
        }
      }
    }

    return lines;
  }

  String toLRCString() {
    String two(int n) => n.toString().padLeft(2, '0');
    return map((l) {
      if (l is LRCLine) {
        final m = l.timestamp.inMinutes;
        final s = l.timestamp.inSeconds % 60;
        final ms = l.timestamp.inMilliseconds % 100;
        return '[${two(m)}:${two(s)}.${two(ms)}] ${l.text}';
      } else {
        return "";
      }
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

  Duration get duration => findlastduration(); // Duration.zero;

  Duration findlastduration() {
    final line = lastWhere(
      (t) => t is LRCLine,
      orElse: () => LRCLine(timestamp: Duration(hours: 1), text: ""),
    );

    return (line as LRCLine).timestamp;
  }
}

extension LRCSpans on List<LRCLine> {
  toSpans() {
    List<TextSpan> spans = [];

    for (var element in this) {
      spans.add(TextSpan(text: " ${element.text}."));
    }

    return spans;
  }

  int position(Duration time, [int startFrom = 0]) {
    if (isEmpty) return -1;

    int left = 0;
    int right = length - 1;
    int resultIndex = 0;

    if (startFrom >= 0 && startFrom < length) {
      if (this[startFrom].timestamp <= time) {
        left = startFrom;
      } else {
        right = startFrom;
      }
    }

    while (left <= right) {
      int mid = left + ((right - left) >> 1);
      if (this[mid].timestamp <= time) {
        resultIndex = mid;
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    startFrom = resultIndex;

    return resultIndex;
  }
}
