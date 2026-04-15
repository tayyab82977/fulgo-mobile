import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Fulgox/controllers/phone_confirm_controller.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/ui/common/Login.dart';
import 'package:Fulgox/ui/common/SignUp.dart';
import 'package:Fulgox/ui/custom%20widgets/myAppBar.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/ui/common/successRegister.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import '../custom widgets/custom_loading.dart';

class ConfirmationScreen extends StatelessWidget {
  String? phone;
  String? firstName;
  String? lastName;
  String? password;
  String? name;
  String? nationalId;
  String? companyName;
  String? vatNumber;

  ResourcesData? resourcesData;
  // PhoneConfirmEvents? askForSms; // Removed Bloc event
  ConfirmationScreen({
    // this.askForSms,
    this.resourcesData,
    this.phone,
    this.firstName,
    this.lastName,
    this.password,
    this.name,
    this.nationalId,
    this.companyName,
    this.vatNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Confirmation(
        // askForSms: askForSms,
        resourcesData: resourcesData,
        phone: phone,
        firstName: firstName,
        password: password,
        name: name,
        lastName: lastName,
        nationalId: nationalId,
        companyName: companyName,
        vatNumber: vatNumber,
      ),
    );
  }
}

class Confirmation extends StatefulWidget {
  // PhoneConfirmEvents? askForSms;
  ResourcesData? resourcesData;
  String? phone;
  String? firstName;
  String? lastName;
  String? password;
  String? name;
  String? nationalId;
  String? companyName;
  String? vatNumber;

  Confirmation({
    // this.askForSms,
    this.resourcesData,
    this.phone,
    this.firstName,
    this.password,
    this.name,
    this.lastName,
    this.nationalId,
    this.companyName,
    this.vatNumber,
  });

  @override
  _ConfirmationState createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {
  double? screenWidth, screenHeight;
  final PhoneConfirmController _phoneConfirmController =
      Get.put(PhoneConfirmController());
  var _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  FocusNode codeFocusNode = FocusNode();
  bool showResendBtn = false;

  getProfileData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _phoneController.text = widget.phone ?? '';
  }

  late Timer _timer;
  int _startMinute = 1;
  int _startSec = 59;

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
            setState(() {
              showResendBtn = true;
            });
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    getProfileData();
    // Initially trigger askForSMS if logic required it on start, but Bloc version didn't seem to trigger it in initState explicitly
    // except via passed event in param, but usually it comes after previous screen.
    // If we need to send SMS immediately:
    /*
    _phoneConfirmController.askForSMS(
        phone: widget.phone,
        name: widget.name,
        password: widget.password,
        firstName: widget.firstName,
        lastName: widget.lastName,
        nationalId: widget.nationalId,
        companyName: widget.companyName,
        vatNumber: widget.vatNumber);
     */
     // However, typically the previous screen sends it or this screen sends it.
     // In the Bloc code: phoneConfirmBloc.add(widget.askForSms); was commented out in initState!
  }

  @override
  void dispose() {
    _timer.cancel();
    codeFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _onBackPressed() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => SignUpScreen(
          resourcesData: widget.resourcesData,
        ),
      ),
      (route) => false,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;

    return SafeArea(
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Container(
                  color: Constants.clientBackgroundGrey,
                  child: Obx(() {
                    if (_phoneConfirmController.success.value) {
                      WidgetsBinding.instance?.addPostFrameCallback((_) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  SuccessRegistration()),
                          (route) => false,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Your Phone has been verified'.tr(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                        _phoneConfirmController.reset();
                      });
                    }

                    if (_phoneConfirmController.codeSendingSuccess.value) {
                      WidgetsBinding.instance?.addPostFrameCallback((_) {
                        setState(() {
                             showResendBtn = false;
                            _startMinute = 1;
                            _startSec = 59;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'The code has been sent'.tr(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                         _phoneConfirmController.codeSendingSuccess.value = false; // Reset to avoid loop
                      });
                    }

                    if (_phoneConfirmController.errorMessage.value.isNotEmpty) {
                      WidgetsBinding.instance?.addPostFrameCallback((_) {
                        String error = _phoneConfirmController.errorMessage.value;
                        if (error == 'needUpdate') {
                          GeneralHandler.handleNeedUpdateState(context);
                        } else if (error == "invalidToken") {
                          GeneralHandler.handleInvalidToken(context);
                        } else if (error == 'failedToLogin') {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'please try to login again'.tr(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        } else if (error == 'codeSendingError') {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'error sending the code',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'the code is wrong'.tr(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }
                        _phoneConfirmController.errorMessage.value = '';
                      });
                    }

                    return CreatPhoneConfirmationScreen(
                        loading: _phoneConfirmController.isLoading.value);
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget CreatPhoneConfirmationScreen({required bool loading}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ClientAppBarNoAction(),
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpScreen()));
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
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Phone verification'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 19,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth! * 0.02),
                      child: Container(
                        width: screenWidth! * 0.7,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          readOnly: true,
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Please enter your phone'.tr();
                            }
                            return null;
                          },
                          decoration: kTextFieldDecoration.copyWith(
                            prefixIcon: Icon(
                              Icons.mobile_friendly,
                              color: Color(0xFF414141),
                              size: 20,
                            ),
                            hintText: 'phone number'.tr(),
                          ),
                          controller: _phoneController,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight! * 0.02,
                    ),
                    Container(
                      width: screenWidth! * 0.7,
                      child: Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: Pinput(
                          autofocus: true,
                          focusNode: codeFocusNode,
                          length: 6,
                          onSubmitted: (v) {
                            _phoneConfirmController.codeConfirmation(
                                phone: _phoneController.text,
                                code: _codeController.text);
                          },
                          controller: _codeController,
                          defaultPinTheme: PinTheme(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Constants.blueColor),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          submittedPinTheme: PinTheme(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Constants.blueColor),
                              borderRadius: BorderRadius.circular(15.0),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight! * 0.05,
                    ),
                    showResendBtn
                        ? Container()
                        : EasyLocalization.of(context)!.locale ==
                                Locale('en')
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '$_startMinute : $_startSec',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 20),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '$_startSec  : $_startMinute',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 20),
                                ),
                              ),
                    SizedBox(
                      height: screenHeight! * 0.02,
                    ),
                    showResendBtn
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth! * 0.05),
                            child: ElevatedButton(
                                onPressed: () {
                                  _phoneConfirmController.askForSMS(
                                      phone: widget.phone,
                                      name: widget.name,
                                      password: widget.password,
                                      firstName: widget.firstName,
                                      lastName: widget.lastName,
                                      nationalId: widget.nationalId,
                                      companyName: widget.companyName,
                                      vatNumber: widget.vatNumber);
                                },
                                child: Text(
                                  "Resend the confirmation code".tr(),
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.red,
                                      decoration: TextDecoration.underline),
                                )),
                          )
                        : Container(),
                    loading
                        ? Container(
                            width: screenWidth,
                            height: screenHeight! * 0.2,
                            child: Center(
                              child: CustomLoading(),
                            ),
                          )
                        : Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth! * 0.05),
                                child: SizedBox(
                                  width: screenWidth!,
                                  height: 50,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Constants.blueColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              side: BorderSide(
                                                  color: Colors.grey))),
                                      child: Text(
                                        'Confirm'.tr(),
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () {
                                        _phoneConfirmController
                                            .codeConfirmation(
                                                phone: _phoneController.text,
                                                code: _codeController.text);
                                      }),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onWidgetDidBuild(BuildContext context, Function callback) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      callback();
    });
  }
}
