// import 'dart:ui';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class ShapesPainter extends CustomPainter {
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint();
//
//     // set the color property of the paint
//     paint.color = Colors.deepOrange;
//
//
//
//     // set the paint color to be white
//     paint.color = Colors.white;
//
//     // Create a rectangle with size and width same as the canvas
//     var rect = Rect.fromLTWH(0, 0, size.width, size.height);
//
//     // draw the rectangle using the paint
//     canvas.drawRect(rect, paint);
//
//     // center of the canvas is (x,y) => (width/2, height/2)
//     var center = Offset(size.width / 2, size.height / 2);
//
//     // draw the circle with center having radius 75.0
//     canvas.drawCircle(center, 75.0, paint);
//
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     // TODO: implement shouldRepaint
//     return null;
//   }
// }