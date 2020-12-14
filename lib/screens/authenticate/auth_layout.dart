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
          0,
          MediaQuery.of(context).size.height * 0.0935,
          0,
          0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Logo(
              dark: true,
              height: MediaQuery.of(context).size.height * 0.135,
            ),
            SizedBox(height: 20),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        form,
                        SizedBox(height: MediaQuery.of(context).size.height * 0.065),
                        Column(
                          children: [
                            Container(
                              width: double.infinity,
                              child: actionButton,
                            ),
                            SizedBox(height: 20),
                            FlatButton(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding:
                                  EdgeInsets.symmetric(vertical: 0, horizontal: 10),
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
