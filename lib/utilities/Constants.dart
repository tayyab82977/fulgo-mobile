import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/models/ErrorViewModel.dart';

const kTextFieldDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  hintText: '',
  labelStyle: TextStyle(fontSize: 14, color: Constants.blueColor),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: .5),
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.blueColor, width: .5),
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  ),
);
const kBulkPickupDialogue = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  hintText: 'Enter a value',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: .5),
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.blueColor, width: .5),
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  ),
);
const kTextFieldDecoration2 = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: .5),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.redColor, width: .5),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: .5),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Constants.blueColor, width: .5),
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  ),
);

const containerShadow = BoxDecoration(
  color: Colors.transparent,
  borderRadius: BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(10)),
);

UserRepository userRepository = UserRepository();

class Constants {
  static final ErrorViewModel CONNECTION_TIMEOUT = ErrorViewModel(
    errorMessage: '',
    errorCode: HttpStatus.requestTimeout,
  );

  static const appVersion = '3.1.3';
  static String? savedVersion = '0.0.0';

  static double latitude = 21.4858;
  static double longitude = 39.1925;
  static const LatLng sauidArabia = LatLng(23.8859, 45.0792);
  // static const LatLng sauidArabia = LatLng(24.7136, 46.6753);

  static const csWhatsApp = '0580000451';
  static const csPhone = '920022167';
  static String currentLocale = 'en';
  // static const baseUrl = 'https://demo.mrashad.com/Fulgoapi';
  static const baseUrl = 'https://Fulgox.byte-s.com';

  static const googleMabiApiKey = "AIzaSyC1-lZ66R1rfXxC3eNKtkNTUXQciEw3YK0";

  static const Color clientButtonGray = Color(0xFFe4e4e4);
  static const Color clientBackgroundGrey = Color(0xFFe4e4e4);
  static const Color capOrange = Color(0xFFF77415);
  static const Color capRed = Color(0xFFFF543E);
  static const Color capDarkPurple = Color(0xFF343558);
  static const Color capPurple = Color(0xFF696BB1);
  static const Color capLigthPurple = Color(0xFFd2d2e7);
  static const Color capGreen = Color(0xFF538B1A);
  static const Color capGrey = Color(0xFF626062);
  static const Color capOffWhite = Color(0xFFF9F9F9);
  static const Color capDarkPink = Color(0xffCE5C6B);
  static const Color capLightGreen = Color(0xff42D65E);
  static const Color blueColor = Color(0xFF2f3a92);
  static const Color greyColor = Color(0xFFf4f4f4);
  static const Color redColor = Color(0xFFBE2C33);
  static const Color lightRedColor = Color(0xfff8efef);
  static const Color lightBlueColor = Color(0xffeaebf4);
}
