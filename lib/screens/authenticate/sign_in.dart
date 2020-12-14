import 'package:flutter/material.dart';
import 'package:innopolis_feedback/screens/authenticate/auth_layout.dart';
import 'package:innopolis_feedback/services/auth.dart';
import 'package:innopolis_feedback/shared/loading.dart';
import 'package:innopolis_feedback/ui/action_button.dart';
import 'package:innopolis_feedback/ui/text_form_field.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  // text field state
  String email = '';
  String password = '';

  Future<void> handleLogin() async {
    if (_formKey.currentState.validate()) {
      setState(() => loading = true);
      dynamic result = await _auth.signIn(email, password);
      if (result == null) {
        setState(
          () {
            loading = false;
            error = 'Could not sign in with those credentials';
          },
        );
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
                  SizedBox(
                    height: 15,
                  ),
                  CustomTextFormField(
                    placeholder: 'Email',
                    validator: (val) => val.isEmpty ? 'Enter an email' : null,
                    onChanged: (val) {
                      setState(() => email = val);
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CustomTextFormField(
                    obscureText: true,
                    placeholder: 'Password',
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
            actionButton: ActionButton(text: 'Login', onPressed: handleLogin),
            onToggleView: widget.toggleView,
            toggleViewButtonText: 'Register',
            toggleViewHelpingText: 'Don’t have an account yet?',
          );
  }
}
