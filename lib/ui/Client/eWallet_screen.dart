import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:xturbox/blocs/bloc/wallet_bloc.dart';
import 'package:xturbox/blocs/events/wallet_events.dart';
import 'package:xturbox/blocs/states/wallet_states.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/ui/custom%20widgets/custom_loading.dart';
import 'package:xturbox/ui/custom%20widgets/home_button.dart';
import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'dart:ui' as ui;

import '../../utilities/Constants.dart';


class EWalletScreen extends StatefulWidget {
  ResourcesData? resourcesData ;
  EWalletScreen({this.resourcesData});

  @override
  _EWalletScreenState createState() => _EWalletScreenState();
}

class _EWalletScreenState extends State<EWalletScreen> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();


  final _valueController = TextEditingController();

  bool isLoading = false ;

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      barrierEnabled: false,
      backgroundColor: Constants.blueColor,
      child: BlocListener<WalletBloc , WalletStates>(
        listener: (context , state){
          if(state is WalletLoading){
            final progress = ProgressHUD.of(context);
            progress?.show();
            isLoading = true ;
            setState(() {});
          }else{
            final progress = ProgressHUD.of(context);
            progress?.dismiss();
            isLoading = false ;
            setState(() {});
          }

          if(state is WalletSetSuccess){
            _codeController.clear();
            _valueController.clear();
            setState(() {});

          }

          if(state is RequestSuccess){
            _confirmationDialog();

          }
          if(state is WalletError){
           ComFunctions.showList(context: context, list: state.errorList);
          }
        },
        child: Scaffold(
          key: _drawerKey,
          backgroundColor: Constants.clientBackgroundGrey,
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        const ClientAppBar(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/images/wallet.svg",
                              placeholderBuilder: (context) => CustomLoading(),
                              height: 38.0,
                              color: Constants.blueColor,
                            ),
                            SizedBox(width: 15,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Transfer to Wallet'.tr(),
                                  style:TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Constants.blueColor,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Constants.redColor,
                                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft:Radius.circular(20))
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text('Balance'.tr(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w400
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 4,),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: Text(SavedData.profileDataModel.amount.toString(),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 25
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 5,),
                                                Text('SR'.tr() ,
                                                  // AutoSizeText('',
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),


                                          // SizedBox(height: screenHeight*0.005,),


                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Flexible(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Constants.blueColor,
                                                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft:Radius.circular(20))
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text('Wallet'.tr(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w400
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 4,),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(SavedData.profileDataModel.wallet.toString(),
                                                  // AutoSizeText('',
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 25
                                                  ),
                                                ),
                                                SizedBox(width: 5,),
                                                Text('SR'.tr() ,
                                                  // AutoSizeText('',
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),


                                          // SizedBox(height: screenHeight*0.005,),


                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20,),
                              Row(
                                children: [
                                  Text("Transfer amount",style: TextStyle(color: Constants.blueColor , fontSize: 18),),
                                  SizedBox(width: 10,),
                                  Flexible(
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: _valueController,
                                      onChanged: (value){
                                        setState(() {
                                          // _counter = int.tryParse(value) ?? 0 ;
                                        });
                                      },
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(7),
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return 'please enter the value'.tr();
                                        }
                                        if((double.tryParse(value) ?? 0) > SavedData.profileDataModel.amount){
                                          return 'please enter a valid value'.tr();

                                        }
                                        return null;
                                      },
                                      decoration: kTextFieldDecoration.copyWith(
                                        labelText: 'amount'.tr(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ButtonTheme(
                          minWidth: MediaQuery.of(context).size.width,
                          height: 50,
                          child: FlatButton(
                              key: const ValueKey('loginButton'),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              color: Constants.blueColor,
                              textColor: Colors.white,
                              child: Text(
                                'Transfer'.tr(),
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              onPressed: () {
                                if(_formKey.currentState!.validate()){
                                  BlocProvider.of<WalletBloc>(context).add(TransferRequest(value: _valueController.text));
                                }

                              }),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: HomeButton()),
              ],
            ),
          ),
        ),
      ),
    );
  }
  _confirmationDialog(){
    showDialog(
        context: context,
        barrierDismissible: false,

        builder: (context) {
          return TransferConfirmationDialog(amount: _valueController.text , walletBloc:BlocProvider.of<WalletBloc>(context) ,);
        });
  }
}


class TransferConfirmationDialog extends StatefulWidget {
  String amount ;
  WalletBloc walletBloc ;
   TransferConfirmationDialog({required this.amount , required this.walletBloc });

  @override
  _TransferConfirmationDialogState createState() => _TransferConfirmationDialogState();
}

class _TransferConfirmationDialogState extends State<TransferConfirmationDialog> {

  final _codeController = TextEditingController();
  WalletBloc walletBloc = WalletBloc();

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      barrierEnabled: false,
      backgroundColor: Constants.blueColor,
      child: WillPopScope(
        onWillPop: ()async =>false,
        child: BlocProvider(
          create: (context)=>WalletBloc(),
          child: BlocListener<WalletBloc,WalletStates>(
            bloc: walletBloc,
            listener: (context , state){
              if(state is WalletLoading){
                final progress = ProgressHUD.of(context);
                progress?.show();
                setState(() {});
              }else{
                final progress = ProgressHUD.of(context);
                progress?.dismiss();
                setState(() {});
              }

              if(state is WalletSetSuccess){
                Navigator.of(context).pop();
                SavedData.profileDataModel.wallet = state.balanceWallet[1];
                SavedData.profileDataModel.amount = state.balanceWallet[0];
                widget.walletBloc.emit(WalletSetSuccess(balanceWallet: state.balanceWallet));
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content:Text("Done".tr()),backgroundColor: Colors.green,)
                );
              }

              if(state is RequestSuccess){

              }
              if(state is WalletError){
                ComFunctions.showList(context: context, list: state.errorList);
              }
            },
            child:Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              // titlePadding: EdgeInsets.all(0),
              // title: Container(
              //     height: 60.00,
              //     decoration: BoxDecoration(
              //       color: Constants.blueColor,
              //       borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              //     ),
              //     child: Center(
              //       child: Text('Please enter the confirmation code'.tr(),
              //           style: TextStyle(color: Colors.white , fontSize: 15)),
              //     )
              // ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      height: 60.00,
                      decoration: BoxDecoration(
                        color: Constants.blueColor,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                      ),
                      child: Center(
                        child: Text('Please enter the confirmation code'.tr(),
                            style: TextStyle(color: Colors.white , fontSize: 15)),
                      )
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Transfer'.tr(),
                        maxLines: 1,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                       widget.amount,
                        maxLines: 1,
                        style: TextStyle(fontWeight: FontWeight.bold , fontSize: 24),
                      ),

                    ],
                  ),
                  SizedBox(height: 20,),
                  Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: PinPut(
                        autofocus: true,
                        fieldsCount: 6,
                        onSubmit:(v){
                          // BlocProvider.of<WalletBloc>(context).add(TransferConfirm(value: _valueController.text, code: _codeController.text));
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
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: CircularCountDownTimer(
                      duration: 120,
                      initialDuration: 0,
                      controller: CountDownController(),
                      width: 40,
                      height: 40,
                      ringColor: Colors.grey,
                      fillColor: Constants.blueColor,
                      backgroundColor: Colors.white,
                      strokeWidth: 20.0,
                      strokeCap: StrokeCap.round,
                      textStyle: TextStyle(
                          fontSize: 18.0, color: Constants.blueColor, fontWeight: FontWeight.bold),
                      textFormat: CountdownTextFormat.S,
                      isReverse: true,
                      isReverseAnimation: false,
                      isTimerTextShown: true,
                      autoStart: true,
                      onStart: () {
                        print('Countdown Started');
                      },
                      onComplete: () {
                        Navigator.of(context).pop();
                        _codeController.clear();
                      },
                    ),
                  ) ,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Constants.redColor, // background
                          onPrimary: Colors.white, // foreground
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _codeController.clear();
                        },
                        child: Text('Cancel'.tr(),style: TextStyle(fontSize: 12),maxLines: 1,),
                      ),
                      SizedBox(width: 10,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Constants.blueColor, // background
                          onPrimary: Colors.white, // foreground
                        ),
                        onPressed: () {
                         walletBloc.add(TransferConfirm(value: widget.amount, code: _codeController.text));
                        },
                        child: Text('Confirm'.tr(),style: TextStyle(fontSize: 12),maxLines: 1,),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

