import 'package:flutter/material.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/viewer.dart';

import 'package:pretty_diff_text/pretty_diff_text.dart';

class LyricsEditor extends StatefulWidget {
  final LyricsTrack track;

  const LyricsEditor({super.key, required this.track});

  @override
  State<LyricsEditor> createState() => _LyricsEditorState();
}

class _LyricsEditorState extends State<LyricsEditor> {
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final UndoHistoryController _undoController = UndoHistoryController();

  static const _plaintextMode = [false, true];
  static const _lrctextMode = [true, false];

  late List<bool> modeSelected;

  late String initial;
  late TrackInfo? info;
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
        title: Text(info?.trackName ?? "Not set"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) {
                  return Dialog.fullscreen(
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 700,
                            child: SingleChildScrollView(
                              child: DiffView(
                                from: initial,
                                to: textEditingController.text,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.done),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 700,
                    child: Stack(
                      children: [
                        switch (modeSelected) {
                          _lrctextMode => TextField(
                            minLines: 100,
                            maxLines: null,
                            controller: textEditingController,
                            focusNode: _focusNode,
                            undoController: _undoController, // ← key line
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                          _plaintextMode => TextField(
                            minLines: 100,
                            maxLines: null,
                            controller: textEditingController,
                            focusNode: _focusNode,
                            undoController: _undoController, // ← key line
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),

                          [...] => SizedBox(),
                        },
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Row(
              children: [
                ToggleButtons(
                  isSelected: modeSelected,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() => modeSelected = _lrctextMode);
                      },
                      icon: const Icon(Icons.list_alt),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => modeSelected = _plaintextMode);
                      },
                      icon: const Icon(Icons.text_fields),
                    ),
                  ],
                ),

                const Spacer(),

                ValueListenableBuilder<UndoHistoryValue>(
                  valueListenable: _undoController,
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
          ],
        ),
      ),
    );
  }

  Future<bool> showDiscardChangesDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Do you really want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    ).then((v) {
      return v ?? false;
    });
  }
}

class DiffView extends StatelessWidget {
  final String from;
  final String to;

  const DiffView({super.key, required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return PrettyDiffText(
      // defaultTextStyle:
      //     Theme.of(context).textTheme.bodyLarge ??
      //     const TextStyle(color: Colors.black),
      oldText: from,
      newText: to,
    );
  }
}
