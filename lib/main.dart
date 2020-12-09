import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:innopolis_feedback/screens/wrapper.dart';
import 'package:innopolis_feedback/services/auth.dart';
import 'package:innopolis_feedback/shared/loading.dart';
import 'package:provider/provider.dart';

import 'ta_course_page.dart';

import 'data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
        title: 'Innopolis Feedback',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
      ),
    );
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

  selectYear(Year year) async {
    print('Selected year: ' + year.name);
    currentList = await getCoursesByYear(year);
    setState(() {
      selectedYear = year;
      currentBuilder = courseItemBuilder;
    });
  }

  selectCourse(Course course) async {
    print('Selected course: ' + course.name);

    currentList = await getTAs(course);
    setState(() {
      selectedCourse = course;
      currentBuilder = taItemBuilder;
    });
  }

  selectTA(TA ta) {
    print('Selected TA: ' + ta.name);
    String title = ta.name + ' - ' + selectedCourse.name;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TaCoursePage(title, ta.id, selectedCourse.id)));
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
    // TODO: wrap Scaffold with WillPopScope to avoid exiting the app with native "BACK" button, using goBack() func instead
    // https://stackoverflow.com/questions/45916658/how-to-deactivate-or-override-the-android-back-button-in-flutter
    return Scaffold(
        appBar: AppBar(
          title: Text('Innopolis Feedback'),
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('Sign out?'),
              onPressed: () => AuthService().signOut(),
            ),
          ],
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
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Text('Oops! Something went wrong :(');
                  }
                  return Loading();
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
