import 'package:flutter/material.dart';
import 'package:innopolis_feedback/ui/action_button.dart';
import 'package:innopolis_feedback/ui/logo.dart';

class AuthLayout extends StatelessWidget {
  final Form form;
  final void Function() onToggleView;
  final ActionButton actionButton;
  final String toggleViewButtonText;
  final String toggleViewHelpingText;

  AuthLayout({
    this.form,
    this.onToggleView,
    this.actionButton,
    this.toggleViewButtonText,
    this.toggleViewHelpingText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          30,
          MediaQuery.of(context).size.height * 0.0935,
          30,
          30,
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 0,
              child: Logo(
                dark: true,
                height: MediaQuery.of(context).size.height * 0.135,
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: SingleChildScrollView(
                    child: form,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    child: actionButton,
                  ),
                  SizedBox(height: 20),
                  FlatButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    child: Column(
                      children: [
                        Text(
                          toggleViewHelpingText,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        SizedBox(height: 5),
                        Text(
                          toggleViewButtonText,
                          style: TextStyle(
                            color: Colors.deepPurple[500],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () => onToggleView(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
