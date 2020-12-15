import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class Year {
  String name;
  String id;

  Year(this.name, this.id);

  @override
  bool operator ==(Object other) {
    try {
      // ignore: test_types_in_equals
      return this.id == (other as Year).id;
    } on TypeError {
      return false;
    }
  }

  @override
  int get hashCode => this.id.hashCode + this.name.hashCode;
}

class Course {
  String name;
  String id;
  String yearId;

  Course(this.name, this.id, this.yearId);

  @override
  bool operator ==(Object other) {
    try {
      // ignore: test_types_in_equals
      return this.id == (other as Course).id;
    } on TypeError {
      return false;
    }
  }

  @override
  int get hashCode {
    return this.id.hashCode + this.name.hashCode;
  }
}

class Student {
  String id;
  String name;
  List<String> favoriteTAs;
  String role;

  Student(this.id, this.name, this.favoriteTAs, {this.role = 'student'});

  bool isFavoriteTa(String taId) => favoriteTAs.contains(taId);

  bool isAdmin() => role == "admin";
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
    if (ratingsCount == 0) ratingsCount = 1;
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
  double sentimentScore;

  StudentFeedback(this.feedbackId, this.taId, this.courseId, this.message,
      this.uid, this.email, this.upvotes, this.downvotes, this.sentimentScore);

  bool isToxic() => sentimentScore < -0.1;
}

class FeedbackComment {
  String commentId;

  // String feedbackId;
  String uid;
  String email;
  DateTime date;
  String text;

  FeedbackComment(
      this.commentId,
      // this.feedbackId,
      this.uid,
      this.email,
      this.date,
      this.text);
}

Stream<List<FeedbackComment>> getComments(String feedbackId) {
  return db
      .collection('feedback')
      .doc(feedbackId)
      .collection('comments')
      .snapshots()
      .map((snap) {
    List<FeedbackComment> commentList = [];
    snap.docs.forEach((doc) {
      var commentData = doc.data();

      FeedbackComment comment = new FeedbackComment(
          doc.id,
          // feedbackId,
          commentData['uid'],
          commentData['email'],
          commentData['date'].toDate(),
          commentData['text']);
      commentList.add(comment);
    });
    return commentList;
  });
}

Future<void> submitComment(StudentFeedback f, FeedbackComment c) {
  return db
      .collection('feedback')
      .doc(f.feedbackId)
      .collection('comments')
      .add({
    // "feedbackId": f.feedbackId,
    "uid": c.uid,
    "email": c.email,
    "date": c.date,
    "text": c.text
  });
}

Future<Student> getStudentById(String studentId) async {
  return db.collection('students').doc(studentId).get().then((studentDoc) {
    var studentData = studentDoc.data();
    return new Student(
        studentDoc.id,
        studentData['name'],
        studentData['favoriteTAs'] != null
            ? studentData['favoriteTAs']
                .map<String>((id) => id.toString())
                .toList()
            : [],
        role: studentData['role'] ?? "student");
  });
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

Future<void> addCourse(String name, String id, String yearId) {
  return db.collection('courses').doc(id).set({'name': name, 'yearId': yearId});
}

Future<String> addTA(String name) async {
  return (await db.collection('tas').add({'name': name})).id;
}

Future<void> addTaCourse(String courseId, String taId) {
  return db.collection('ta-course').add({'courseId': courseId, 'taId': taId});
}

Future<void> updateRating(String taCourseId, String uid, int rating) {
  return db
      .collection('ta-course')
      .doc(taCourseId)
      .collection('ratings')
      .doc(uid)
      .set({'rating': rating});
}

Future<void> updateTaName(String taId, String name) async {
  return await db.collection('tas').doc(taId).set({'name': name});
}

Future<void> updateCourse(String id, String name, String yearId) async {
  await db.collection('courses').doc(id).set({'name': name, 'yearId': yearId});
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
      var sentimentObject = feedbackData['sentiment'] ?? {};
      StudentFeedback feedback = new StudentFeedback(
          doc.id,
          taCourse.taId,
          taCourse.courseId,
          feedbackData['message'],
          feedbackData['uid'],
          feedbackData['email'],
          toStringList(feedbackData['upvotes'] ?? []),
          toStringList(feedbackData['downvotes'] ?? []),
          (sentimentObject['score'] ?? 0.0).toDouble());
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

Future<void> deleteCourse(String courseId) async {
  await db.collection('courses').doc(courseId).delete();
  await db
      .collection('ta-course')
      .where('courseId', isEqualTo: courseId)
      .get()
      .then((snapshot) {
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  });
  await db
      .collection('feedback')
      .where('courseId', isEqualTo: courseId)
      .get()
      .then((snapshot) {
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  });
}

Future<void> deleteStudent(String studentId) async {
  await db.collection('students').doc(studentId).delete();
  await db
      .collection('feedback')
      .where('uid', isEqualTo: studentId)
      .get()
      .then((snapshot) {
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  });
}

Future<void> deleteTaCourse(String taId, String courseId) async {
  await db
      .collection('ta-course')
      .where('taId', isEqualTo: taId)
      .where('courseId', isEqualTo: courseId)
      .get()
      .then((snapshot) {
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  });
  return await db
      .collection('feedback')
      .where('taId', isEqualTo: taId)
      .where('courseId', isEqualTo: courseId)
      .get()
      .then((snapshot) {
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  });
}

Future<void> deleteTA(String taId) async {
  await db.collection('tas').doc(taId).delete();
  await db
      .collection('ta-course')
      .where('taId', isEqualTo: taId)
      .get()
      .then((snapshot) {
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  });
  return await db
      .collection('feedback')
      .where('taId', isEqualTo: taId)
      .get()
      .then((snapshot) {
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  });
}

Future<void> deleteAllFeedbackByStudent(String studentId) async {
  return await db
      .collection('feedback')
      .where('uid', isEqualTo: studentId)
      .get()
      .then((snapshot) {
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  });
}

Future<void> deleteFeedbackByStudentInTaCourse(
    String studentId, String courseId, String taId) async {
  return await db
      .collection('feedback')
      .where('uid', isEqualTo: studentId)
      .where('courseId', isEqualTo: courseId)
      .where('taId', isEqualTo: taId)
      .get()
      .then((snapshot) {
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  });
}
