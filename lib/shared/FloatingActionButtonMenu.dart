import 'package:flutter/material.dart';
import 'package:innopolis_feedback/shared/styles.dart';

class FloatingActionButtonMenu extends StatefulWidget {
  final String tooltip;
  final AnimatedIconData animatedIcon;
  final List<FloatingActionButton> menuItems;

  FloatingActionButtonMenu({this.tooltip, this.animatedIcon, this.menuItems});

  @override
  _FloatingActionButtonMenuState createState() => _FloatingActionButtonMenuState();
}

class _FloatingActionButtonMenuState extends State<FloatingActionButtonMenu>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  List<Widget> _menuItems;

  @override
  initState() {
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: ColorsStyle.primary,
      end: ColorsStyle.primary,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  _animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {
      isOpened = !isOpened;
    });
  }

  Widget _toggle() {
    return Container(
      child: FloatingActionButton(
        heroTag: "toggle",
        backgroundColor: _buttonColor.value,
        onPressed: _animate,
        tooltip: widget.tooltip,
        child: AnimatedIcon(
          icon: widget.animatedIcon,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _menuItems = [];
    widget.menuItems.asMap().forEach((index, fab) {
      _menuItems.add(
          Transform(
            transform: Matrix4.translationValues(
              0.0,
              _translateButton.value * (widget.menuItems.length * 1.0 - index),
              0.0,
            ),
            child: Container(
                child: fab
            ),
          )
      );
    });
    _menuItems.add(_toggle());
    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _menuItems
    );
  }
}