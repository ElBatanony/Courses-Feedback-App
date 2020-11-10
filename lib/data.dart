import 'stub/data.dart';

class Year {
  String name;
  String code;
  List<Course> courses;

  Year(this.name, this.code, this.courses);
}

class Course {
  String name;
  String code;
  List<TA> tas;

  Course(this.name, this.code, this.tas);
}

class TA {
  String id;
  String name;
  // TODO: add issues
  // TODO: add rating
  // TODO: add courses
  TA(this.id, this.name);
}

Future<List<Year>> getYears() {
  // TODO: Fetch years from db
  return Future<List<Year>>.delayed(
      Duration(milliseconds: 1000), () => stubYears);
}

Future<TA> fetchTA(String taId) {
  // TODO: Fetch TA from db
  return Future<TA>.delayed(Duration(milliseconds: 1000),
      () => stubTAs.firstWhere((ta) => ta.id == taId));
}
