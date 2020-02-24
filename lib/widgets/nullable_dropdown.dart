
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NullableDropdown extends StatefulWidget {
  final String initialValue;
  final String labelText;
  final List<String> possibleValues;
  final ValueSetter<String> valueSetter;
  final FormFieldValidator validator;

  const NullableDropdown({
    Key key,
    this.initialValue,
    @required this.labelText,
    @required this.possibleValues,
    @required this.valueSetter,
    this.validator,
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

  TextStyle getMenuItemStyle(String menuItem) {
    if (menuItem != value) {
      return TextStyle(color: Colors.lightBlueAccent);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(7.0),
      child: DropdownButtonFormField<String>(
        isDense: true,
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
        validator: widget.validator,
        items: widget.possibleValues.map<DropdownMenuItem<String>>((String itemValue) {
          return DropdownMenuItem<String>(
            value: itemValue,
            child: Text(itemValue,
              style: getMenuItemStyle(itemValue),
            ),
          );
        }).toList(),
      ),
    );

  }
}
