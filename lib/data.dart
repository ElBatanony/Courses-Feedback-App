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

  Student(this.id, this.name, this.yearId);
}

class TA {
  String id;
  String name;

  TA(this.name, this.id);
}

class TaCourse {
  String taId;
  String courseId;
  String docId;
  double avgRating;
  List<int> ratings;

  calculateAvgRating() {
    int ratingsCount = 0, sumRatings = 0;
    for (int i = 0; i < 5; i += 1) {
      ratingsCount += ratings[i];
      sumRatings += (i + 1) * ratings[i];
    }
    avgRating = sumRatings / ratingsCount;
  }

  TaCourse(this.taId, this.courseId, this.docId, this.ratings) {
    calculateAvgRating();
  }
}

class StudentFeedback {
  String feedbackId;
  String taId, courseId, message, uid, email;
  List<String> upvotes, downvotes; // List of emails

  StudentFeedback(this.feedbackId, this.taId, this.courseId, this.message,
      this.uid, this.email, this.upvotes, this.downvotes);
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

    List<int> ratings = [];
    for (int i = 1; i <= 5; i += 1) {
      List<dynamic> rating = docData['rating$i'] ?? [];
      ratings.add(rating.length);
    }

    return new TaCourse(docData['taId'] ?? 'no TA ID',
        docData['courseId'] ?? 'no Course ID', doc.id, ratings);
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
}

Future<void> submitFeedback(StudentFeedback f, bool isAnonymous) {
  return db.collection('feedback').add({
    "taId": f.taId,
    "courseId": f.courseId,
    "message": f.message,
    "uid": f.uid,
    "email": isAnonymous ? 'Anonymous' : f.email,
    "upvotes": [],
    "downvotes": []
  });
}

List<String> toStringList(List<dynamic> l) {
  return l.map((e) => e.toString()).toList();
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
          doc.id,
          taCourse.taId,
          taCourse.courseId,
          feedbackData['message'],
          feedbackData['uid'],
          feedbackData['email'],
          toStringList(feedbackData['upvotes'] ?? []),
          toStringList(feedbackData['downvotes'] ?? []));
      feedbackList.add(feedback);
    });
    return feedbackList;
  });
}

Future<void> updateVotes(StudentFeedback f) {
  return db
      .collection('feedback')
      .doc(f.feedbackId)
      .update({"upvotes": f.upvotes, "downvotes": f.downvotes});
}

Future<void> deleteFeedback(StudentFeedback f) {
  return db.collection('feedback').doc(f.feedbackId).delete();
}
