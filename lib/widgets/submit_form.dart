import 'package:flutter/material.dart';
import 'package:lyrium/datahelper.dart';
import 'package:lyrium/editor.dart';
import 'package:lyrium/widgets/scrollable_area.dart';
import 'package:pretty_diff_text/pretty_diff_text.dart';

Future<dynamic> opensubmitform(BuildContext context, DraftTrack track) {
  return showDialog(
    context: context,
    builder: (c) {
      return Dialog.fullscreen(child: SubmitForm(draft: track));
    },
  );
}

class SubmitForm extends StatefulWidget {
  final DraftTrack draft;

  const SubmitForm({super.key, required this.draft});
  @override
  _SubmitFormState createState() => _SubmitFormState();
}

class _SubmitFormState extends State<SubmitForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _artistController;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.draft.trackName);
    _artistController = TextEditingController(text: widget.draft.artistName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Save")),
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
                    defaultTextStyle: TextStyle(
                      fontSize: 32,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    oldText: widget.draft.syncedLyrics ?? "",
                    newText: widget.draft.newText,
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
                              widget.draft.newText,
                            )
                            .then((c) {
                              if (c.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Saving Failed'),
                                  ),
                                );
                              }
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
