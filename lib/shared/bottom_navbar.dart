import 'package:flutter/material.dart';
import 'package:innopolis_feedback/screens/home/home.dart';
import 'package:innopolis_feedback/screens/profile.dart';

class BottomNavBar extends StatefulWidget {
  final int defaultSelectedIndex;

  BottomNavBar({this.defaultSelectedIndex});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex;

  @override
  Widget build(BuildContext context) {
    //Question - in case of PUSH stack will be too big(if pressing profile->courses->profile...) Maybe better replace?
    void goToCourses() {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyHomePage()));
    }

    void goToProfile() {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Profile()));
    }

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });

      if (index == 0) {
        goToCourses();
      } else if (index == 1) {
        goToProfile();
      }
    }

    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex ?? widget.defaultSelectedIndex,
      onTap: _onItemTapped,
    );
  }
}
