import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide Trans;
import 'package:Fulgox/controllers/signup_controller.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/ui/common/Confirmation.dart';
import 'package:Fulgox/ui/common/Login.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/utilities/comFunctions.dart';
import 'package:Fulgox/utilities/fieldValidations.dart';

class SignUpScreen extends StatefulWidget {
  ResourcesData? resourcesData;

  final UserRepository? userRepository;

  SignUpScreen({this.userRepository, this.resourcesData});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignupController _signupController = Get.put(SignupController());

  // LoginBloc? _loginBloc;
  // AuthenticationBloc? _authenticationBloc;

  UserRepository? get _userRepository => widget.userRepository;

  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _fNameController = TextEditingController();
  final _lNameController = TextEditingController();
  final _vatNumberController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _bankController = TextEditingController();
  final _ibanController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _phoneController = TextEditingController();

  var _formKey = GlobalKey<FormState>();
  bool hasAddress = false;

  double? width, height, screenWidth, screenHeight;

  bool? checkBox;
  bool? rebuild;
  FocusNode? nameFocus;
  FocusNode? idFocus;
  FocusNode? fNameFocus;
  FocusNode? lNameFocus;
  FocusNode? phoneFocus;
  FocusNode? passwordFocus;
  FocusNode? passwordConfFocus;
  FocusNode? vatNumberFocus;
  FocusNode? companyNameFocus;
  bool startValidation = false;

  bool addingAddress = false;
  List<String> citiesNames = [];
  List<Addresses> addressDataList = [];

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern as String);
    return (!regex.hasMatch(value)) ? false : true;
  }

  bool phoneValidation(String value) {
    if (value.length == 9 && value.characters.first == '5') {
      return true;
    }
    return false;
  }

  bool validatePassword(String? value) {
    if (_passwordController.text == _passwordConfirmationController.text) {
      return true;
    }
    return false;
  }


  @override
  void initState() {
    nameFocus = FocusNode();
    phoneFocus = FocusNode();
    passwordFocus = FocusNode();
    passwordConfFocus = FocusNode();
    fNameFocus = FocusNode();
    lNameFocus = FocusNode();
    idFocus = FocusNode();
    vatNumberFocus = FocusNode();
    companyNameFocus = FocusNode();

    checkBox = false;
    addingAddress = false;
    super.initState();
  }

  @override
  void dispose() {
    nameFocus!.dispose();
    phoneFocus!.dispose();
    passwordFocus!.dispose();
    passwordConfFocus!.dispose();
    fNameFocus!.dispose();
    lNameFocus!.dispose();
    super.dispose();
  }

  _onLoginButtonPressed() {
    startValidation = true;
    if (_formKey.currentState!.validate()) {
      _signupController.register(
          password: _passwordController.text.toString(),
          phone: _phoneController.text.toString(),
          name: _nameController.text.toString(),
          firstName: _fNameController.text.toString(),
          lastName: _lNameController.text.toString(),
          nationalId: _idController.text.toString(),
          vatNumber: _vatNumberController.text.toString(),
          companyName: _companyNameController.text.toString());
    }
  }

  final _arCodeController = TextEditingController();
  final _enCodeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    width = size.width;

    height = size.height;
    _enCodeController.text = '+966';
    _arCodeController.text = '966+';
    // SignUpBloc signUpBloc = BlocProvider.of<SignUpBloc>(context);

    return Scaffold(
      body: Obx(() {
        if (_signupController.isLoading.value) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            ComFunctions.ProgressDialog(context);
          });
        } else {
          // If not loading, try to pop the progress dialog if it was open
          // This is a bit tricky with GetX + local context dialogs
          // but usually Navigator.pop(context) is called in success/error
        }

        if (_signupController.signupSuccess.value) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            Navigator.pop(context); // Pop loading dialog
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ConfirmationScreen(
                          resourcesData: widget.resourcesData,
                          phone: _phoneController.text,
                          password: _passwordController.text,
                          name: _nameController.text,
                          firstName: _fNameController.text,
                          lastName: _lNameController.text,
                          nationalId: _idController.text,
                          companyName: _companyNameController.text,
                          vatNumber: _vatNumberController.text,
                        )));
            _signupController.reset();
          });
        }

        if (_signupController.errorType.value.isNotEmpty) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            Navigator.pop(context); // Pop loading dialog
            if (_signupController.errorType.value == 'TIMEOUT') {
              GeneralHandler.handleNetworkError(context);
            } else if (_signupController.errorType.value == 'needUpdate') {
              GeneralHandler.handleNeedUpdateState(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Container(
                    width: screenWidth,
                    height: screenHeight! * 0.1,
                    child: ListView.builder(
                      itemCount: _signupController.errors.length,
                      itemBuilder: (context, i) {
                        return Text(_signupController.errors[i]);
                      },
                    ),
                  ),
                ),
              );
            }
            _signupController.errorType.value = ''; // Clear error
          });
        }

        return CreateSignUpScreen();
      }),
    );
  }

  Widget CreateSignUpScreen() {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Stack(
              children: [
                Container(
                  height: 30,
                  color: Constants.blueColor,
                ),
                Container(
                  width: screenWidth,
                  height: screenHeight! * 0.3,
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
                                    builder: (context) => LoginScreen(
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
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: screenHeight! * 0.05),
                  child: Column(
                    children: [
                      Text('Create an Account For Free'.tr(),
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                              fontFamily: 'Cairo')),
                      SizedBox(
                        height: screenHeight! * 0.03,
                      ),
                      Container(
                        child: TextFormField(
                          focusNode: nameFocus,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).requestFocus(fNameFocus);
                          },
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Please enter your store name'.tr();
                            }
                            if (value.contains(' ')) {
                              return 'Store can not contain spaces'.tr();
                            }
                            if (!FieldValidation.validaStoreName(value)) {
                              return 'Store can not contain arabic letters'
                                  .tr();
                            }
                            return null;
                          },
                          onChanged: (e) {
                            if (startValidation) {
                              _formKey.currentState!.validate();
                            }
                          },
                          decoration: kTextFieldDecoration.copyWith(
                            prefixIcon: Icon(
                              MdiIcons.store,
                              color: Constants.blueColor,
                              size: 20,
                            ),
                            labelText: 'Store Name'.tr(),
                          ),
                          controller: _nameController,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              child: TextFormField(
                                focusNode: fNameFocus,
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context)
                                      .requestFocus(lNameFocus);
                                },
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your first name'.tr();
                                  }
                                  return null;
                                },
                                onChanged: (e) {
                                  if (startValidation) {
                                    _formKey.currentState!.validate();
                                  }
                                },
                                decoration: kTextFieldDecoration.copyWith(
                                  prefixIcon: Icon(
                                    MdiIcons.account,
                                    color: Constants.blueColor,
                                    size: 20,
                                  ),
//                                  ImageIcon(
//                                    AssetImage('assets/images/user.png'),
//                                    color:Color(0xFF414141),
//                                  ) ,
                                  labelText: 'First Name'.tr(),
                                ),
                                controller: _fNameController,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              child: TextFormField(
                                focusNode: lNameFocus,
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context)
                                      .requestFocus(companyNameFocus);
                                },
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your last name'.tr();
                                  }
                                  return null;
                                },
                                onChanged: (e) {
                                  if (startValidation) {
                                    _formKey.currentState!.validate();
                                  }
                                },
                                decoration: kTextFieldDecoration.copyWith(
                                  prefixIcon: Icon(
                                    MdiIcons.account,
                                    color: Constants.blueColor,
                                    size: 20,
                                  ),
                                  labelText: 'Last Name'.tr(),
                                ),
                                controller: _lNameController,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: TextFormField(
                          focusNode: companyNameFocus,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).requestFocus(vatNumberFocus);
                          },
                          // validator: (String? value) {
                          //   if (value!.isEmpty) {
                          //     return 'Please enter your  nationalid'.tr();
                          //   }
                          //   if(value.length != 10){
                          //     return 'Please enter a valid national id'.tr();
                          //
                          //   }
                          //   return null;
                          // },
                          onChanged: (e) {
                            if (startValidation) {
                              _formKey.currentState!.validate();
                            }
                          },
                          decoration: kTextFieldDecoration.copyWith(
                            prefixIcon: Icon(
                              Icons.work,
                              color: Constants.blueColor,
                              size: 20,
                            ),
                            labelText: 'Company Name'.tr(),
                          ),
                          controller: _companyNameController,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: TextFormField(
                          focusNode: vatNumberFocus,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).requestFocus(idFocus);
                          },
                          // validator: (String? value) {
                          //   if (value!.isEmpty) {
                          //     return 'Please enter your  nationalid'.tr();
                          //   }
                          //   if(value.length != 10){
                          //     return 'Please enter a valid national id'.tr();
                          //
                          //   }
                          //   return null;
                          // },
                          onChanged: (e) {
                            if (startValidation) {
                              _formKey.currentState!.validate();
                            }
                          },
                          decoration: kTextFieldDecoration.copyWith(
                            prefixIcon: Icon(
                              MdiIcons.numeric,
                              color: Constants.blueColor,
                              size: 20,
                            ),
                            labelText: 'Vat number'.tr(),
                          ),
                          controller: _vatNumberController,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: TextFormField(
                          focusNode: idFocus,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).requestFocus(phoneFocus);
                          },
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Please enter your national id'.tr();
                            }
                            if (value.length != 10) {
                              return 'Please enter a valid national id'.tr();
                            }
                            return null;
                          },
                          onChanged: (e) {
                            if (startValidation) {
                              _formKey.currentState!.validate();
                            }
                          },
                          decoration: kTextFieldDecoration.copyWith(
                            prefixIcon: Icon(
                              MdiIcons.idCard,
                              color: Constants.blueColor,
                              size: 20,
                            ),
                            labelText: 'National id'.tr(),
                          ),
                          controller: _idController,
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
                                      if (!phoneValidation(
                                          _phoneController.text)) {
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
                                    focusNode: phoneFocus,
                                    onFieldSubmitted: (v) {
                                      FocusScope.of(context)
                                          .requestFocus(passwordFocus);
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
                                    onChanged: (e) {
                                      if (startValidation) {
                                        _formKey.currentState!.validate();
                                      }
                                    },
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(9),
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: kTextFieldDecoration.copyWith(
                                      labelText: 'phone number'.tr(),
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
                                    focusNode: phoneFocus,
                                    keyboardType: TextInputType.number,
                                    onFieldSubmitted: (v) {
                                      FocusScope.of(context)
                                          .requestFocus(passwordFocus);
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
                                    onChanged: (e) {
                                      if (startValidation) {
                                        _formKey.currentState!.validate();
                                      }
                                    },
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(9),
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: kTextFieldDecoration.copyWith(
                                      labelText: 'phone number'.tr(),
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
                                      if (!phoneValidation(
                                          _phoneController.text)) {
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
                        height: 15,
                      ),
                      Container(
                        child: TextFormField(
                          focusNode: passwordFocus,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context)
                                .requestFocus(passwordConfFocus);
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
                          onChanged: (e) {
                            if (startValidation) {
                              _formKey.currentState!.validate();
                            }
                          },
                          decoration: kTextFieldDecoration.copyWith(
                            labelText: 'password'.tr(),
                            // prefixIcon: Icon(
                            //   MdiIcons.lock,
                            //   color: Color(0xFF414141),
                            //   size: 20,
                            // ),
//                                ImageIcon(
//                                  AssetImage('assets/images/key.png'),
//                                  color: Color(0xFF414141),
//                                  size: 10,
//                                ),
                          ),
                          controller: _passwordController,
                          obscureText: true,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: TextFormField(
                          focusNode: passwordConfFocus,
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'please confirm your password'.tr();
                            }
                            if (!validatePassword(value)) {
                              return 'password and confirmation not match'.tr();
                            }
                            return null;
                          },
                          onChanged: (e) {
                            if (startValidation) {
                              _formKey.currentState!.validate();
                            }
                          },
                          decoration: kTextFieldDecoration.copyWith(
                              // prefixIcon: Icon(
                              //   MdiIcons.lock,
                              //   color: Color(0xFF414141),
                              //   size: 20,
                              // ),
//                                  ImageIcon(
//                                    AssetImage('assets/images/key.png'),
//                                    color: Color(0xFF414141),
//                                    size: 10,
//                                  ),
                              labelText: 'password confirmation'.tr()),
                          controller: _passwordConfirmationController,
                          obscureText: true,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: ButtonTheme(
                minWidth: screenWidth!,
                height: 50,
                child: ElevatedButton(
                    child: Text(
                      'Register'.tr(),
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    onPressed: () {
                      _onLoginButtonPressed();
                    }),
              ),
            ),
            SizedBox(
              height: 20,
            )
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
