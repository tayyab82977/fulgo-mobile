import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:get/get.dart' hide Trans;
import 'package:Fulgox/controllers/switch_account_controller.dart';
import 'package:Fulgox/ui/common/dashboard.dart';
import 'package:Fulgox/ui/custom%20widgets/custom_loading.dart';
import 'package:Fulgox/utilities/Constants.dart';

import '../../utilities/comFunctions.dart';

class SwitchAccountDialog extends StatefulWidget {
  String name;
  String phone;
  String password;
  SwitchAccountDialog(
      {required this.name, required this.phone, required this.password});

  @override
  _SwitchAccountDialogState createState() => _SwitchAccountDialogState();
}

class _SwitchAccountDialogState extends State<SwitchAccountDialog> {
  final SwitchAccountController _switchAccountController = Get.put(SwitchAccountController());

  @override
  void initState() {
    super.initState();
    
    // Setup listeners for state changes
    ever(_switchAccountController.isLoading, (bool loading) {
      if (loading) {
        Loader.show(context, progressIndicator: CustomLoading());
      } else {
        Loader.hide();
      }
    });

    ever(_switchAccountController.success, (bool success) {
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ResourcesScreen(),
          ),
          (route) => false,
        );
      }
    });

    ever(_switchAccountController.errorList, (List errors) {
      if (errors.isNotEmpty) {
        errors.forEach((element) {
          ComFunctions.showToast(text: element.toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Constants.blueColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Column(
                    children: [
                      Text(
                        "Login with".tr(),
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        widget.name,
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ],
                  )),
                ),
              ),
              onTap: () {
                _switchAccountController.switchAccount(
                    phone: widget.phone, password: widget.password);
              },
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),
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
                Spacer()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
