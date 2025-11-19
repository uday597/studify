import 'package:flutter/material.dart';

PreferredSizeWidget ReuseAppbar({
  required String name,
  IconData? icon,
  VoidCallback? onPressed,
}) {
  return AppBar(
    actions: [IconButton(onPressed: onPressed, icon: Icon(icon))],

    foregroundColor: Colors.white,
    backgroundColor: Colors.lightBlueAccent,
    title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
  );
}
