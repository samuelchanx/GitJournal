import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/md_yaml_doc_codec.dart';
import 'package:gitjournal/editors/common.dart';

class RawEditor extends StatefulWidget implements Editor {
  final Note note;
  final bool noteModified;

  @override
  final NoteCallback noteDeletionSelected;
  @override
  final NoteCallback noteEditorChooserSelected;
  @override
  final NoteCallback exitEditorSelected;
  @override
  final NoteCallback renameNoteSelected;
  @override
  final NoteCallback moveNoteToFolderSelected;
  @override
  final NoteCallback discardChangesSelected;

  final bool isNewNote;

  RawEditor({
    Key key,
    @required this.note,
    @required this.noteModified,
    @required this.noteDeletionSelected,
    @required this.noteEditorChooserSelected,
    @required this.exitEditorSelected,
    @required this.renameNoteSelected,
    @required this.moveNoteToFolderSelected,
    @required this.discardChangesSelected,
    @required this.isNewNote,
  }) : super(key: key);

  @override
  RawEditorState createState() {
    return RawEditorState(note);
  }
}

class RawEditorState extends State<RawEditor> implements EditorState {
  Note note;
  bool _noteModified;
  TextEditingController _textController = TextEditingController();

  final serializer = MarkdownYAMLCodec();

  RawEditorState(this.note) {
    _textController = TextEditingController(text: serializer.encode(note.data));
  }

  @override
  void initState() {
    super.initState();
    _noteModified = widget.noteModified;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var editor = Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: _NoteEditor(
          textController: _textController,
          autofocus: widget.isNewNote,
          onChanged: _noteTextChanged,
        ),
      ),
    );

    return Scaffold(
      appBar: buildEditorAppBar(widget, this, noteModified: _noteModified),
      body: editor,
    );
  }

  @override
  Note getNote() {
    note.data = serializer.decode(_textController.text);
    return note;
  }

  void _noteTextChanged() {
    if (_noteModified) return;
    setState(() {
      _noteModified = true;
    });
  }
}

class _NoteEditor extends StatelessWidget {
  final TextEditingController textController;
  final bool autofocus;
  final Function onChanged;

  _NoteEditor({this.textController, this.autofocus, this.onChanged});

  @override
  Widget build(BuildContext context) {
    var style =
        Theme.of(context).textTheme.subhead.copyWith(fontFamily: "Roboto Mono");

    return TextField(
      autofocus: autofocus,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      style: style,
      decoration: const InputDecoration(
        hintText: 'Write here',
        border: InputBorder.none,
        isDense: true,
      ),
      controller: textController,
      textCapitalization: TextCapitalization.sentences,
      scrollPadding: const EdgeInsets.all(0.0),
      onChanged: (_) => onChanged(),
    );
  }
}
