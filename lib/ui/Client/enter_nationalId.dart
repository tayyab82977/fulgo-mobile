import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Trans;
import 'package:Fulgox/controllers/national_id_controller.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/ui/Client/HomeScreenNew.dart';
import 'package:Fulgox/ui/common/chooseLanguageScreen.dart';
import 'package:Fulgox/ui/custom%20widgets/myAppBar.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/comFunctions.dart';
import 'package:Fulgox/utilities/push_nofitications.dart';

class EnterNationalIdScreen extends StatefulWidget {
  ResourcesData? resourcesData;
  EnterNationalIdScreen({this.resourcesData});

  @override
  _EnterNationalIdScreenState createState() => _EnterNationalIdScreenState();
}

class _EnterNationalIdScreenState extends State<EnterNationalIdScreen> {
  var _formKey = GlobalKey<FormState>();
  double? screenWidth, screenHeight;
  final _valueController = TextEditingController();
  final NationalIdController _nationalIdController =
      Get.put(NationalIdController());
  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;

    return Scaffold(
      backgroundColor: Constants.blueColor,
      body: Obx(() {
        if (_nationalIdController.isLoading.value) {
          // We can show a simple loader or integrate with ProgressHUD if needed
          // but since we are using GetX, we can just overlay a loader in the UI here.
        }

        if (_nationalIdController.success.value) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => NewHomeScreen(
                          dashboardDataModel: SavedData.profileDataModel,
                          resourcesData: widget.resourcesData,
                        )),
                (route) => false);
            _nationalIdController.success.value = false;
          });
        }

        if (_nationalIdController.errorMessage.value == 'error') {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            ComFunctions.showList(
                context: context,
                list: _nationalIdController.errorsList.cast<String>());
            _nationalIdController.errorMessage.value = '';
          });
        }

        return Stack(
          children: [
            Column(
              children: [
                Spacer(),
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/Fulgo_white_icon.png",
                        fit: BoxFit.fill,
                        height: 70,
                        width: 149,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Dialog(
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Please enter your national id".tr(),
                                  style: TextStyle(
                                      color: Constants.blueColor,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Flexible(
                                  child: Container(
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: _valueController,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(10),
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return 'please enter the value'.tr();
                                        }
                                        if (value.length != 10) {
                                          return 'Please enter a valid national id'
                                              .tr();
                                        }
                                        return null;
                                      },
                                      decoration: kTextFieldDecoration.copyWith(
                                        labelText: '',
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _nationalIdController.setNationalId(
                                                _valueController.text);
                                          }
                                        },
                                        child: Text('Save'.tr()),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: ElevatedButton(
                                        onPressed: () async {
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
                                          _authController.logout();
                                          Future.delayed(
                                              const Duration(milliseconds: 1),
                                              () {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ChooseLanguageScreen(),
                                              ),
                                              (route) => false,
                                            );
                                          });
                                        },
                                        child: Text(
                                          'Logout'.tr(),
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
              ],
            ),
            if (_nationalIdController.isLoading.value)
              Container(
                color: Colors.black26,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
          ],
        );
      }),
    );
  }
}
