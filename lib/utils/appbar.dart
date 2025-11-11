import 'package:flutter/material.dart';

PreferredSizeWidget ReuseAppbar({required String name, IconData? icon}) {
  return AppBar(
    actions: [IconButton(onPressed: () {}, icon: Icon(icon))],

    foregroundColor: Colors.white,
    backgroundColor: Colors.lightBlueAccent,
    title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
  );
}
