import 'package:flutter/material.dart';
import 'package:Fulgox/utilities/Constants.dart';

class CustomLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: Constants.blueColor,),
    );
  }
}
