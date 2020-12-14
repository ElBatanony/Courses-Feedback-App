import 'package:flutter/material.dart';
import 'package:innopolis_feedback/shared/bottom_navbar.dart';
import 'package:innopolis_feedback/shared/loading.dart';
import 'package:innopolis_feedback/ta_course_page.dart';
import 'package:innopolis_feedback/data.dart';
import 'package:innopolis_feedback/ui/app_bar.dart';
import 'package:innopolis_feedback/ui/list_item.dart';

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
    return ListItem(
      title: year.name,
      onTap: () => selectYear(year),
    );
  }

  Widget courseItemBuilder(Course course) {
    return ListItem(
      title: course.name,
      onTap: () => selectCourse(course),
    );
  }

  Widget taItemBuilder(TA ta) {
    return ListItem(
      title: ta.name,
      onTap: () => selectTA(ta),
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple[100],
        radius: 18,
        child: Opacity(
          opacity: 0.9,
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Innopolis Feedback',
        goBackIconVisible: selectedYear != null || selectedCourse != null,
        onGoBack: goBack,
      ),
      bottomNavigationBar: BottomNavBar(
        defaultSelectedIndex: 0,
      ),
      body: Column(
        children: [
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
                    padding: const EdgeInsets.all(30),
                    itemCount: currentList.length,
                    itemBuilder: (context, index) =>
                        currentBuilder(currentList[index]),
                  );
                }
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text('Oops! Something went wrong :(');
                }
                return Loading();
              },
            ),
          ),
        ],
      ),
    );
  }
}
