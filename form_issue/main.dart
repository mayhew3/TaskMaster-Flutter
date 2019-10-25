import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:intl/intl.dart' show DateFormat;

void main() {
  var taskItem = TaskItem(
    name: 'Existing Name',
    description: 'Existing Description',
    urgency: 3,
    priority: 5,
    gamePoints: 1,
    urgentDate: DateTime.now(),
    dueDate: DateTime.now(),
  );

  runApp(FormTestApp(taskItem: taskItem));
}

class TaskItem {
  final String name;
  final String description;
  final String project;
  final String context;
  final int urgency;
  final int priority;
  final int duration;
  final DateTime startDate;
  final DateTime targetDate;
  final DateTime dueDate;
  final DateTime urgentDate;
  final int gamePoints;

  TaskItem( {
    this.name,
    this.description,
    this.urgency,
    this.project,
    this.context,
    this.priority,
    this.duration,
    this.startDate,
    this.targetDate,
    this.dueDate,
    this.urgentDate,
    this.gamePoints,
  });
}

class FormTestApp extends StatefulWidget {
  final TaskItem taskItem;

  const FormTestApp({Key key,
    this.taskItem}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FormTestAppState();
  }
}

class FormTestAppState extends State<FormTestApp> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _name; // ignore: unused_field
  String _description; // ignore: unused_field

  String _project; // ignore: unused_field
  String _context; // ignore: unused_field

  String _priority; // ignore: unused_field
  String _duration; // ignore: unused_field
  String _urgency; // ignore: unused_field

  DateTime _startDate;
  DateTime _targetDate;
  DateTime _dueDate;
  DateTime _urgentDate;

  String _gamePoints; // ignore: unused_field

  int _formUpdates;

  List<String> possibleProjects;
  List<String> possibleContexts;

  void saveForm() async {
    final form = formKey.currentState;
    if (form.validate()) {
      _formUpdates = 0;
      form.save();
      print('$_formUpdates updates made.');
    }
  }


  @override
  void initState() {
    super.initState();
    _startDate = widget.taskItem?.startDate;
    _targetDate = widget.taskItem?.targetDate;
    _dueDate = widget.taskItem?.dueDate;
    _urgentDate = widget.taskItem?.urgentDate;

    _project = widget.taskItem?.project;
    _context = widget.taskItem?.context;

    _formUpdates = 0;

    possibleProjects = [
      '(none)',
      'Career',
      'Hobby',
      'Friends',
      'Family',
      'Health',
      'Maintenance',
      'Organization',
      'Shopping',
      'Entertainment',
      'WIG Mentorship',
      'Writing',
      'Bugs',
      'Projects',
    ];

    possibleContexts = [
      '(none)',
      'Computer',
      'Home',
      'Office',
      'E-Mail',
      'Phone',
      'Outside',
      'Reading',
      'Planning',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Issue',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Task Details"),
        ),
        body: Form(
          key: formKey,
          autovalidate: false,
          onWillPop: () {
            return Future(() => true);
          },
          child: ListView(
            children: <Widget>[
              EditableTaskField(
                initialText: widget.taskItem?.name,
                labelText: 'Name',
                fieldSetter: (value) {
                  print('Saving NAME');
                  _formUpdates++;
                  _name = value;
                },
                inputType: TextInputType.multiline,
                isRequired: true,
                wordCaps: true,
              ),
              NullableDropdown(
                initialValue: widget.taskItem?.project,
                labelText: 'Project',
                possibleValues: possibleProjects,
                valueSetter: (newValue) => _project = newValue,
              ),
              NullableDropdown(
                initialValue: widget.taskItem?.context,
                labelText: 'Context',
                possibleValues: possibleContexts,
                valueSetter: (newValue) => _context = newValue,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: 'Urgency',
                        filled: false,
                        border: OutlineInputBorder(),
                      ),
                      initialValue: widget.taskItem?.urgency?.toString(),
                      onSaved: (value) {
                        _formUpdates++;
                        _urgency = value;
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        filled: false,
                        border: OutlineInputBorder(),
                      ),
                      initialValue: widget.taskItem?.priority?.toString(),
                      onSaved: (value) {
                        _formUpdates++;
                        _priority = value;
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: 'Points',
                        filled: false,
                        border: OutlineInputBorder(),
                      ),
                      initialValue: widget.taskItem?.gamePoints?.toString(),
                      onSaved: (value) {
                        _formUpdates++;
                        _gamePoints = value;
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: 'Length',
                        filled: false,
                        border: OutlineInputBorder(),
                      ),
                      initialValue: widget.taskItem?.gamePoints?.toString(),
                      onSaved: (value) {
                        _formUpdates++;
                        _gamePoints = value;
                      },
                    ),
                  ),
                ],
              ),
              ClearableDateTimeField(
                labelText: 'Start Date',
                dateGetter: () {
                  return _startDate;
                },
                dateSetter: (DateTime pickedDate) {
                  setState(() {
                    _startDate = pickedDate;
                  });
                },
              ),
              ClearableDateTimeField(
                labelText: 'Target Date',
                dateGetter: () {
                  return _targetDate;
                },
                dateSetter: (DateTime pickedDate) {
                  setState(() {
                    _targetDate = pickedDate;
                  });
                },
              ),
              ClearableDateTimeField(
                labelText: 'Due Date',
                dateGetter: () {
                  return _dueDate;
                },
                dateSetter: (DateTime pickedDate) {
                  setState(() {
                    _dueDate = pickedDate;
                  });
                },
              ),
              ClearableDateTimeField(
                labelText: 'Urgent Date',
                dateGetter: () {
                  return _urgentDate;
                },
                dateSetter: (DateTime pickedDate) {
                  setState(() {
                    _urgentDate = pickedDate;
                  });
                },
              ),
              EditableTaskField(
                initialText: widget.taskItem?.description,
                labelText: 'Notes',
                fieldSetter: (value) {
                  print('Saving DESCRIPTION');
                  _formUpdates++;
                  _description = value;
                },
                inputType: TextInputType.multiline,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => saveForm(),
        ),
      ),
    );
  }

}

final longDateFormat = DateFormat.yMMMMd().add_jm();

DateTime daysFromNow(int days) {
  DateTime now = DateTime.now();
  DateTime atSeven = new DateTime(now.year, now.month, now.day, 19);
  return atSeven.add(new Duration(days: days));
}

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

class ClearableDateTimeField extends StatelessWidget {
  const ClearableDateTimeField({
    Key key,
    this.labelText,
    this.dateGetter,
    this.dateSetter,
  }) : super(key: key);

  final String labelText;
  final ValueGetter<DateTime> dateGetter;
  final ValueChanged<DateTime> dateSetter;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(7.0),
      child: DateTimeField(
        decoration: InputDecoration(
          labelText: labelText,
          filled: false,
          border: OutlineInputBorder(),
        ),
        format: longDateFormat,
        initialValue: dateGetter(),
        onChanged: (pickedDate) => dateSetter(pickedDate),
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? daysFromNow(7),
              lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
              TimeOfDay.fromDateTime(currentValue ?? daysFromNow(7)),
            );
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        },
      ),
    );
  }
}

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

/// A [FormField<DateTime>] that integrates a text input with time-chooser UIs.
///
/// It borrows many of it's parameters from [TextFormField].
///
/// When a [controller] is specified, [initialValue] must be null (the
/// default).
class DateTimeField extends FormField<DateTime> {
  DateTimeField({
    @required this.format,
    @required this.onShowPicker,

    // From super
    Key key,
    FormFieldSetter<DateTime> onSaved,
    FormFieldValidator<DateTime> validator,
    DateTime initialValue,
    bool autovalidate = false,
    bool enabled = true,

    // Features
    this.resetIcon = const Icon(Icons.close),
    this.onChanged,

    // From TextFormField
    // Key key,
    this.controller,
    // String initialValue,
    this.focusNode,
    InputDecoration decoration = const InputDecoration(),
    TextInputType keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction textInputAction,
    TextStyle style,
    StrutStyle strutStyle,
    TextDirection textDirection,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    this.readOnly = false,
    bool showCursor,
    bool obscureText = false,
    bool autocorrect = true,
    // bool autovalidate = false,
    bool maxLengthEnforced = true,
    int maxLines = 1,
    int minLines,
    bool expands = false,
    int maxLength,
    VoidCallback onEditingComplete,
    ValueChanged<DateTime> onFieldSubmitted,
    // FormFieldSetter<String> onSaved,
    // FormFieldValidator<String> validator,
    List<TextInputFormatter> inputFormatters,
    // bool enabled = true,
    double cursorWidth = 2.0,
    Radius cursorRadius,
    Color cursorColor,
    Brightness keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    InputCounterWidgetBuilder buildCounter,
  }) : super(
      key: key,
      autovalidate: autovalidate,
      initialValue: initialValue,
      enabled: enabled ?? true,
      validator: validator,
      onSaved: onSaved,
      builder: (field) {
        final _DateTimeFieldState state = field;
        final InputDecoration effectiveDecoration = (decoration ??
            const InputDecoration())
            .applyDefaults(Theme.of(field.context).inputDecorationTheme);
        return TextField(
          controller: state._effectiveController,
          focusNode: state._effectiveFocusNode,
          decoration: effectiveDecoration.copyWith(
            errorText: field.errorText,
            suffixIcon: state.shouldShowClearIcon(effectiveDecoration)
                ? IconButton(
              icon: resetIcon,
              onPressed: state.clear,
            )
                : null,
          ),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          textCapitalization: textCapitalization,
          autofocus: autofocus,
          readOnly: readOnly,
          showCursor: showCursor,
          obscureText: obscureText,
          autocorrect: autocorrect,
          maxLengthEnforced: maxLengthEnforced,
          maxLines: maxLines,
          minLines: minLines,
          expands: expands,
          maxLength: maxLength,
          onChanged: (string) =>
              field.didChange(tryParse(string, format)),
          onEditingComplete: onEditingComplete,
          onSubmitted: (string) => onFieldSubmitted == null
              ? null
              : onFieldSubmitted(tryParse(string, format)),
          inputFormatters: inputFormatters,
          enabled: enabled,
          cursorWidth: cursorWidth,
          cursorRadius: cursorRadius,
          cursorColor: cursorColor,
          scrollPadding: scrollPadding,
          keyboardAppearance: keyboardAppearance,
          enableInteractiveSelection: enableInteractiveSelection,
          buildCounter: buildCounter,
        );
      });

  /// For representing the date as a string e.g.
  /// `DateFormat("EEEE, MMMM d, yyyy 'at' h:mma")`
  /// (Sunday, June 3, 2018 at 9:24pm)
  final DateFormat format;

  /// Called when the date chooser dialog should be shown.
  final Future<DateTime> Function(BuildContext context, DateTime currentValue)
  onShowPicker;

  /// The [InputDecoration.suffixIcon] to show when the field has text. Tapping
  /// the icon will clear the text field. Set this to `null` to disable that
  /// behavior. Also, setting the suffix icon yourself will override this option.
  final Icon resetIcon;

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool readOnly;
  final void Function(DateTime value) onChanged;

  @override
  _DateTimeFieldState createState() => _DateTimeFieldState();

  /// Returns an empty string if [DateFormat.format()] throws or [date] is null.
  static String tryFormat(DateTime date, DateFormat format) {
    if (date != null) {
      try {
        return format.format(date);
      } catch (e) {
        // print('Error formatting date: $e');
      }
    }
    return '';
  }

  /// Returns null if [format.parse()] throws.
  static DateTime tryParse(String string, DateFormat format) {
    if (string?.isNotEmpty ?? false) {
      try {
        return format.parse(string);
      } catch (e) {
        // print('Error parsing date: $e');
      }
    }
    return null;
  }

  /// Sets the hour and minute of a [DateTime] from a [TimeOfDay].
  static DateTime combine(DateTime date, TimeOfDay time) => DateTime(
      date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);

  static DateTime convert(TimeOfDay time) =>
      DateTime(1, 1, 1, time?.hour ?? 0, time?.minute ?? 0);
}

class _DateTimeFieldState extends FormFieldState<DateTime> {
  TextEditingController _controller;
  FocusNode _focusNode;
  bool isShowingDialog = false;
  bool hadFocus = false;

  @override
  DateTimeField get widget => super.widget;

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _focusNode;

  bool get hasFocus => _effectiveFocusNode.hasFocus;
  bool get hasText => _effectiveController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: format(widget.initialValue));
      _controller.addListener(_handleControllerChanged);
    }
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _focusNode.addListener(_handleFocusChanged);
    }
    widget.controller?.addListener(_handleControllerChanged);
    widget.focusNode?.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(DateTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null) {
        _controller =
            TextEditingController.fromValue(oldWidget.controller.value);
        _controller.addListener(_handleControllerChanged);
      }
      if (widget.controller != null) {
        setValue(parse(widget.controller.text));
        // Release the controller since it wont be used
        if (oldWidget.controller == null) {
          _controller?.dispose();
          _controller = null;
        }
      }
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      widget.focusNode?.addListener(_handleFocusChanged);

      if (oldWidget.focusNode != null && widget.focusNode == null) {
        _focusNode = FocusNode();
        _focusNode.addListener(_handleFocusChanged);
      }
      if (widget.focusNode != null && oldWidget.focusNode == null) {
        // Release the focus node since it wont be used
        _focusNode?.dispose();
        _focusNode = null;
      }
    }
  }

  @override
  void didChange(DateTime value) {
    if (widget.onChanged != null) widget.onChanged(value);
    super.didChange(value);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode?.dispose();
    widget.controller?.removeListener(_handleControllerChanged);
    widget.focusNode?.removeListener(_handleFocusChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    _effectiveController.text = format(widget.initialValue);
    didChange(widget.initialValue);
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController.text != format(value))
      didChange(parse(_effectiveController.text));
  }

  String format(DateTime date) => DateTimeField.tryFormat(date, widget.format);
  DateTime parse(String text) => DateTimeField.tryParse(text, widget.format);

  Future<void> requestUpdate() async {
    if (!isShowingDialog) {
      isShowingDialog = true;
      final newValue = await widget.onShowPicker(context, value);
      isShowingDialog = false;
      if (newValue != null) {
        _effectiveController.text = format(newValue);
      }
    }
  }

  void _handleFocusChanged() {
    if (hasFocus && !hadFocus && (!hasText || widget.readOnly)) {
      hadFocus = hasFocus;
      _hideKeyboard();
      requestUpdate();
    } else {
      hadFocus = hasFocus;
    }
  }

  void _hideKeyboard() {
    Future.microtask(() => FocusScope.of(context).requestFocus(FocusNode()));
  }

  void clear() async {
    _hideKeyboard();
    // Fix for ripple effect throwing exception
    // and the field staying gray.
    // https://github.com/flutter/flutter/issues/36324
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _effectiveController.clear());
    });
  }

  bool shouldShowClearIcon([InputDecoration decoration]) =>
      widget.resetIcon != null &&
          (hasText || hasFocus) &&
          decoration?.suffixIcon == null;
}
