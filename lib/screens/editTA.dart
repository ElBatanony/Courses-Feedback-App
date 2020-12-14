import 'package:flutter/material.dart';
import 'package:innopolis_feedback/data.dart';
import 'package:innopolis_feedback/shared/loading.dart';
import 'package:innopolis_feedback/shared/styles.dart';

class EditTA extends StatefulWidget {
  final TA editingTA;

  EditTA(this.editingTA);

  @override
  _EditTAState createState() => _EditTAState();
}

class _EditTAState extends State<EditTA> {
  final _formKey = GlobalKey<FormState>();
  double maxWidth;
  List<Year> _years = [];
  List<Course> _courses = [];
  List<Course> _assignedCourses = [];

  String error = '';
  String selectionError = '';
  bool loading = false;
  bool assigningLoading = false;

  // text field state
  TextEditingController name;

  // dropdown button state
  Year year;
  Course course;

  Widget yearSelector(BuildContext context) {
    return year == null
        ? DropdownButtonFormField<Year>(
            decoration: textInputDecoration,
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
              ])
        : DropdownButtonFormField<Year>(
            isExpanded: true,
            decoration: textInputDecoration,
            value: year,
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (Year newValue) {
              setState(() {
                year = newValue;
              });
            },
            items: _years.map<DropdownMenuItem<Year>>((Year year) {
              return DropdownMenuItem<Year>(
                value: year,
                child: Text(year.name),
              );
            }).toList(),
          );
  }

  Widget courseSelector(BuildContext context) {
    return FutureBuilder(
      future: getCoursesByYear(year),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _courses = snapshot.data;
          course = _courses.contains(course) ? course : null;
          if (course == null) {
            course = _courses.isNotEmpty ? _courses[0] : null;
          }

          return course == null
              ? DropdownButtonFormField<Course>(
                  decoration: textInputDecoration,
                  value: course,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  onChanged: (Course newValue) {},
                  items: [
                      DropdownMenuItem<Course>(
                        value: course,
                        child: Text("No courses available :("),
                      )
                    ])
              : DropdownButtonFormField<Course>(
                  isExpanded: true,
                  decoration: textInputDecoration,
                  value: course,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 48,
                  elevation: 16,
                  onChanged: (Course newValue) {
                    setState(() {
                      course = newValue;
                    });
                  },
                  items:
                      _courses.map<DropdownMenuItem<Course>>((Course course) {
                    return DropdownMenuItem<Course>(
                      value: course,
                      child: Text(course.name),
                    );
                  }).toList(),
                );
        }
        if (snapshot.hasError) {
          print(snapshot.error);
          return Text('Oops! Something went wrong :(');
        }
        return Loading();
      },
    );
  }

  Widget assignedCoursesList(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: getCoursesByTA(widget.editingTA),
      builder: (futureContext, snapshot) {
        if (snapshot.hasData) {
          if (_assignedCourses.isEmpty) {
            _assignedCourses = snapshot.data;
          }
        }
        if (snapshot.hasError) {
          print(snapshot.error.toString());
          return ListTile(
            title: Center(child: Text("Something went wrong :(")),
            onTap: () {},
          );
        }

        if (_assignedCourses.isEmpty) {
          return ListTile(
            title: Center(child: Text("Empty")),
            onTap: () {},
          );
        }
        return Column(
            children: _assignedCourses.map((course) {
          return ListTile(
            title: Text(course.name),
            onTap: () {},
            trailing: IconButton(
              icon: Icon(Icons.close),
              color: ColorsStyle.inactiveTrack,
              onPressed: () {
                setState(() {
                  _assignedCourses.remove(course);
                });
              },
            ),
          );
        }).toList());
      },
    );
  }

  Widget assignButton(BuildContext context) {
    return assigningLoading
        ? CircularProgressIndicator(backgroundColor: ColorsStyle.primary)
        : RaisedButton(
            color: ColorsStyle.primary,
            child: Text(
              'Assign',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              if (course == null) {
                setState(() {
                  selectionError = 'Course is not selected';
                });
                return null;
              }
              setState(() => assigningLoading = true);
              if (_assignedCourses.contains(course)) {
                selectionError = 'Selected course has already been assigned';
              } else {
                selectionError = '';
                _assignedCourses.add(course);
              }
              setState(() => assigningLoading = false);
            });
  }

  Widget submitButton(BuildContext context) {
    return RaisedButton(
        color: ColorsStyle.primary,
        child: Text(
          'Edit TA',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            try {
              if (_assignedCourses.isEmpty) {
                setState(() {
                  error = 'At least one assigned course is required';
                });
              } else {
                setState(() => loading = true);
                if (widget.editingTA.name != name.text) {
                  await updateTaName(widget.editingTA.id, name.text);
                }
                List<Course> current = await getCoursesByTA(widget.editingTA);
                List<Course> diff = current
                    .toSet()
                    .difference(_assignedCourses.toSet())
                    .toList();

                for (Course course in diff) {
                  await deleteTaCourse(widget.editingTA.id, course.id);
                }
                diff = _assignedCourses
                    .toSet()
                    .difference(current.toSet())
                    .toList();
                for (Course course in diff) {
                  await addTaCourse(course.id, widget.editingTA.id);
                }
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
        });
  }

  @override
  void initState() {
    super.initState();
    name = TextEditingController();
    name.text = widget.editingTA.name;
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
                title: Text('Editing TA')),
            body: Container(
              child: Form(
                key: _formKey,
                child: FutureBuilder(
                    future: getYears(),
                    builder: (futureContext, snapshot) {
                      if (snapshot.hasData) {
                        if (_years.isEmpty) {
                          _years = snapshot.data;
                        }
                        if (year == null) {
                          year = _years.isNotEmpty ? _years[0] : null;
                        }
                        return ListView(
                          padding: EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 50.0),
                          children: <Widget>[
                            Text("Name"),
                            TextFormField(
                              controller: name,
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'name'),
                              validator: (val) =>
                                  val.isEmpty ? 'Enter TA\'s name' : null,
                            ),
                            SizedBox(height: 20.0),
                            Divider(color: ColorsStyle.divider),
                            SizedBox(height: 10.0),
                            Center(child: Text("Course assigner")),
                            SizedBox(height: 20.0),
                            Text("Year"),
                            yearSelector(futureContext),
                            SizedBox(height: 10.0),
                            Text("Course"),
                            courseSelector(futureContext),
                            SizedBox(height: 10.0),
                            Text(
                              selectionError,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 14.0),
                            ),
                            SizedBox(height: 10.0),
                            assignButton(futureContext),
                            SizedBox(height: 20.0),
                            Divider(color: ColorsStyle.divider),
                            SizedBox(height: 10.0),
                            Center(child: Text("Assigned courses")),
                            SizedBox(height: 20.0),
                            Container(
                              child: assignedCoursesList(futureContext),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color.fromARGB(30, 0, 0, 0),
                                      width: 2.0)),
                            ),
                            SizedBox(height: 20.0),
                            submitButton(context),
                            SizedBox(height: 12.0),
                            Text(
                              error,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 14.0),
                            )
                          ],
                        );
                      }
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Text('Oops! Something went wrong :(');
                      }
                      return Loading();
                    }),
              ),
            ),
          );
  }
}
