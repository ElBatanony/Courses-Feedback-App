import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResendVerificationEmail extends StatelessWidget {
  final User user;
  ResendVerificationEmail(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurple[50],
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Text(
              'You need to verify you account to act on this page',
              style: TextStyle(color: Colors.deepPurple[500]),
            ),
            RaisedButton(
              color: Colors.deepPurple[100],
              textColor: Colors.deepPurple[900],
              child: Text('Resend verification mail'),
              onPressed: user.sendEmailVerification,
            )
          ],
        ),
      ),
    );
  }
}
