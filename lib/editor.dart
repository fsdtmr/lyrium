import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:lyrium/datahelper.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/storage/local.dart';
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
  late TrackInfo info;
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
              ;
            }

            Navigator.of(context).pop();
          },
        ),
        title: Text("Editing ${info.trackName} "),
        actions: [
          IconButton(
            onPressed: () {
              opensubmitform(context);
            },
            icon: const Icon(Icons.done),
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
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: ScrollableArea(
                      child: TextField(
                        autofocus: true,
                        minLines: 100,
                        maxLines: null,
                        controller: textEditingController,
                        focusNode: _focusNode,
                        undoController: _undoController, // ← key line
                        style: TextStyle(fontSize: 22),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
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
                                  final confirmed =
                                      await showDiscardChangesDialog(context);
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
          );
        },
      ),
    );
  }

  Future<dynamic> opensubmitform(BuildContext context) {
    return showDialog(
      context: context,
      builder: (c) {
        return Dialog.fullscreen(
          child: ArtworkForm(from: initial, to: textEditingController.text),
        );
      },
    );
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
}

class ArtworkForm extends StatefulWidget {
  final String from;
  final String to;

  const ArtworkForm({super.key, required this.from, required this.to});
  @override
  _ArtworkFormState createState() => _ArtworkFormState();
}

class _ArtworkFormState extends State<ArtworkForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Artwork Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a title";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _artistController,
                decoration: InputDecoration(labelText: "Artist"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter an artist name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              Expanded(
                child: ScrollableArea(
                  child: PrettyDiffText(
                    defaultTextStyle: TextStyle(fontSize: 32),
                    oldText: widget.from,
                    newText: widget.to,
                  ),
                ),
              ),

              SizedBox(height: 24),

              TextButton(
                onPressed: _formKey.currentState?.validate() ?? false
                    ? () {
                        DataHelper.instance
                            .insertDraft(
                              _titleController.text,
                              _artistController.text,
                              widget.to,
                            )
                            .then((c) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Saved')),
                              );
                            });
                      }
                    : null,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScrollableArea extends StatelessWidget {
  final Widget child;
  const ScrollableArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: MediaQuery.of(context).size.width + 300,
          child: child,
        ),
      ),
    );
  }
}
