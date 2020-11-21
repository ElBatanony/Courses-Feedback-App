import 'package:flutter/material.dart';

import 'data.dart';

class TaProfilePage extends StatefulWidget {
  final String taId;
  final String taName;

  TaProfilePage(this.taId, this.taName);

  @override
  _TaProfilePageState createState() => _TaProfilePageState();
}

class _TaProfilePageState extends State<TaProfilePage> {
  TA ta;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('TA - ' + widget.taName),
        ),
        body: Center(
          child: FutureBuilder(
            future: getTaById(widget.taId),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Text('Error fetching TA: ' + snapshot.error.toString());

              if (snapshot.hasData) {
                if (snapshot.data == null) return Text("Can't find data on TA");

                ta = snapshot.data;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ID: ' + ta.id),
                    Text('Name: ' + ta.name),
                    Text('Rating: unimplemented/5'),
                    displayCourses(ta),
                    displayIssues(ta)
                  ],
                );
              }

              return Text('Loading ...');
            },
          ),
        ));
  }
}

Widget displayCourses(TA ta) {
  return Text('Multiple courses per TA not implemented');
}

Widget displayIssues(TA ta) {
  return Text('Issues are yet to be implemented');
}
