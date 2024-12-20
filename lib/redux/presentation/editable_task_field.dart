
import 'package:flutter/material.dart';

class EditableTaskField extends StatefulWidget {
  final String? initialText;
  final String labelText;
  final ValueSetter<String?> fieldSetter;
  final ValueSetter<String?>? onChanged;
  final bool isRequired;
  final bool wordCaps;
  final TextInputType inputType;
  final FormFieldValidator<String>? validator;

  const EditableTaskField({
    super.key,
    required this.initialText,
    required this.labelText,
    required this.fieldSetter,
    required this.inputType,
    this.onChanged,
    this.isRequired = false,
    this.wordCaps = false,
    this.validator,
  });

  @override
  State<StatefulWidget> createState() {
    return EditableTaskFieldState(initialText: initialText);
  }
}

class EditableTaskFieldState extends State<EditableTaskField> {

  String? initialText;

  EditableTaskFieldState({
    required this.initialText
  });

  int? getMaxLines() {
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
        initialValue: initialText,
        onChanged: widget.onChanged,
        onSaved: widget.fieldSetter,
        validator: (value) {
          var validator = widget.validator;
          if (validator != null) {
            var validatorResult = validator(value);
            if (validatorResult != null) {
              return validatorResult;
            }
          } else if (value != null && value.isEmpty && widget.isRequired) {
            return '${widget.labelText} is required';
          }
          return null;
        },
      ),
    );
  }


}