import 'package:flutter/material.dart';

Widget reuseList({
  VoidCallback? onTap,
  required String image,
  required String text,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, const Color.fromARGB(255, 169, 226, 255)],
            begin: Alignment.center,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(2, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightBlueAccent.withOpacity(0.9),
                      Colors.blueAccent.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Image.asset(image, height: 32, color: Colors.white),
              ),
            ),

            // TEXT
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color.fromARGB(189, 0, 0, 0),
                  letterSpacing: 1.1,
                ),
              ),
            ),

            // ARROW
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
