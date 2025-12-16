import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/common/dashboard.dart';
import 'package:xturbox/ui/custom%20widgets/custom_loading.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/push_nofitications.dart';

import '../../utilities/comFunctions.dart';

class LogoutConfirmationDialog extends StatefulWidget {

  @override
  _LogoutConfirmationDialogState createState() => _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50)
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15,),
              Text('Are you sure to log out from all accounts ?'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Constants.blueColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text("Cancel".tr(),style: TextStyle(color: Colors.white),)),
                        ),
                      ),
                      onTap: (){
                       Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Constants.redColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text("Logout".tr(),style: TextStyle(color: Colors.white),)),
                        ),
                      ),
                      onTap: ()async{
                        try {
                          await PushNotificationManager
                              .firebaseMessaging
                              .setAutoInitEnabled(false);
                          await PushNotificationManager
                              .firebaseMessaging
                              .deleteToken();
                        } catch (e) {
                          print(e);
                        }
                        print("logout");

                        authenticationBloc.add(LoggedOut());
                        Future.delayed(
                            const Duration(milliseconds: 1), () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ChooseLanguageScreen(),
                            ),
                                (route) => false,
                          );
                        });
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
