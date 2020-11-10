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
  String name;
  TA(this.name);
}

List<Year> stubYears = [
  Year('Bach-17', 'BS17', [
    Course('Mobile Application Development', '[F20]MAD',
        [TA('Tony Stark'), TA('Batman')]),
    Course('Academic Writing and Research Culture l', '[F20]AW&RC_1',
        [TA('The Flash'), TA('Captain Russia')])
  ]),
  Year('Masters-18', 'MS18', [
    Course('Machine Learning', 'ML', [TA('Electro'), TA('Machine Monster')])
  ])
];

Future<List<Year>> getYears() {
  return Future<List<Year>>.delayed(
      Duration(milliseconds: 1000), () => stubYears);
}
