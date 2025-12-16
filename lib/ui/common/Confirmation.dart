import 'dart:async';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/bloc/phoneConfirm_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/dashboard_events.dart';
import 'package:xturbox/blocs/events/phoneConfirm_events.dart';
import 'package:xturbox/blocs/events/resources_events.dart';
import 'package:xturbox/blocs/states/phoneConfirm_states.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/ui/common/Login.dart';
import 'package:xturbox/ui/common/SignUp.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/ui/common/successRegister.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:xturbox/utilities/comFunctions.dart';

import '../custom widgets/custom_loading.dart';

class ConfirmationScreen extends StatelessWidget {
  String? phone ;
  String? firstName;
  String? lastName;
  String? password;
  String? name;
  String? nationalId;
  String? companyName;
  String? vatNumber;

  ResourcesData? resourcesData ;
  PhoneConfirmEvents? askForSms;
  ConfirmationScreen({this.askForSms , this.resourcesData , this.phone , this.firstName, this.lastName , this.password , this.name , this.nationalId,this.companyName,this.vatNumber});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Confirmation(askForSms: askForSms, resourcesData: resourcesData,phone: phone,firstName: firstName, password: password, name: name,lastName: lastName, nationalId:nationalId,companyName: companyName,vatNumber: vatNumber,),
    );
  }
}

class Confirmation extends StatefulWidget {
  PhoneConfirmEvents? askForSms;
  ResourcesData? resourcesData ;
  String? phone ;
  String? firstName;
  String? lastName;
  String? password;
  String? name;
  String? nationalId;
  String? companyName;
  String? vatNumber;



  Confirmation({this.askForSms , this.resourcesData , this.phone , this.firstName,this.password,this.name,this.lastName,this.nationalId,this.companyName,this.vatNumber});

  @override
  _ConfirmationState createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {
  double? screenWidth ,screenHeight ;
  PhoneConfirmBloc confirmationBloc = PhoneConfirmBloc();
  var _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? phoneNumber;
  FocusNode codeFocusNode = FocusNode();
  bool showResendBtn = false ;

  getProfileData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _phoneController.text = widget.phone!;
  }

  late Timer _timer;
  int _startMinute = 1;
  int _startSec = 59;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec,
          (Timer timer) => setState(
            () {

              _startSec = _startSec - 1;
              if(_startSec == 0 && _startMinute != 0 ){

                _startMinute = 0 ;
                _startSec = 60 ;
              }

              if(_startSec == 0 && _startMinute == 0){
                setState(() {
                  showResendBtn = true ;
                });
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(
                //     builder: (BuildContext context) => SignUpScreen(
                //       resourcesData: widget.resourcesData,
                //     ),
                //   ),
                //       (route) => false,
                // );

              }

            },
      ),
    );
  }

  @override
  void initState() {
    startTimer();
    // phoneConfirmBloc.add(widget.askForSms);
    getProfileData();
    super.initState();
  }
  @override
  void dispose() {
    _timer.cancel();
    codeFocusNode.dispose();
    super.dispose();
  }


  Future<bool> _onBackPressed()async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => SignUpScreen(
          resourcesData: widget.resourcesData,
        ),
      ),
          (route) => false,
    );
    return true ;
  }


  @override
  Widget build(BuildContext context) {
    // PhoneConfirmBloc signUpBloc = BlocProvider.of<PhoneConfirmBloc>(context);

    Size size = MediaQuery.of(context).size;
     screenWidth = size.width;
     screenHeight = size.height;


    return BlocProvider(
      create: (context)=>PhoneConfirmBloc(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: _onBackPressed,
          child: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Constants.clientBackgroundGrey,
                    child: BlocConsumer<PhoneConfirmBloc, PhoneConfirmStates>(
                      bloc: confirmationBloc,
                      builder: (context, state) {
                        if (state is PhoneConfirmInitial) {
                          return CreatPhoneConfirmationScreen(
                            loading: false
                          );
                        }
                        else if (state is PhoneConfirmError) {
                          return CreatPhoneConfirmationScreen(
                            loading: false
                          );
                        }
                        else if (state is PhoneConfirmLoading) {

                          return CreatPhoneConfirmationScreen(
                            loading: true
                          );
                        }
                        else if (state is CodeSendingSuccess) {
                          return CreatPhoneConfirmationScreen(
                            loading: false
                          );
                        }
                        else if (state is FailedToLogin) {
                          return LoginScreen(resourcesData: widget.resourcesData,);
                        }
                        else if (state is CodeSendingError) {

                          return CreatPhoneConfirmationScreen(
                            loading: false
                          );
                        }
                        return Container();
                      },
                      listener: (context, state) {
                        if (state is PhoneConfirmError) {
                         if (state.error == 'needUpdate'){
                           GeneralHandler.handleNeedUpdateState(context);
                        }
                         else if(state.error == "invalidToken"){
                           GeneralHandler.handleInvalidToken(context);
                         }
                          _onWidgetDidBuild(context, () {
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'the code is wrong'.tr(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                        }
                        if (state is PhoneConfirmSuccess) {
                          Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (BuildContext context) => SuccessRegistration()),
                                (route) => false,);
                          _onWidgetDidBuild(context, () {

                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Your Phone has been verified'.tr(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          });
                          // Future.delayed(const Duration(seconds: 1), () {
                          //   Navigator.pushAndRemoveUntil(context,
                          //     MaterialPageRoute(builder: (BuildContext context) => IntroSliderScreen()),
                          //         (route) => false,);
                          // });

                        }
                        if (state is CodeSendingError) {
                          _onWidgetDidBuild(context, () {
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'error sending the code',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                        }
                        if (state is FailedToLogin) {
                          _onWidgetDidBuild(context, () {
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'please try to login again'.tr(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          });
                        }
                        if (state is CodeSendingSuccess) {
                          showResendBtn = false ;
                          _startMinute = 1 ;
                          _startSec = 59 ;
                          _onWidgetDidBuild(context, () {
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'The code has been sent'.tr(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          });
                        }

                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget CreatPhoneConfirmationScreen({required bool loading}){
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
                        onTap: (){
                          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>SignUpScreen(
                          )));
                        },
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back , color: Colors.black54, ),
                            SizedBox(width: 5,),
                            Text('Back'.tr() ,
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 20
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Phone verification'.tr(),style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 19,
                    ),),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth! * 0.02),
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
//                                  ImageIcon(
//                                    AssetImage('assets/images/user.png'),
//                                    color:Color(0xFF414141),
//                                  ) ,
                            hintText: 'phone number'.tr(),
                          ),
                          controller: _phoneController,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight! * 0.02,
                    ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
//                       child: Container(
//                         width: screenWidth * 0.7,
//                         child: TextFormField(
//                           onFieldSubmitted: (v){
//                             signUpBloc.add(CodeConfirmation(
//                                 phone: _phoneController.text, code: _codeController.text));
//                           },
//                           validator: (String value) {
//                             if (value.isEmpty) {
//                               return 'Please enter the code'.tr();
//                             }
//                             return null;
//                           },
//                           decoration: kTextFieldDecoration.copyWith(
//                             prefixIcon: Icon(
//                               MdiIcons.lock,
//                               color: Color(0xFF414141),
//                               size: 20,
//                             ),
// //                                  ImageIcon(
// //                                    AssetImage('assets/images/user.png'),
// //                                    color:Color(0xFF414141),
// //                                  ) ,
//                             hintText: 'code'.tr(),
//                           ),
//                           controller: _codeController,
//                         ),
//                       ),
//                     ),
                   Container(
                     width: screenWidth! * 0.7,

                     child: Directionality(
                       textDirection: ui.TextDirection.ltr,
                       child: PinPut(
                         autofocus: true,
                         focusNode: codeFocusNode,
                       fieldsCount: 6,
                         onSubmit:(v){
                    confirmationBloc.add(CodeConfirmation(
                          phone: _phoneController.text, code: _codeController.text));
                  },
                  controller: _codeController,
                  submittedFieldDecoration: BoxDecoration(
                        border: Border.all(color: Constants.blueColor),
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.white
                  ),
                  selectedFieldDecoration: BoxDecoration(
                        border: Border.all(color: Constants.blueColor),
                        borderRadius: BorderRadius.circular(15.0),
                  ),
                  followingFieldDecoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(15.0),
                  ),
                  ),
                     ),
                   ),
                    SizedBox(
                      height: screenHeight! * 0.05,
                    ),
                showResendBtn? Container() :
                EasyLocalization.of(context)!.locale == Locale('en') ?

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('$_startMinute : $_startSec' , style: TextStyle(color: Colors.red, fontSize: 20),),
                    ) :
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('$_startSec  : $_startMinute' , style: TextStyle(color: Colors.red, fontSize: 20),),
                    ) ,

                    SizedBox(
                      height: screenHeight! * 0.02,
                    ),

            showResendBtn ?
            Padding(
                 padding: EdgeInsets.symmetric(horizontal: screenWidth! * 0.05),
                 child: TextButton(onPressed: (){
                   confirmationBloc.add(AskForSMS(phone: widget.phone , name: widget.name ,password: widget.password,firstName: widget.firstName,lastName: widget.lastName ,nationalId: widget.nationalId,companyName: widget.companyName,vatNumber: widget.vatNumber));
                 },
                     child: Text("Resend the confirmation code".tr(),

                       style: TextStyle(fontSize: 15,color: Colors.red,decoration: TextDecoration.underline),)),
               ) : Container(),
               loading ?
               Container(
                 width: screenWidth,
                 height: screenHeight!*0.2,
                 child: Center(
                   child: CustomLoading(),
                 ),
               )     :
               Column(
                 children: [
                   Padding(
                     padding: EdgeInsets.symmetric(horizontal: screenWidth! * 0.05),
                     child: ButtonTheme(
                       minWidth: screenWidth!,
                       height: 50,
                       child: FlatButton (
                           shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(12.0),
                               side: BorderSide(color: Colors.grey)),
                           color:  Constants.blueColor,
                           padding: EdgeInsets.zero,
                           textColor: Colors.white,
                           child: Text(
                             'Confirm'.tr(),
                             style: TextStyle(
                               fontSize: 17,
                             ),
                           ),
                           onPressed: () {
                             confirmationBloc.add(CodeConfirmation(
                                 phone: _phoneController.text, code: _codeController.text));
                           }),
                     ),
                   ),
                   // Padding(
                   //   padding: EdgeInsets.only(
                   //     top: screenHeight * 0.02,
                   //   ),
                   //   child: MaterialButton(
                   //     child: Text(
                   //       'Resend Code',
                   //       style: TextStyle(
                   //           color: Constants.color1,
                   //           fontSize: 15,
                   //           textBaseline: TextBaseline.alphabetic),
                   //     ),
                   //     onPressed: () {
                   //       signUpBloc.add(AskForSMS(phone: _phoneController.text));
                   //     },
                   //   ),
                   // ),
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
