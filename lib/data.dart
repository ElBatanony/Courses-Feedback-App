import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class Year {
  String name;
  String id;

  Year(this.name, this.id);
}

class Course {
  String name;
  String id;
  String yearId;
  List<String> taIds;

  Course(this.name, this.id, this.yearId, this.taIds);
}

class Student {
  String id;
  String name;
  String yearId;

  // TODO: add issues
  // TODO: add feedback, up/down votes, representatives, comments and stuff that we will  have time for
  Student(this.id, this.name, this.yearId);
}

class TA {
  String id;
  String name;

  // TODO: add issues
  // TODO: add rating
  TA(this.name, this.id);
}

List<String> courseTaIds(dynamic courseData) {
  return (courseData['tas'] as List).map((e) => e.toString()).toList();
}

Future<List<Year>> getYears() async {
  List<Year> years = [];
  return db.collection('years').get().then((snap) {
    snap.docs.forEach((yearDoc) {
      var yearData = yearDoc.data();
      years.add(new Year(yearData['name'], yearDoc.id));
    });
    return years;
  });
}

Future<List<Course>> getCoursesByYear(Year year) async {
  List<Course> courses = [];
  await db
      .collection('courses')
      .where('yearId', isEqualTo: year.id)
      .get()
      .then((snap) => {
            snap.docs.forEach((courseDoc) {
              var courseData = courseDoc.data();
              var courseTas = courseTaIds(courseData);

              courses.add(new Course(courseData['name'], courseDoc.id,
                  courseData['yearId'], courseTas));
            })
          });
  return courses;
}

Future<List<Course>> getCoursesByTA(TA ta) async {
  List<Course> courses = [];
  return db
      .collection('courses')
      .where('tas', arrayContains: ta.id)
      .get()
      .then((snap) {
    snap.docs.forEach((courseDoc) {
      var courseData = courseDoc.data();
      var courseTas = courseTaIds(courseData);
      courses.add(new Course(
          courseData['name'], courseDoc.id, courseData['yearId'], courseTas));
    });
    return courses;
  });
}

Future<List<TA>> getTAs(Course course) async {
  List<TA> tas = [];

  for (int i = 0; i < course.taIds.length; i += 1) {
    String taId = course.taIds[i];
    var taDoc = await db.collection('tas').doc(taId).get();
    var taData = taDoc.data();
    tas.add(new TA(taData['name'], taDoc.id));
  }

  return tas;
}

Future<TA> getTaById(String taId) {
  return db.collection('tas').doc(taId).get().then((taDoc) {
    var taData = taDoc.data();
    return new TA(taData['name'], taDoc.id);
  });
}
