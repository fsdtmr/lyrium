import 'package:flutter/material.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/utils/duration.dart';
import 'package:lyrium/utils/lrc.dart';
import 'package:lyrium/utils/string.dart';
import 'package:lyrium/viewer.dart';
import 'package:lyrium/widgets/scrollable_area.dart';
import 'package:lyrium/widgets/submit_form.dart';

class LyricsEditor extends StatefulWidget {
  final LyricsTrack track;

  const LyricsEditor({super.key, required this.track});

  @override
  State<LyricsEditor> createState() => _LyricsEditorState();
}

class _LyricsEditorState extends State<LyricsEditor> {
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController secondarytextEditingController =
      TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final UndoHistoryController _undoController = UndoHistoryController();
  final UndoHistoryController _secondaryUndoController =
      UndoHistoryController();

  static const _plaintextMode = [false, true];
  static const _lrctextMode = [true, false];
  TextStyle editorTextStyle = TextStyle(fontSize: 22);
  late List<bool> modeSelected;

  late String initial;
  late TrackInfo info;

  Duration duration = Durations.medium1;
  @override
  void initState() {
    super.initState();
    info = widget.track.toInfo();
    initial = widget.track.editable;
    modeSelected = _lrctextMode;
    textEditingController.text = initial;
  }

  TextStyle get enabledStyle => Theme.of(context).textTheme.bodyMedium!;
  TextStyle get disabledStyle =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            if (textEditingController.text != initial) {
              if (!(await showDiscardChangesDialog(context))) {
                return;
              }
            }

            Navigator.of(context).pop();
          },
        ),
        title: Text("Editing ${info.trackName} "),
        actions: [
          ValueListenableBuilder<UndoHistoryValue>(
            valueListenable: modeSelected == _lrctextMode
                ? _undoController
                : _secondaryUndoController,
            builder: (context, value, _) {
              return Row(
                children: [
                  IconButton(
                    isSelected: value.canUndo,
                    onPressed: () async {
                      if (!value.canUndo) {
                        textEditingController.text = initial;
                        final confirmed = await showDiscardChangesDialog(
                          context,
                        );
                        if (confirmed) {}
                      } else {
                        _undoController.undo();
                      }
                    },
                    icon: Icon(Icons.undo),
                  ),
                  IconButton(
                    isSelected: value.canRedo,
                    onPressed: () => _undoController.redo(),
                    icon: Icon(Icons.redo),
                  ),
                ],
              );
            },
          ),
        ],
      ),

      body: Builder(
        builder: (context) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: ScrollableArea(
                      child: switch (modeSelected) {
                        _lrctextMode => TextField(
                          autofocus: true,
                          minLines: 100,
                          maxLines: null,
                          controller: textEditingController,
                          focusNode: _focusNode,
                          undoController: _undoController,
                          style: editorTextStyle,
                          decoration: InputDecoration(
                            hintText: "[mm:ss.mss] La La La....",
                            border: InputBorder.none,
                          ),
                        ),

                        _plaintextMode => TextField(
                          autofocus: true,
                          minLines: 100,
                          maxLines: null,
                          controller: secondarytextEditingController,
                          undoController: _secondaryUndoController,
                          focusNode: _focusNode,
                          style: editorTextStyle,
                          decoration: InputDecoration(
                            hintText: "La La La....",
                            border: InputBorder.none,
                          ),
                        ),

                        [...] => throw UnimplementedError(),
                      },
                    ),
                  ),
                ),

                Row(
                  children: [
                    IconButton(
                      isSelected: modeSelected == _lrctextMode,

                      onPressed: () {
                        switchtoLRC();
                      },
                      icon: const Icon(Icons.list_alt),
                    ),
                    IconButton(
                      isSelected: modeSelected == _plaintextMode,
                      onPressed: () {
                        switchtoPlain();
                      },
                      icon: const Icon(Icons.text_fields),
                    ),
                    IconButton(
                      onPressed: () {
                        editorTextStyle = editorTextStyle.copyWith(
                          fontSize: editorTextStyle.fontSize! - 1,
                        );

                        setState(() {});
                      },
                      icon: Icon(Icons.text_decrease),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          editorTextStyle = editorTextStyle.copyWith(
                            fontSize: editorTextStyle.fontSize! + 1,
                          );
                        });
                      },
                      icon: Icon(Icons.text_increase),
                    ),
                    const Spacer(),

                    TextButton.icon(
                      label: Text("Next"),
                      onPressed: () {
                        if (modeSelected != _lrctextMode) {
                          switchtoLRC();
                          return;
                        }
                        openViewer(context);
                      },
                      icon: const Icon(Icons.done),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void switchtoPlain() {
    final _plain = toLRCLineList(textEditingController.text).toPlainText();
    secondarytextEditingController.text = _plain.isValid
        ? _plain
        : textEditingController.text;
    setState(() => modeSelected = _plaintextMode);
  }

  void switchtoLRC() {
    if (secondarytextEditingController.text != "") {
      textEditingController.text = remapPlainText(
        textEditingController.text,
        secondarytextEditingController.text,
      );
    }
    setState(() => modeSelected = _lrctextMode);
  }

  Future<bool> showDiscardChangesDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You are about to discard unsaved changes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    ).then((v) {
      return v ?? false;
    });
  }

  static String remapPlainText(String text, String text2) {
    text = text
        .split("\n")
        .map((e) {
          var l = e.split("]");
          if (l.length == 2) {
            return e;
          }
          return "[00:00.000]$e";
        })
        .join("\n");
    return toLRCLineList(text).remapPlainText(text2).toLRCString();
  }

  void openViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) {
          final textColor =
              Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

          var textStyle = TextStyle(
            fontSize: 40,

            fontWeight: FontWeight.w800,
            color: textColor.withAlpha(127),
          );
          var highlighttextStyle = TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: textColor,
          );
          final lrcln = toLRCLineList(textEditingController.text);

          return LyricsView(
            textStyle: textStyle,
            highlightTextStyle: highlighttextStyle,
            controller: NoOpController(
              lyrics: widget.track.copyWith(
                syncedLyrics: textEditingController.text,
                duration:
                    lrcln.lastOrNull?.timestamp.toDouble() ??
                    Duration(hours: 1).toDouble(),
              ),
            ),
            onSave: () {
              return opensubmitform(
                context,
                DraftTrack.from(widget.track, textEditingController.text),
              );
            },
          );
        },
      ),
    );
  }
}

class DraftTrack extends LyricsTrack {
  final String newText;

  DraftTrack({
    required super.id,
    required super.trackName,
    super.namespace = "Draft",
    required this.newText,

    super.artistName,
    super.albumName,
    super.duration,
    super.instrumental,
    super.plainLyrics,
    super.syncedLyrics,
  });

  factory DraftTrack.from(LyricsTrack track, String s) {
    return DraftTrack(
      newText: s,

      id: track.id,
      trackName: track.trackName,
      artistName: track.artistName,
      albumName: track.albumName,
      duration: track.duration,
      instrumental: track.instrumental,
      plainLyrics: track.plainLyrics,
      syncedLyrics: track.syncedLyrics,
    );
  }
}
