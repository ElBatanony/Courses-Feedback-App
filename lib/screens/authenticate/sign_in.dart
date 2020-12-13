import 'package:flutter/material.dart' hide TextFormField;
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

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : new AuthLayout(
            form: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  error != ''
                      ? Text(
                          error,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.0,
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    placeholder: 'Email',
                    validator: (val) => val.isEmpty ? 'Enter an email' : null,
                    onChanged: (val) {
                      setState(() => email = val);
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
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

    // Scaffold(
    //         body: Padding(
    //           padding: EdgeInsets.fromLTRB(
    //             30,
    //             MediaQuery.of(context).size.height * 0.0935,
    //             30,
    //             30,
    //           ),
    //           child: Column(
    //             children: <Widget>[
    //               Expanded(
    //                 flex: 0,
    //                 child: Logo(
    //                   dark: true,
    //                   height: MediaQuery.of(context).size.height * 0.135,
    //                 ),
    //               ),
    //               Expanded(
    //                 flex: 1,
    //                 child: Center(
    //                   child: Padding(
    //                     padding: const EdgeInsets.symmetric(vertical: 20),
    //                     child: Form(
    //                       key: _formKey,
    //                       child: SingleChildScrollView(
    //                         child: Column(
    //                           children: <Widget>[
    //                             error != ''
    //                                 ? Text(
    //                                     error,
    //                                     style: TextStyle(
    //                                       color: Colors.red,
    //                                       fontSize: 14.0,
    //                                     ),
    //                                   )
    //                                 : Container(),
    //                             SizedBox(
    //                               height: 15,
    //                             ),
    //                             TextFormField(
    //                               placeholder: 'Email',
    //                               validator: (val) =>
    //                                   val.isEmpty ? 'Enter an email' : null,
    //                               onChanged: (val) {
    //                                 setState(() => email = val);
    //                               },
    //                             ),
    //                             SizedBox(
    //                               height: 30,
    //                             ),
    //                             TextFormField(
    //                               obscureText: true,
    //                               placeholder: 'Password',
    //                               validator: (val) => val.length < 6
    //                                   ? 'Enter a password 6+ chars long'
    //                                   : null,
    //                               onChanged: (val) {
    //                                 setState(() => password = val);
    //                               },
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //               Expanded(
    //                 flex: 0,
    //                 child: Column(
    //                   // crossAxisAlignment: CrossAxisAlignment.stretch,
    //                   children: <Widget>[
    //                     Container(
    //                       width: double.infinity,
    //                       child: ActionButton(
    //                         text: 'Login',
    //                         onPressed: handleLogin,
    //                       ),
    //                     ),
    //                     SizedBox(height: 20),
    //                     FlatButton(
    //                       materialTapTargetSize:
    //                           MaterialTapTargetSize.shrinkWrap,
    //                       padding:
    //                           EdgeInsets.symmetric(vertical: 0, horizontal: 10),
    //                       child: Column(
    //                         children: [
    //                           Text(
    //                             'Don’t have an account yet?',
    //                             textAlign: TextAlign.center,
    //                             style: TextStyle(fontWeight: FontWeight.normal),
    //                           ),
    //                           SizedBox(height: 5),
    //                           Text(
    //                             'Register',
    //                             style: TextStyle(
    //                               color: Colors.deepPurple[500],
    //                               decoration: TextDecoration.underline,
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                       splashColor: Colors.transparent,
    //                       highlightColor: Colors.transparent,
    //                       onPressed: widget.toggleView,
    //                     )
    //                   ],
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       );
  }
}
