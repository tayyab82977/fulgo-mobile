import 'package:flutter/material.dart';

class CustomCheckBox extends StatelessWidget {
  Color checkedColor ;
  Color unCheckedColor ;
  Color backgroundColor ;
  bool? checked ;
  CustomCheckBox(
      {  required
      this.backgroundColor,
        required
        this.checked,
        required
        this.checkedColor,
        required
        this.unCheckedColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: checked! ? checkedColor : backgroundColor ,
        border: Border.all(color: checked! ? checkedColor : unCheckedColor , style: BorderStyle.solid),
      ),
      child: checked! ? Center(child: Icon(Icons.check,size: 11, color: Colors.white,) ) : Container(),
    );
  }
}
