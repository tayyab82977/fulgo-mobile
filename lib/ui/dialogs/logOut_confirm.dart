import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/ui/common/chooseLanguageScreen.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/push_nofitications.dart';
import '../../utilities/comFunctions.dart';

class LogoutConfirmationDialog extends StatefulWidget {
  @override
  _LogoutConfirmationDialogState createState() =>
      _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 15,
              ),
              Text(
                'Are you sure to log out from all accounts ?'.tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 15,
              ),
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
                          child: Center(
                            child: Text("Cancel".tr(),
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Constants.redColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text("Logout".tr(),
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      onTap: () async {
                        try {
                          await PushNotificationManager.firebaseMessaging
                              .setAutoInitEnabled(false);
                          await PushNotificationManager.firebaseMessaging
                              .deleteToken();
                        } catch (e) {
                          print(e);
                        }
                        print("logout");

                        final AuthController authController = Get.find<AuthController>();
                        authController.logout();
                        Future.delayed(const Duration(milliseconds: 1), () {
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
