
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditableTaskField extends StatelessWidget {
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

  int getMaxLines() {
    return TextInputType.multiline == inputType ? null : 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(7.0),
      child: TextFormField(
        keyboardType: inputType,
        maxLines: getMaxLines(),
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