
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditableTaskField extends StatelessWidget {
  final String initialText;
  final String labelText;
  final ValueSetter<String> fieldSetter;
  final bool isRequired;
  final bool multiline;
  final bool wordCaps;

  const EditableTaskField({
    Key key,
    @required this.initialText,
    @required this.labelText,
    @required this.fieldSetter,
    this.isRequired = false,
    this.multiline = false,
    this.wordCaps = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(7.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        maxLines: multiline ? null : 1,
        textCapitalization: wordCaps ? TextCapitalization.words : TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: labelText,
          filled: false,
          border: OutlineInputBorder(),
        ),
        initialValue: initialText,
        onSaved: fieldSetter,
        validator: (value) {
          if (value.isEmpty && isRequired) {
            return '$labelText is required';
          }
          return null;
        },
      ),
    );
  }


}