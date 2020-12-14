import 'package:flutter/material.dart';
import 'package:innopolis_feedback/data.dart';
import 'package:innopolis_feedback/shared/loading.dart';
import 'package:innopolis_feedback/shared/styles.dart';

class EditCourse extends StatefulWidget {
  final Course editingCourse;

  EditCourse(this.editingCourse);

  @override
  _EditCourseState createState() => _EditCourseState();
}

class _EditCourseState extends State<EditCourse> {
  final _formKey = GlobalKey<FormState>();
  List<Year> _years = [];

  String error = '';
  bool loading = false;

  // text field state
  var name = TextEditingController();
  var abbreviation = TextEditingController();

  // dropdown button state
  Year year;

  String makeAbbreviation(String courseName) {
    String temp = courseName;
    if (courseName.contains("]")) {
      temp = courseName.substring(courseName.indexOf("]") + 1);
    }
    if (temp == "") return "";
    List<String> parts = temp.replaceAll("and", "&").split(" ");
    DateTime now = DateTime.now();
    String result =
        (now.month >= 6 ? "[F" : "[S") + (now.year % 100).toString() + "]";
    parts.forEach((part) {
      result += part == "" ? "" : part[0].toUpperCase();
    });
    return result;
  }

  @override
  void initState() {
    super.initState();
    name = TextEditingController();
    name.text = widget.editingCourse.name;
    abbreviation = TextEditingController();
    abbreviation.text = widget.editingCourse.id;
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            resizeToAvoidBottomPadding: false,
            backgroundColor: Colors.white,
            appBar: AppBar(
                backgroundColor: ColorsStyle.primary,
                elevation: 0.0,
                title: Text('Editing Course')),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Name"),
                      ],
                    ),
                    TextFormField(
                      controller: name,
                      decoration:
                          textInputDecoration.copyWith(hintText: 'name'),
                      validator: (val) =>
                          val.isEmpty ? 'Enter course\'s name' : null,
                      onChanged: (val) {},
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Abbreviation"),
                      ],
                    ),
                    TextFormField(
                      enabled: false,
                      controller: abbreviation,
                      decoration: textInputDecoration.copyWith(
                          hintText: 'abbreviation'),
                      validator: (val) => val.isEmpty ||
                              !(val.startsWith("[F") || val.startsWith("[S"))
                          ? 'Enter abbreviation in format: \'[S20] ABC\''
                          : null,
                      onChanged: (val) {
                        setState(() => abbreviation.text = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Year"),
                      ],
                    ),
                    FutureBuilder(
                      future: getYears(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _years = snapshot.data;
                          if (year == null) {
                            int index = _years
                                .indexOf(Year("", widget.editingCourse.yearId));
                            if (index != -1) {
                              year = _years[index];
                            } else {
                              year = _years.isNotEmpty ? _years[0] : null;
                            }
                          }

                          if (_years.isNotEmpty) {
                            return DropdownButtonFormField<Year>(
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'year'),
                              value: year,
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              onChanged: (Year newValue) {
                                setState(() {
                                  year = newValue;
                                });
                              },
                              items: _years
                                  .map<DropdownMenuItem<Year>>((Year year) {
                                return DropdownMenuItem<Year>(
                                  value: year,
                                  child: Text(year.name),
                                );
                              }).toList(),
                            );
                          } else {
                            return DropdownButtonFormField<Year>(
                                decoration: textInputDecoration.copyWith(
                                    hintText: 'year'),
                                value: year,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 24,
                                elevation: 16,
                                onChanged: (Year newValue) {},
                                items: [
                                  DropdownMenuItem<Year>(
                                    value: year,
                                    child: Text(""),
                                  )
                                ]);
                          }
                        }
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return Text('Oops! Something went wrong :(');
                        }
                        return Loading();
                      },
                    ),
                    SizedBox(height: 20.0),
                    RaisedButton(
                        color: ColorsStyle.primary,
                        child: Text(
                          'Edit Course',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() => loading = true);
                            try {
                              if (widget.editingCourse.name == name.text &&
                                  widget.editingCourse.yearId == year.id) {
                                throw Exception("Nothing to update");
                              } else {
                                await updateCourse(widget.editingCourse.id,
                                    name.text, year.id);
                                Navigator.pop(context, true);
                              }
                            } catch (e, p) {
                              print(e.toString() + " " + p.toString());
                              if (e.toString().contains("]")) {
                                error = e.toString().split('] ')[1];
                              } else {
                                error = e.toString();
                              }
                              setState(() => loading = false);
                            }
                          }
                        }),
                    SizedBox(height: 12.0),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
