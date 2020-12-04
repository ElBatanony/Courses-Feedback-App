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

  Course(this.name, this.id, this.yearId);
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

class TaCourse {
  String taId;
  String courseId;
  double rating;
  String docId;

  TaCourse(this.taId, this.courseId, this.docId, this.rating);
}

class StudentFeedback {
  String taId, courseId, message, uid, email;

  StudentFeedback(this.taId, this.courseId, this.message, this.uid, this.email);
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

              courses.add(new Course(
                  courseData['name'], courseDoc.id, courseData['yearId']));
            })
          });
  return courses;
}

Future<List<Course>> getCoursesByTA(TA ta) async {
  List<Course> courses = [];

  return db
      .collection('ta-course')
      .where('taId', isEqualTo: ta.id)
      .get()
      .then((snap) async {
    for (int i = 0; i < snap.docs.length; i += 1) {
      var taCourseData = snap.docs[i].data();
      var course = await getCourseById(taCourseData['courseId']);
      courses.add(course);
    }
    return courses;
  });
}

Future<List<TA>> getTAs(Course course) async {
  List<TA> tas = [];

  return db
      .collection('ta-course')
      .where('courseId', isEqualTo: course.id)
      .get()
      .then((snap) async {
    for (int i = 0; i < snap.docs.length; i += 1) {
      var taCourseData = snap.docs[i].data();
      var course = await getTaById(taCourseData['taId']);
      tas.add(course);
    }
    return tas;
  });
}

Future<TA> getTaById(String taId) {
  return db.collection('tas').doc(taId).get().then((taDoc) {
    var taData = taDoc.data();
    return new TA(taData['name'], taDoc.id);
  });
}

Future<Course> getCourseById(String courseId) {
  return db.collection('courses').doc(courseId).get().then((courseDoc) {
    var courseData = courseDoc.data();
    return new Course(courseData['name'], courseDoc.id, courseData['yearId']);
  });
}

Future<TaCourse> getTaCoursePair(String taId, String courseId) {
  return db
      .collection('ta-course')
      .where('taId', isEqualTo: taId)
      .where('courseId', isEqualTo: courseId)
      .get()
      .then((snap) {
    var doc = snap.docs.first;
    if (doc.exists == false) {
      return null;
    }

    var docData = doc.data();
    double rating = 0;
    if (docData['rating'] != null) rating = (docData['rating']) * 1.0;

    return new TaCourse(docData['taId'] ?? 'no TA ID',
        docData['courseId'] ?? 'no Course ID', doc.id, rating);
  });
}

Future<int> getRating(String taCourseId, String uid) {
  return db
      .collection('ta-course')
      .doc(taCourseId)
      .collection('ratings')
      .doc(uid)
      .get()
      .then((doc) {
    if (doc.exists == false) return 0;
    return doc.data()['rating'] ?? 0;
  });
}

Future<void> updateRating(String taCourseId, String uid, int rating) {
  return db
      .collection('ta-course')
      .doc(taCourseId)
      .collection('ratings')
      .doc(uid)
      .set({'rating': rating});
  // TODO: update average rating of ta-course-pair using firestore triggers
}

Future<void> submitFeedback(StudentFeedback f, bool isAnonymous) {
  return db.collection('feedback').add({
    "taId": f.taId,
    "courseId": f.courseId,
    "message": f.message,
    "uid": f.uid,
    "email": isAnonymous ? 'Anonymous' : f.email
  });
}

Stream<List<StudentFeedback>> getFeedback(TaCourse taCourse) {
  return db
      .collection('feedback')
      .where('taId', isEqualTo: taCourse.taId)
      .where('courseId', isEqualTo: taCourse.courseId)
      .snapshots()
      .map((snap) {
    List<StudentFeedback> feedbackList = [];
    snap.docs.forEach((doc) {
      var feedbackData = doc.data();
      StudentFeedback feedback = new StudentFeedback(
          taCourse.taId,
          taCourse.courseId,
          feedbackData['message'],
          feedbackData['uid'],
          feedbackData['email']);
      feedbackList.add(feedback);
    });
    return feedbackList;
  });
}
