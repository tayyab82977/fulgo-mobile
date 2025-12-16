import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class FieldValidation {


 static final rtlChars = RegExp('[\u0591-\u07FF]');
 static bool validaStoreName(String value) {
   return (FieldValidation.rtlChars.hasMatch(value)) ? false : true;
 }


 static String acceptedCharachters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123";
  static String? emptyValidation(String value , String msg){
    if (value.isEmpty){
      return msg ;
    }else{
      return null ;
    }

  }

  static String? phoneValidation(String value) {
      if (value.isEmpty) {
        return 'Please enter your mobile';
      }
      if (value.length != 9 && value.characters.first != '5') {
        return 'please enter a valid mobile number';
      }
      return null;
  }











}