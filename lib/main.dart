import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ta_profile_page.dart';

import 'data.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore db = FirebaseFirestore.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Innopolis Feedback',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Year> years;
  Year selectedYear;
  Course selectedCourse;
  TA selectedTA;

  List currentList;
  Function currentBuilder;

  goBack() {
    if (selectedCourse != null)
      return setState(() {
        selectedCourse = null;
        selectYear(selectedYear);
      });
    if (selectedYear != null)
      return setState(() {
        selectedYear = null;
      });
  }

  selectYear(Year year) {
    print('Selected year: ' + year.name);
    setState(() {
      selectedYear = year;
      currentList = year.courses;
      currentBuilder = courseItemBuilder;
    });
  }

  selectCourse(Course course) {
    print('Selected course: ' + course.name);
    setState(() {
      selectedCourse = course;
      currentList = course.tas;
      currentBuilder = taItemBuilder;
    });
  }

  selectTA(TA ta) {
    print('Selected TA: ' + ta.name);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => TaProfilePage(ta.id, ta.name)));
  }

  Widget yearItemBuilder(Year year) {
    return ListTile(
      title: Text(year.name),
      onTap: () => selectYear(year),
    );
  }

  Widget courseItemBuilder(Course course) {
    return ListTile(
      title: Text(course.name),
      onTap: () => selectCourse(course),
    );
  }

  Widget taItemBuilder(TA ta) {
    return ListTile(
      title: Text(ta.name),
      onTap: () => selectTA(ta),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Innopolis Feedback'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text('Welcome to Innopolis Feedback!',
                  style: TextStyle(fontSize: 22)),
            ),
            Expanded(
              child: FutureBuilder(
                future: getYears(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    years = snapshot.data;
                    if (selectedYear == null) {
                      currentList = years;
                      currentBuilder = yearItemBuilder;
                    }
                    return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: currentList.length,
                        itemBuilder: (context, index) =>
                            currentBuilder(currentList[index]));
                  }
                  if (snapshot.hasError)
                    return Text('Oops! Something went wrong :(');
                  return Text('Loading ...');
                },
              ),
            ),
            if (selectedYear != null || selectedCourse != null)
              RaisedButton(
                child: Text('Back'),
                onPressed: goBack,
              )
          ],
        ));
  }
}
