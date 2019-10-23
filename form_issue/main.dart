import 'package:flutter/material.dart';

void main() {
  runApp(FormTestApp(taskItem: TaskItem('Existing Name', 'Existing Description', 3)));
}

class TaskItem {
  final String name;
  final String description;
  final int urgency;

  TaskItem(this.name, this.description, this.urgency);
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
  String _urgency; // ignore: unused_field

  void saveForm() async {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
    }
  }


  @override
  void initState() {
    super.initState();
    _urgency = widget.taskItem?.urgency?.toString();
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
              TextFormField(
                keyboardType: TextInputType.text,
                maxLines: null,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: false,
                  border: OutlineInputBorder(),
                ),
                initialValue: widget.taskItem?.name,
                onSaved: (value) {
                  print('Saving name field!');
                  _name = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Description',
                  filled: false,
                  border: OutlineInputBorder(),
                ),
                initialValue: widget.taskItem?.description,
                onSaved: (value) {
                  print('Saving description field!');
                  _description = value;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'Urgency',
                  filled: false,
                  border: OutlineInputBorder(),
                ),
                initialValue: _urgency,
                onSaved: (value) {
                  print('Saving urgency field!');
                  _urgency = value;
                },
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