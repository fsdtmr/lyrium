import 'package:flutter/material.dart';
import 'package:lyrium/utils/lrc.dart';


class SimpleLyricEditor extends StatefulWidget {
  final String initial;
  const SimpleLyricEditor({super.key, required this.initial});

  @override
  State<SimpleLyricEditor> createState() => _SimpleLyricEditorState();
}

class _SimpleLyricEditorState extends State<SimpleLyricEditor> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    textEditingController.text = widget.initial;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.done))],
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
          child: Stack(
            children: [
              SelectableRichText(
                text: toLRCLineList(widget.initial).toSpans() ?? [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SelectableRichText extends StatelessWidget {
  final List<TextSpan> text;

  const SelectableRichText({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(text: "", children: text),
      showCursor: true,
      cursorColor: Colors.red,
      cursorWidth: 2,

      onSelectionChanged: (selection, cause) => {
        switch (cause) {
          null => () {},
          SelectionChangedCause.tap => () {},
          SelectionChangedCause.doubleTap => () {},
          SelectionChangedCause.longPress => () {},
          SelectionChangedCause.forcePress => () {},
          SelectionChangedCause.keyboard => () {},
          SelectionChangedCause.toolbar => () {},
          SelectionChangedCause.drag => () {
          },
          SelectionChangedCause.stylusHandwriting => () {},
        },
      },
    );
  }
}
