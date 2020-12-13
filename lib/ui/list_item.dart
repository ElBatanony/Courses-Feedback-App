import 'package:flutter/material.dart';

class ListItem extends Container {
  ListItem({Widget leading, String title, Function onTap})
      : super(
          child: ListTile(
            title: Text(title),
            leading: leading,
            trailing: Icon(Icons.chevron_right),
            onTap: onTap,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 15,
            ),
          ),
          decoration: BoxDecoration(
            border: new Border(
              bottom: new BorderSide(
                color: Colors.grey[300],
              ),
            ),
          ),
        );
}
