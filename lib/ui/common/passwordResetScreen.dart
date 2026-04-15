import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Fulgox/controllers/reset_password_controller.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:Fulgox/ui/common/Login.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/ui/common/dashboard.dart';
import 'package:Fulgox/utilities/Constants.dart';

import '../custom widgets/NetworkErrorView.dart';
import '../custom widgets/custom_loading.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  double screenHeight = 0, screenWidth = 0;

  final ResetPasswordController controller = Get.put(ResetPasswordController());
  final _phoneController = TextEditingController();

  final _enCodeController = TextEditingController();
  final _arCodeController = TextEditingController();

  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool timerStarted = false;
  String? phone;

  var _formKey = GlobalKey<FormState>();

  bool phoneValidation(String value) {
    if (value.length == 9 && value.characters.first == '5') {
      return true;
    }
    return false;
  }

  bool validatePassword(String? value) {
    if (_passwordController.text == _newPasswordController.text) {
      return true;
    }
    return false;
  }

  late Timer _timer;
  int _startMinute = 1;
  int _startSec = 59;

  FocusNode codeNode = FocusNode();
  FocusNode newPasswordNode = FocusNode();
  FocusNode newPasswordConfNode = FocusNode();

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          _startSec = _startSec - 1;
          if (_startSec == 0 && _startMinute != 0) {
            _startMinute = 0;
            _startSec = 60;
          }

          if (_startSec == 0 && _startMinute == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LoginScreen(),
              ),
              (route) => false,
            );
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Listeners for side effects
    ever(controller.codeSent, (bool sent) {
      if (sent) {
        timerStarted = true;
        startTimer();
      }
    });

    ever(controller.errorMessage, (String error) {
      if (error.isNotEmpty) {
        if (error == 'codeNotSent' || error == 'noChangePass') {
          if (controller.errorList.isNotEmpty) {
            _onWidgetDidBuild(context, () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(controller.errorList.first.toString()),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }
        } else if (error == "TIMEOUT") {
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
      }
    });

    ever(controller.passwordChanged, (bool changed) {
      if (changed) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => ResourcesScreen()),
          (route) => false,
        );
      }
    });

    ever(controller.passwordSemiChanged, (bool changed) {
      if (changed) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => LoginScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    if (timerStarted) {
      _timer.cancel();
    }
    codeNode.dispose();
    newPasswordNode.dispose();
    newPasswordConfNode.dispose();
    // Get.delete<ResetPasswordController>(); // Optional, dependent on lifecycle needs
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;

    _enCodeController.text = '+966';
    _arCodeController.text = '966+';
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
        child: Column(
          children: [
            EasyLocalization.of(context)!.locale == Locale('en')
                ? Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Hero(
                      tag: 'appLogo',
                      child: Image.asset(
                        'assets/images/appstore.png',
                        width: screenWidth * 0.55,
                        colorBlendMode: BlendMode.darken,
                        // fit: BoxFit.fitWidth,
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Hero(
                      tag: 'appLogo',
                      child: Image.asset(
                        'assets/images/logo-ar.png',
                        width: screenWidth * 0.55,

                        colorBlendMode: BlendMode.darken,
                        // fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
            SizedBox(
              height: screenHeight * 0.05,
            ),
            Text(
              'Reset Password'.tr(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: screenHeight * 0.05,
            ),
            Expanded(child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CustomLoading());
              }
              if (controller.codeSent.value) {
                return CreateChangePasswordScreen();
              }
              if (controller.errorMessage.value == 'noChangePass') {
                return CreateChangePasswordScreen();
              }
              // Default
              return CreateIntialScreen();
            })),
          ],
        ),
      ),
    );
  }

  Widget CreateIntialScreen() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: Colors.black54,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Back'.tr(),
                    style: TextStyle(color: Colors.black54, fontSize: 20),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            EasyLocalization.of(context)!.locale == Locale('en')
                ? Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          readOnly: true,
                          validator: (String? value) {
                            if (_phoneController.text.isEmpty) {
                              return '';
                            }
                            if (!phoneValidation(_phoneController.text)) {
                              return '';
                            }
                            return null;
                          },
                          textAlign: TextAlign.center,
                          decoration: kTextFieldDecoration.copyWith(
                              contentPadding: EdgeInsets.all(0), hintText: ''),
                          controller: _enCodeController,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          onFieldSubmitted: (v) {
                            if (_formKey.currentState!.validate()) {
                              phone = _phoneController.text;
                              controller.getCode(phone: _phoneController.text);
                            }
                          },
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Please enter your mobile'.tr();
                            }
                            if (!phoneValidation(value)) {
                              return 'please enter a valid mobile number'.tr();
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(9),
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: 'phone number'.tr(),
                          ),
                          controller: _phoneController,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          // focusNode: phoneFocusNode,
                          keyboardType: TextInputType.number,
                          onFieldSubmitted: (v) {
                            if (_formKey.currentState!.validate()) {
                              phone = _phoneController.text;
                              controller.getCode(phone: _phoneController.text);
                            }
                          },

                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Please enter your mobile'.tr();
                            }
                            if (!phoneValidation(value)) {
                              return 'please enter a valid mobile number'.tr();
                            }
                            return null;
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(9),
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: 'phone number'.tr(),
                          ),
                          controller: _phoneController,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          readOnly: true,
                          validator: (String? value) {
                            if (_phoneController.text.isEmpty) {
                              return '';
                            }
                            if (!phoneValidation(_phoneController.text)) {
                              return '';
                            }
                            return null;
                          },
                          textAlign: TextAlign.center,
                          decoration: kTextFieldDecoration.copyWith(
                              contentPadding: EdgeInsets.all(0), hintText: ''),
                          controller: _arCodeController,
                        ),
                      ),
                    ],
                  ),
            SizedBox(
              height: screenHeight * 0.02,
            ),
            ButtonTheme(
              minWidth: screenWidth * 0.85,
              height: 50,
              child: CustomButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(color: Colors.grey)),
                  color: Constants.blueColor,
                  child: Text(
                    'Phone verification'.tr(),
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      phone = _phoneController.text;
                      controller.getCode(phone: _phoneController.text);
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget CreateChangePasswordScreen() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: Colors.black54,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Cancel'.tr(),
                        style: TextStyle(color: Colors.black54, fontSize: 20),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone verification code'.tr()),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: TextFormField(
                          onFieldSubmitted: (v) {
                            FocusScope.of(context)
                                .requestFocus(newPasswordNode);
                          },
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Please enter the code'.tr();
                            }
                            return null;
                          },
                          decoration: kTextFieldDecoration2.copyWith(
                            hintText: '',
                            hintStyle: TextStyle(
                              fontSize: 11,
                            ),
                            prefixIcon: Icon(
                              MdiIcons.lock,
                              color: Color(0xFF414141),
                              size: 20,
                            ),
//                                ImageIcon(
//                                  AssetImage('assets/images/key.png'),
//                                  color: Color(0xFF414141),
//                                  size: 10,
//                                ),
                          ),
                          controller: _codeController,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New Password'.tr()),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: TextFormField(
                          focusNode: newPasswordNode,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context)
                                .requestFocus(newPasswordConfNode);
                          },
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'please enter your password'.tr();
                            }
                            if (!validatePassword(value)) {
                              return 'password and confirmation not match'.tr();
                            }
                            return null;
                          },
                          decoration: kTextFieldDecoration2.copyWith(
                            hintText: '',
                            hintStyle: TextStyle(
                              fontSize: 11,
                            ),
                            prefixIcon: Icon(
                              MdiIcons.keyVariant,
                              color: Color(0xFF414141),
                              size: 20,
                            ),
                          ),
                          controller: _passwordController,
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New Password confirmation'.tr()),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: TextFormField(
                          focusNode: newPasswordConfNode,
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'please confirm your password'.tr();
                            }
                            if (!validatePassword(value)) {
                              return 'password and confirmation not match'.tr();
                            }
                            return null;
                          },
                          decoration: kTextFieldDecoration2.copyWith(
                            prefixIcon: Icon(
                              MdiIcons.keyVariant,
                              color: Color(0xFF414141),
                              size: 20,
                            ),
                            hintText: '',
                            hintStyle: TextStyle(
                              fontSize: 11,
                            ),
                          ),
                          controller: _newPasswordController,
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                EasyLocalization.of(context)!.locale == Locale('en')
                    ? Center(
                        child: Text(
                        '$_startMinute : $_startSec',
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ))
                    : Center(
                        child: Text(
                        '$_startSec  : $_startMinute',
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      )),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                ButtonTheme(
                  minWidth: screenWidth * 0.85,
                  height: 50,
                  child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: Colors.transparent)),
                      color: Constants.blueColor,
                      child: Text(
                        'Set new password'.tr(),
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          controller.changeMyPassword(
                              code: _codeController.text,
                              phone: phone ?? "",
                              password: _passwordController.text);
                        }
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onWidgetDidBuild(BuildContext context, Function callback) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      callback();
    });
  }
}
