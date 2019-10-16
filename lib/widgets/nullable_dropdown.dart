
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NullableDropdown extends StatefulWidget {
  final String initialValue;
  final String labelText;
  final List<String> possibleValues;
  final ValueSetter<String> valueSetter;

  const NullableDropdown({
    Key key,
    this.initialValue,
    @required this.labelText,
    @required this.possibleValues,
    @required this.valueSetter,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => NullableDropdownState();
}

class NullableDropdownState extends State<NullableDropdown> {
  String value;

  @override
  void initState() {
    super.initState();
    value = wrapNullValue(widget.initialValue);
  }

  String wrapNullValue(String value) {
    return value ?? '(none)';
  }

  String unwrapNullValue(String value) {
    return value == '(none)' ? null : value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(7.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: widget.labelText,
          filled: false,
          border: OutlineInputBorder(),
        ),
        value: value,
        onChanged: (String newValue) {
          setState(() {
            value = newValue;
            var unwrapped = unwrapNullValue(newValue);
            widget.valueSetter(unwrapped);
          });
        },
        items: widget.possibleValues.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );

  }
}
