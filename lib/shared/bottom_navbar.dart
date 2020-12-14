import 'package:flutter/material.dart';
import 'package:innopolis_feedback/main.dart';
import 'package:innopolis_feedback/screens/profile.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Question - in case of PUSH stack will be too big(if pressing profile->courses->profile...) Maybe better replace?
    void goToCourses() {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyHomePage()));
    }

    void goToProfile() {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Profile()));
    }

    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: IconButton(
            icon: Icon(Icons.list),
            onPressed: goToCourses,
          ),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            icon: Icon(Icons.account_circle_outlined),
            onPressed: goToProfile,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
