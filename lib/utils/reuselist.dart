import 'package:flutter/material.dart';

Widget reuseList({
  VoidCallback? onTap,
  required Color color,
  required String image,
  required String text,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.white.withOpacity(0.3),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isSmall = width < 350;
          return Container(
            height: isSmall ? 95 : 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.95), color.withOpacity(0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(3, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: CircleAvatar(
                    radius: isSmall ? 30 : 38,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        image,
                        height: isSmall ? 30 : 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: isSmall ? 18 : 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white70,
                    size: isSmall ? 22 : 26,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
