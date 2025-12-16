import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/ui/custom%20widgets/NetworkErrorView.dart';
import 'package:xturbox/ui/common/dashboard.dart';
import 'package:xturbox/utilities/comFunctions.dart';

class GeneralHandler {

  static handleInvalidToken(BuildContext context){
    print('Hello from General Handler 403');
    AuthenticationBloc authenticationBloc = AuthenticationBloc() ;
    authenticationBloc.add(LoggedOut());
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ChooseLanguageScreen(),
        ),
            (route) => false,
      );
    });
  }


  static handleNeedUpdateState(BuildContext context){
    print('Hello from General Handler 505');
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Column(
              children: [
                Text('please update the application to be able to continue'.tr()),
              ],
            ),
            actions: [
              TextButton(
                child: Text('ok'.tr()),
                onPressed: () {
                  ComFunctions.launchStore();
                  Navigator.pop(context);

                },
              ),
            ],
          );
        });
  }


  static handleGeneralError(BuildContext context){
    print('Hello from General Handler General Error');
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Icon(Icons.error,size: 49,),
                    SizedBox(height: 20,),
                    Text('Something went wrong please try again'.tr(),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10,),
                    // Text('contact with the customer service'.tr(),
                    //   style: TextStyle(
                    //     // decoration: TextDecoration.underline,
                    //     // color: Colors.blue
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                  ],
                ),
              ),
            ),
            actions: [
              // TextButton(
              //   child: Text('contact with the customer service'.tr()),
              //   onPressed: () {
              //     ComFunctions.launcPhone("920022167");
              //
              //   },
              // ),
              TextButton(
                child: Text('ok'.tr()),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ResourcesScreen(
                      ),
                    ),
                        (route) => false,
                  );
                },
              ),
            ],
          );
        });
  }

  static handleNetworkError(BuildContext context){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return NetworkErrorView();
        });
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  static List<String> handleErrorsFromApi(var decodedData){
    List<String> errorsMList = [];
    errorsMList.add('error'.tr());
    var errorPosList ;
    String? errorString ;
    try{
      errorPosList = decodedData['error'];
      var errorList = errorPosList.cast<String>();
      errorsMList.addAll(errorList);

    }catch(e){
      try{
        errorString = decodedData['error'];
        errorsMList.add(errorString ?? "");
      }catch(e){
        // errorsMList.removeLast();
      }

    }
    return errorsMList ;


  }


}