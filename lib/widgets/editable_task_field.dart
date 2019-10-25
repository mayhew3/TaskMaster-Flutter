
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditableTaskField extends StatefulWidget {
  final String initialText;
  final String labelText;
  final ValueSetter<String> fieldSetter;
  final bool isRequired;
  final bool wordCaps;
  final TextInputType inputType;

  const EditableTaskField({
    Key key,
    @required this.initialText,
    @required this.labelText,
    @required this.fieldSetter,
    @required this.inputType,
    this.isRequired = false,
    this.wordCaps = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EditableTaskFieldState(initialText: this.initialText);
  }
}

class EditableTaskFieldState extends State<EditableTaskField> {

  String initialText;

  EditableTaskFieldState({
    @required this.initialText
  });

  int getMaxLines() {
    return TextInputType.multiline == widget.inputType ? null : 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(7.0),
      child: TextFormField(
        keyboardType: widget.inputType,
        maxLines: getMaxLines(),
        textCapitalization: widget.wordCaps ? TextCapitalization.words : TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: widget.labelText,
          filled: false,
          border: OutlineInputBorder(),
        ),
        initialValue: this.initialText,
        onSaved: widget.fieldSetter,
        validator: (value) {
          if (value.isEmpty && widget.isRequired) {
            return '${widget.labelText} is required';
          }
          return null;
        },
      ),
    );
  }


}