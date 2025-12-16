import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:xturbox/blocs/bloc/nationalId_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/events/nationalId_events.dart';
import 'package:xturbox/blocs/states/nationalId_states.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/ui/Client/HomeScreenNew.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'package:xturbox/utilities/push_nofitications.dart';


class EnterNationalIdScreen extends StatefulWidget {
  ResourcesData? resourcesData ;
  EnterNationalIdScreen({this.resourcesData}) ;

  @override
  _EnterNationalIdScreenState createState() => _EnterNationalIdScreenState();
}

class _EnterNationalIdScreenState extends State<EnterNationalIdScreen> {

  var _formKey = GlobalKey<FormState>();
  double? screenWidth , screenHeight  ;
  final _valueController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;

    return ProgressHUD(
      barrierEnabled: false,
      backgroundColor: Constants.blueColor,
      child: BlocListener<NationalIdBloc , NationalIdStates>(
        listener: (context , state){
          if(state is NationalIdLoading){
            final progress = ProgressHUD.of(context);
            progress?.show();
          }else{
            final progress = ProgressHUD.of(context);
            progress?.dismiss();
          }

          if(state is NationalIdSetSuccess){
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        NewHomeScreen(
                          dashboardDataModel: SavedData.profileDataModel,
                          resourcesData: widget.resourcesData,
                        )
                ),
                    (route) => false);
          }

          if(state is NationalIdError){
            ComFunctions.showList(context: context , list: state.errorList);
          }
        },
        child: Scaffold(
          backgroundColor: Constants.blueColor,
          body: Column(
            children: [
              Spacer(),
              Center(
                child: Column(
                  children: [
                    Image.asset("assets/images/xturbo_white_icon.png",fit: BoxFit.fill, height: 70,width: 149, ),
                    SizedBox(height: 30,),
                    Dialog(
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 20,),
                              Text("Please enter your national id".tr(),style: TextStyle(color: Constants.blueColor,fontWeight: FontWeight.w600),),
                              SizedBox(height: 10,),

                                    Flexible(
                                      child: Container(
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          controller: _valueController,
                                          onChanged: (value){
                                            setState(() {
                                              // _counter = int.tryParse(value) ?? 0 ;
                                            });
                                          },
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(10),
                                            FilteringTextInputFormatter.digitsOnly
                                          ],
                                          validator: (String? value) {
                                            if (value!.isEmpty) {
                                              return 'please enter the value'.tr();
                                            }
                                            if (value.length != 10) {
                                              return 'Please enter a valid national id'.tr();
                                            }
                                            return null;
                                          },
                                          decoration: kTextFieldDecoration.copyWith(
                                            labelText: '',
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 15,),
                                    SizedBox(height: 10,),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex:3,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: Constants.blueColor, // background
                                              onPrimary: Colors.white, // foreground
                                            ),
                                            onPressed: () {
                                              if(_formKey.currentState!.validate()){
                                                BlocProvider.of<NationalIdBloc>(context).add(SetNationalIdValue(value: _valueController.text));
                                              }
                                            },
                                            child: Text('Save'.tr()),
                                          ),
                                        ),
                                        SizedBox(width: 20,),
                                        Expanded(
                                          flex: 2,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: Constants.redColor, // background
                                              onPrimary: Colors.white, // foreground
                                            ),
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
                                            child: Text('Logout'.tr(),style: TextStyle(fontSize: 11),),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 30,),
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
                ),
      ),
    );
  }
}
