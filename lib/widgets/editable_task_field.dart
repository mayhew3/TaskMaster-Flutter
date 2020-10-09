
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditableTaskField extends StatefulWidget {
  final String initialText;
  final String labelText;
  final ValueSetter<String> fieldSetter;
  final ValueSetter<String> onChanged;
  final bool isRequired;
  final bool wordCaps;
  final TextInputType inputType;
  final FormFieldValidator<String> validator;

  const EditableTaskField({
    Key key,
    @required this.initialText,
    @required this.labelText,
    @required this.fieldSetter,
    @required this.inputType,
    this.onChanged,
    this.isRequired = false,
    this.wordCaps = false,
    this.validator,
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
        onChanged: widget.onChanged,
        onSaved: widget.fieldSetter,
        validator: (value) {
          if (widget.validator != null) {
            var validatorResult = widget.validator(value);
            if (validatorResult != null) {
              return validatorResult;
            }
          } else if (value.isEmpty && widget.isRequired) {
            return '${widget.labelText} is required';
          }
          return null;
        },
      ),
    );
  }


}