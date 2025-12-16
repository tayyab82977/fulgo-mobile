import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:xturbox/blocs/bloc/addAcount_bloc.dart';
import 'package:xturbox/blocs/events/addAcount_events.dart';
import 'package:xturbox/blocs/states/addAcount_states.dart';
import 'package:xturbox/ui/common/dashboard.dart';
import 'package:xturbox/ui/custom%20widgets/custom_loading.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/comFunctions.dart';


class AddAccountDialog extends StatefulWidget {
  AddAccountDialog() ;

  @override
  _AddAccountDialogState createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  FocusNode? phoneFocusNode;
  FocusNode? passwordFocusNode;
  bool startValidation = false;
  var _formKey = GlobalKey<FormState>();

  bool phoneValidation(String value) {
    if (value.length == 9 && value.characters.first == '5') {
      return true;
    }
    return false;
  }

  final _arCodeController = TextEditingController();
  final _enCodeController = TextEditingController();

  @override
  void initState() {
    phoneFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _enCodeController.text = '+966';
    _arCodeController.text = '966+';
    return BlocListener<AddAccountBloc,AddAccountStates>(
      listener: (context , state ){
        if(state is AddAccountLoading){
          Loader.show(context,progressIndicator:CustomLoading());
        }else{
          Loader.hide();
        }
        if(state is AddAccountSetSuccess){
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ResourcesScreen(
              ),
            ),
                (route) => false,
          );
        }
        if(state is AddAccountError){
          state.errorList?.forEach((element) {
            ComFunctions.showToast(text: element.tr());
          });
        }
      },
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Adding new account'.tr(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                EasyLocalization.of(context)!.locale == Locale('en') ?
                Row(
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
                SizedBox(height: 10,),
                Container(
                  child: TextFormField(

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
                    },
                  ),
                ),
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Constants.redColor,
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
                            color: Constants.blueColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text("Login".tr(),style: TextStyle(color: Colors.white),)),
                          ),
                        ),
                        onTap: (){
                          if(_formKey.currentState!.validate());
                             BlocProvider.of<AddAccountBloc>(context).add(AddingAccount(phone: _phoneController.text, password: _passwordController.text));
                        },
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
