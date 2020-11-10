import '../data.dart';

TA stubTA1 = TA('1', 'Tony Stark');
TA stubTA2 = TA('2', 'Batman');
TA stubTA3 = TA('3', 'The Flash');
TA stubTA4 = TA('4', 'Captain Russia');
TA stubTA5 = TA('5', 'Electro');
TA stubTA6 = TA('6', 'Machine Monster');

List<TA> stubTAs = [stubTA1, stubTA2, stubTA3, stubTA4, stubTA5, stubTA6];

List<Year> stubYears = [
  Year('Bach-17', 'BS17', [
    Course('Mobile Application Development', '[F20]MAD', [stubTA1, stubTA2]),
    Course('Academic Writing and Research Culture l', '[F20]AW&RC_1',
        [stubTA3, stubTA4])
  ]),
  Year('Masters-18', 'MS18', [
    Course('Machine Learning', 'ML', [stubTA5, stubTA6])
  ])
];
