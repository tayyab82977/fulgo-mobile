import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:pinput/pinput.dart';
import 'package:Fulgox/controllers/wallet_controller.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/ui/custom%20widgets/custom_loading.dart';
import 'package:Fulgox/ui/custom%20widgets/home_button.dart';
import 'package:Fulgox/ui/custom%20widgets/myAppBar.dart';
import 'package:Fulgox/utilities/comFunctions.dart';
import 'dart:ui' as ui;

import '../../utilities/Constants.dart';

class EWalletScreen extends StatefulWidget {
  ResourcesData? resourcesData;
  EWalletScreen({this.resourcesData});

  @override
  _EWalletScreenState createState() => _EWalletScreenState();
}

class _EWalletScreenState extends State<EWalletScreen> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _valueController = TextEditingController();
  final WalletController _walletController = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      backgroundColor: Constants.clientBackgroundGrey,
      body: Obx(() {
        if (_walletController.requestSuccess.value) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            _confirmationDialog();
            _walletController.requestSuccess.value = false;
          });
        }

        if (_walletController.transferSuccess.value) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            _valueController.clear();
            _walletController.transferSuccess.value = false;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Done".tr()),
              backgroundColor: Colors.green,
            ));
          });
        }

        if (_walletController.errorMessage.value == 'error') {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            ComFunctions.showList(
              context: context, list: _walletController.errorsList.cast<String>());
            _walletController.errorMessage.value = '';
          });
        }

        return Stack(
          children: [
            Form(
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
                                placeholderBuilder: (context) =>
                                    CustomLoading(),
                                height: 38.0,
                                color: Constants.blueColor,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Transfer to Wallet'.tr(),
                                    style: TextStyle(
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
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Constants.redColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
                                                          topLeft:
                                                              Radius.circular(
                                                                  20))),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Balance'.tr(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      SavedData
                                                          .profileDataModel!
                                                          .amount
                                                          .toString(),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 25),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    'SR'.tr(),
                                                    // AutoSizeText('',
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Constants.blueColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
                                                          topLeft:
                                                              Radius.circular(
                                                                  20))),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'Wallet'.tr(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    SavedData.profileDataModel!
                                                        .wallet
                                                        .toString(),
                                                    // AutoSizeText('',
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 25),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    'SR'.tr(),
                                                    // AutoSizeText('',
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Transfer amount",
                                      style: TextStyle(
                                          color: Constants.blueColor,
                                          fontSize: 18),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: _valueController,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(7),
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return 'please enter the value'
                                                .tr();
                                          }
                                          if ((double.tryParse(value) ?? 0) >
                                              SavedData
                                                  .profileDataModel!.amount) {
                                            return 'please enter a valid value'
                                                .tr();
                                          }
                                          return null;
                                        },
                                        decoration:
                                            kTextFieldDecoration.copyWith(
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
                            child: ElevatedButton(
                                key: const ValueKey('loginButton'),
                                child: Text(
                                  'Transfer'.tr(),
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _walletController
                                        .transferRequest(_valueController.text);
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
            if (_walletController.isLoading.value)
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

  _confirmationDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return TransferConfirmationDialog(
            amount: _valueController.text,
          );
        });
  }
}

class TransferConfirmationDialog extends StatefulWidget {
  String amount;
  TransferConfirmationDialog({required this.amount});

  @override
  _TransferConfirmationDialogState createState() =>
      _TransferConfirmationDialogState();
}

class _TransferConfirmationDialogState
    extends State<TransferConfirmationDialog> {
  final _codeController = TextEditingController();
  final WalletController walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        child: Obx(() {
          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      height: 60.00,
                      decoration: BoxDecoration(
                        color: Constants.blueColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32)),
                      ),
                      child: Center(
                        child: Text('Please enter the confirmation code'.tr(),
                            style:
                                TextStyle(color: Colors.white, fontSize: 15)),
                      )),
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Pinput(
                        autofocus: true,
                        length: 6,
                        onCompleted: (v) {
                          // walletController.transferConfirm(widget.amount, _codeController.text);
                        },
                        controller: _codeController,
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
                          fontSize: 18.0,
                          color: Constants.blueColor,
                          fontWeight: FontWeight.bold),
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
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _codeController.clear();
                        },
                        child: Text(
                          'Cancel'.tr(),
                          style: TextStyle(fontSize: 12),
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          walletController.transferConfirm(
                              _codeController.text, widget.amount);
                        },
                        child: Text(
                          'Confirm'.tr(),
                          style: TextStyle(fontSize: 12),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (walletController.isLoading.value)
                Positioned.fill(
                  child: Container(
                    color: Colors.black12,
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.white)),
                  ),
                )
            ],
          );
        }),
      ),
    );
  }
}
