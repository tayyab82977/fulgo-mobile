import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:get/get.dart' hide Trans;
import 'package:Fulgox/controllers/login_controller.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/data_providers/models/seversListModerl.dart';
import 'package:Fulgox/ui/Client/shipmentTracking.dart';
import 'package:Fulgox/ui/common/SignUp.dart';
import 'package:Fulgox/ui/custom%20widgets/custom_loading.dart';
import 'package:Fulgox/ui/common/passwordResetScreen.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/utilities/URLs.dart';

import 'chooseLanguageScreen.dart';
import 'dashboard.dart';

class LoginScreen extends StatefulWidget {
  ResourcesData? resourcesData;
  String? username;
  final UserRepository? userRepository;

  LoginScreen({this.userRepository, this.resourcesData, this.username});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

bool phoneValidation(String value) {
  if (value.length == 9 && value.characters.first == '5') {
    return true;
  }
  return false;
}

class _LoginScreenState extends State<LoginScreen> {
  var _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _arCodeController = TextEditingController();
  final _enCodeController = TextEditingController();
  final customServerName = TextEditingController();
  final customServerValue = TextEditingController();

  FocusNode? phoneFocusNode;
  FocusNode? passwordFocusNode;
  bool startValidation = false;

  UserRepository? get _userRepository => widget.userRepository;

  final LoginController _loginController = Get.put(LoginController());
  UserRepository userRepository = UserRepository();
  String? username;

  double screenHeight = 0, screenWidth = 0;

  _onLoginButtonPressed() {
    startValidation = true;
    if (_formKey.currentState!.validate()) {
      _loginController.login(
          phone: _phoneController.text, password: _passwordController.text);
    }
  }

  String live = URL.LIVE_SERVER;

  ServerListModel? _selectedServer;

  List<ServerListModel> servers = [];
  List<ServerListModel> savedServers = [];

  ServerListModel liveServer =
      new ServerListModel(serverName: 'Live', serverValue: URL.LIVE_SERVER);

  ServerListModel customServer =
      new ServerListModel(serverName: 'Other', serverValue: "");

  loadingServerList() async {
    customServerValue.text = "http://192.168.1.201:2222/api/";

    servers.add(liveServer);
    servers.add(customServer);

    _selectedServer = servers.first;
    // EventsAPIs.url = _selectedServer.serverValue;
  }

  @override
  void dispose() {
    passwordFocusNode!.dispose();
    phoneFocusNode!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // loadingServerList();
    phoneFocusNode = FocusNode();
    passwordFocusNode = FocusNode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _phoneCodeController.text = '+966';
    _enCodeController.text = '+966';
    _arCodeController.text = '966+';

    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return Scaffold(
      body: Obx(() {
        if (_loginController.loginSuccess.value) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ResourcesScreen(
                        resourcesData: widget.resourcesData,
                      )),
              (route) => false,
            );
            _loginController.reset(); // Reset state after navigation
          });
        }

        if (_loginController.errorMessage.value.isNotEmpty) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            if (_loginController.errorMessage.value == 'TIMEOUT') {
              GeneralHandler.handleNetworkError(context);
            } else if (_loginController.errorMessage.value == 'needUpdate') {
              GeneralHandler.handleNeedUpdateState(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'please check the mobile number and password or contact the customer services'
                          .tr()),
                  backgroundColor: Colors.red,
                ),
              );
            }
            _loginController.errorMessage.value = ''; // Clear error
          });
        }

        return CreateLoginScreen(loading: _loginController.isLoading.value);
      }),
    );
  }

  Widget CreateLoginScreen({required bool loading}) {
    return Scaffold(
      backgroundColor: Color(0xFFe4e4e4),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            Stack(
              children: [
                Container(
                  height: 20,
                  color: Constants.blueColor,
                ),
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.3,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('assets/images/loginTop.png'),
                    fit: BoxFit.fill,
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment:
                          EasyLocalization.of(context)?.currentLocale ==
                                  Locale("en")
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        IconButton(
                          icon: EasyLocalization.of(context)?.currentLocale ==
                                  Locale("en")
                              ? Icon(Icons.arrow_back_ios)
                              : Icon(Icons.arrow_forward_ios),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChooseLanguageScreen(
                                          resourcesData: widget.resourcesData,
                                        )));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: screenHeight * 0.02,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Welcome'.tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 50,
                          color: Constants.blueColor,
                          fontFamily: 'Cairo')),
                  Text('Log in to your account'.tr(),
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontFamily: 'Cairo')),
                  SizedBox(
                    height: screenHeight * 0.03,
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
                                    contentPadding: EdgeInsets.all(0),
                                    hintText: ''),
                                controller: _enCodeController,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                key: const ValueKey('phoneLogin'),
                                focusNode: phoneFocusNode,
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context)
                                      .requestFocus(passwordFocusNode);
                                },
                                onChanged: (e) {
                                  if (startValidation) {
                                    _formKey.currentState!.validate();
                                  }
                                },
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your mobile'.tr();
                                  }
                                  if (!phoneValidation(value)) {
                                    return 'please enter a valid mobile number'
                                        .tr();
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
                                key: const ValueKey('phoneLogin'),
                                focusNode: phoneFocusNode,
                                keyboardType: TextInputType.number,
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context)
                                      .requestFocus(passwordFocusNode);
                                },
                                onChanged: (e) {
                                  if (startValidation) {
                                    _formKey.currentState!.validate();
                                  }
                                },
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your mobile'.tr();
                                  }
                                  if (!phoneValidation(value)) {
                                    return 'please enter a valid mobile number'
                                        .tr();
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
                                    contentPadding: EdgeInsets.all(0),
                                    hintText: ''),
                                controller: _arCodeController,
                              ),
                            ),
                          ],
                        ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  Container(
                    child: TextFormField(
                      key: const ValueKey('passWordLogin'),
                      focusNode: passwordFocusNode,
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'please enter your password'.tr();
                        }

                        return null;
                      },
                      onChanged: (e) {
                        if (startValidation) {
                          _formKey.currentState!.validate();
                        }
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'password'.tr(),
                        // prefixIcon:Icon(MdiIcons.lock , color:Color(0xFF414141), size: 20,),
                      ),
                      controller: _passwordController,
                      obscureText: true,
                      onFieldSubmitted: (v) {
                        _onLoginButtonPressed();
                      },
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResetPassword()));
                        },
                        child: Text(
                          'Forgot password ?'.tr(),
                          style: TextStyle(
                              color: Constants.blueColor,
                              fontWeight: FontWeight.bold),
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
                    child: ElevatedButton(
                        key: const ValueKey('loginButton'),
                        child: Text(
                          'Log In'.tr(),
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        onPressed: () {
                          _onLoginButtonPressed();
                        }),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  loading
                      ? CustomLoading()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Do not have account'.tr(),
                              style: TextStyle(
                                  color: Constants.blueColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '? '.tr(),
                              style: TextStyle(
                                  color: Constants.blueColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                                child: Text(
                                  'Register'.tr(),
                                  style: TextStyle(
                                      color: Constants.blueColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUpScreen(
                                                resourcesData:
                                                    widget.resourcesData,
                                              )));
                                }),
                          ],
                        ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                  ButtonTheme(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShipmentTracking(
                                      showBottomBar: false,
                                    )));
                      },
                      child: Container(
                        width: screenWidth * 0.85,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),

                            // color: Colors.red.shade400
                            // color: Color(0xFFBC2A27)
                            color: Colors.white),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Shipments Tracking'.tr(),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            SvgPicture.asset(
                              "assets/images/route.svg",
                              color: Colors.black,
                              placeholderBuilder: (context) => CustomLoading(),
                              height: 25.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: screenHeight * 0.05,
            ),
          ]),
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
