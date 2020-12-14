import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innopolis_feedback/ui/text_form_field.dart';
import 'package:innopolis_feedback/screens/authenticate/auth_layout.dart';
import 'package:innopolis_feedback/services/auth.dart';
import 'package:innopolis_feedback/shared/loading.dart';
import 'package:innopolis_feedback/ui/action_button.dart';

class SignUp extends StatefulWidget {
  final Function toggleView;

  SignUp({this.toggleView});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final String innoMail = '@innopolis.ru';
  final String innoMail2 = '@innopolis.university';
  String error = '';
  bool loading = false;

  // text field state
  String email = '';
  String password = '';
  String name = '';
  String yearId = 'bs17'; //constant for now
  // TODO: implement choosing study year

  Future<void> handleRegister() async {
    if (_formKey.currentState.validate()) {
      setState(() => loading = true);
      User user = await _auth.signUp(email, password, name, yearId);
      if (user == null) {
        setState(() {
          loading = false;
          error = 'The email address is already in use';
        });
      } else {
        user.sendEmailVerification();
      }
    }
  }

  // TODO: add live form validation

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : new AuthLayout(
            form: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  if (error != '')
                    Text(
                      error,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.0,
                      ),
                    ),
                  SizedBox(height: 15),
                  CustomTextFormField(
                    placeholder: 'Name',
                    validator: (val) => val.isEmpty ? 'Enter your name' : null,
                    onChanged: (val) {
                      setState(() => name = val);
                    },
                  ),
                  SizedBox(height: 30.0),
                  CustomTextFormField(
                    placeholder: 'Email',
                    validator: (val) =>
                        val.endsWith(innoMail) || val.endsWith(innoMail2)
                            ? null
                            : 'Enter an Innopolis email',
                    onChanged: (val) {
                      setState(() => email = val);
                    },
                  ),
                  SizedBox(height: 30.0),
                  CustomTextFormField(
                    placeholder: 'Password',
                    obscureText: true,
                    validator: (val) => val.length < 6
                        ? 'Enter a password 6+ chars long'
                        : null,
                    onChanged: (val) {
                      setState(() => password = val);
                    },
                  ),
                ],
              ),
            ),
            actionButton: ActionButton(
              text: 'Register',
              onPressed: handleRegister,
            ),
            toggleViewButtonText: 'Login',
            toggleViewHelpingText: 'Already have an account?',
            onToggleView: widget.toggleView,
          );
  }
}
