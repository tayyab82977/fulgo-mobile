import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:xturbox/blocs/bloc/myPickupActions_bloc.dart';
import 'package:xturbox/blocs/bloc/myPickup_bloc.dart';
import 'package:xturbox/blocs/events/myPickupActions_events.dart';
import 'package:xturbox/blocs/events/myPickup_events.dart';
import 'package:xturbox/blocs/states/myPickupActions_states.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/ui/custom%20widgets/customCheckBox.dart';
import 'package:xturbox/ui/custom%20widgets/custom_loading.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/comFunctions.dart';
import 'dart:ui' as ui;

class DeliverScreen extends StatefulWidget {
  ResourcesData? resourcesData;
  OrdersDataModelMix? ordersDataModel;
  double? payment;
  MyPickupBloc? myPickupBloc;

  DeliverScreen(
      {this.ordersDataModel,
      this.resourcesData,
      this.payment,
      this.myPickupBloc});

  @override
  State<DeliverScreen> createState() => _DeliverScreenState();
}

class _DeliverScreenState extends State<DeliverScreen> {
  double? width, height, screenHeight, screenWidth;
  PaymentMethod? _currentSelectedPaymentMethod;
  bool confirmed = false;
  String receipt = "";
  bool withPayment = true ;
  bool showMsgButton = true ;
  final _codeController = TextEditingController();

  @override
  void initState() {
    if(widget.payment.toString() != 'null' && widget.payment.toString() != "" && widget.payment.toString() != "0"&& widget.payment.toString() != "0.0"){
      withPayment = true ;
    }else {
      withPayment = false ;

    }
    widget.resourcesData?.paymentMethods?.forEach((e) {

      e.isSelected = false ;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return BlocProvider(
        create: (context) => PickupActionsBloc(),
        child: BlocConsumer<PickupActionsBloc, PickupActionsStates>(
          builder: (context, state) {
            if (state is PickupActionsLoading) {
              return buildDeliverScreen(loading: true);
            }
            return buildDeliverScreen(pickupActionsBloc: BlocProvider.of<PickupActionsBloc>(context));
          },
          listener: (context, state) {
            if(state is ReceiptLoadedSuccess){
              receipt = state.receipt ?? "error".tr() ;
            }
            else if (state is PickupActionSuccess || state is PickupActionDispatchIssueSuccess) {
             ComFunctions.showToast(text: "Successfully done".tr() ,color: Colors.green);
              Navigator.pop(context);
              widget.myPickupBloc!.add(GetMyPickup());
            }
            else if (state is MsgSentSuccessfully){
              showMsgButton = false ;
              ComFunctions.showToast(text: "Successfully done".tr() ,color: Colors.green);

            }
            else if (state is PickupActionsFailure){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:Container(
                    height:(state.errorList?.length ?? 1) * 30 ,
                    child: ListView.builder(
                        itemCount: state.errorList?.length,
                        itemBuilder: (context , i){
                          return Text(state.errorList?[i] ?? "error".tr());
                        }),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ));
  }
  // widget.myPickupBloc!.add(GetMyPickup());

  Widget buildDeliverScreen({bool loading = false , PickupActionsBloc? pickupActionsBloc}) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: height,
            decoration: BoxDecoration(
                color: Colors.white,
                // color: Constants.clientBackgroundGrey,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    spreadRadius: 5,
                    blurRadius: 2,
                    offset: Offset(3, 1), // changes position of shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Constants.greyColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  'Deliver'.tr(),
                                  maxLines: 2,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "#"+'${widget.ordersDataModel?.id}',
                                maxLines: 2,
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Constants.greyColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.clear)),
                      ),
                    ],
                  ),
                ),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                    SizedBox(height: 30,),
                    Padding(
                      padding: EdgeInsets.all(width! * 0.02),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Constants.lightRedColor,
                            borderRadius: BorderRadius.circular(15)),
                        height: 50,
                        width: width! * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.payment.toString(),style: TextStyle(fontSize: 22 , color: Colors.red , fontWeight: FontWeight.w700),),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "SR".tr(),
                              style: TextStyle(fontSize: 15),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    (widget.payment ?? 0) > 0 ?
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                              children:(widget.resourcesData?.paymentMethods ?? []).map((item) =>
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10 , vertical: 2),
                                      child: GestureDetector(
                                        onTap: () {
                                          if(item.val2 != "B"){
                                            setState(() {
                                              item.isSelected = !item.isSelected  ;
                                              if(item.isSelected){
                                                _currentSelectedPaymentMethod = item ;
                                                pickupActionsBloc?.add(GetTheReceipt(storeId: widget.ordersDataModel?.pickupStoreId , method: _currentSelectedPaymentMethod?.val2));
                                              }
                                              receipt = "";
                                              confirmed = false ;
                                              widget.resourcesData?.paymentMethods?.forEach((e) {
                                                if(e.id != item.id){
                                                  e.isSelected = false ;
                                                }
                                              });
                                            });
                                          }
                                         },
                                        child: Row(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                Theme(
                                                  data: Theme.of(context).copyWith(
                                                    unselectedWidgetColor:
                                                    Colors.black54,
                                                  ),
                                                  child: SizedBox(
                                                      height: 25,
                                                      width: 25,
                                                      child: CustomCheckBox(
                                                        checkedColor:
                                                        Constants.blueColor,
                                                        unCheckedColor: Constants.greyColor,
                                                        backgroundColor: Constants.greyColor,
                                                        checked: item.isSelected,
                                                      )),
                                                )]),
                                            SizedBox(width: 5,),
                                            Expanded(child: Text(item.name ?? "" ,style: TextStyle(fontSize: 16), )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )

                              ).toList().cast<Widget>()),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20 , vertical: 10 ),
                          child: Container(
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    // color: Color.fromRGBO(120, 135, 198, .3),
                                    color: Color(0xFFdbdbdb),
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  )
                                ],
                                color: Constants.greyColor,
                                border: Border.all(color: Constants.greyColor),
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.receipt , size: 22,),
                                      SizedBox(width: 10,),
                                      Text("receipt number".tr(), style: TextStyle(fontSize: 14),),

                                    ],
                                  ),
                                  receipt != "" ? Text(receipt, style: TextStyle(fontSize: 20 , color: Constants.redColor , fontWeight: FontWeight.w700),) : Container(),

                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ) : SizedBox(),

                  ],
                ),
                if(confirmed && widget.payment == 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Are you sure ?".tr(),
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                   showMsgButton ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: GestureDetector(
                        onTap: (){
                          // pickupActionsBloc?.add(SendConfirmationMsg(
                          //   msgType: "sms",
                          //   receiverId: widget.ordersDataModel?.member,
                          //   receiverPhone: widget.ordersDataModel?.receiverPhone,
                          // ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Send Confirmation code".tr() , style: TextStyle(fontSize: 19 , decoration: TextDecoration.underline),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(onPressed: (){
                                  pickupActionsBloc?.add(SendConfirmationMsg(
                                    msgType: "1",
                                    receiverId: widget.ordersDataModel?.member,
                                    receiverPhone: widget.ordersDataModel?.receiverPhone,
                                  ));
                                }, icon: Icon(MdiIcons.messageArrowLeftOutline) , color: Colors.black, iconSize: 22,),
                                IconButton(onPressed: (){
                                  pickupActionsBloc?.add(SendConfirmationMsg(
                                    msgType: "2",
                                    receiverId: widget.ordersDataModel?.member,
                                    receiverPhone: widget.ordersDataModel?.receiverPhone,
                                  ));
                                }, icon: Icon(MdiIcons.whatsapp) , color: Colors.green, iconSize: 22,),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ) : Padding(
                     padding: const EdgeInsets.all(15.0),
                     child: CircularCountDownTimer(
                       duration: 180,
                       initialDuration: 0,
                       controller: CountDownController(),
                       width: 40,
                       height: 40,
                       ringColor: Colors.grey,
                       ringGradient: null,
                       fillColor: Constants.blueColor,
                       fillGradient: null,
                       backgroundColor: Colors.white,
                       backgroundGradient: null,
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
                         setState(() {
                           showMsgButton = true ;
                         });
                       },
                     ),
                   ),
                    Container(
                      width: width! * 0.7,
                      child: Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: PinPut(
                          autofocus: false,
                          fieldsCount: 6,
                          onSubmit:(v){

                          },
                          controller: _codeController,
                          submittedFieldDecoration: BoxDecoration(
                              border: Border.all(color: Constants.blueColor),
                              borderRadius: BorderRadius.circular(15.0),
                              color: Colors.white
                          ),
                          selectedFieldDecoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          followingFieldDecoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ) else if (confirmed && receipt != "") Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Are you sure ?".tr(),
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                   showMsgButton ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Send Confirmation code".tr() , style: TextStyle(fontSize: 19 , decoration: TextDecoration.underline),),
                          Row(
                            children: [
                              IconButton(onPressed: (){
                                pickupActionsBloc?.add(SendConfirmationMsg(
                                  msgType: "1",
                                  receiverId: widget.ordersDataModel?.member,
                                  receiverPhone: widget.ordersDataModel?.receiverPhone,
                                ));
                              }, icon: Icon(MdiIcons.messageArrowLeftOutline) , color: Colors.black, iconSize: 22,),
                              IconButton(onPressed: (){
                                pickupActionsBloc?.add(SendConfirmationMsg(
                                  msgType: "2",
                                  receiverId: widget.ordersDataModel?.member,
                                  receiverPhone: widget.ordersDataModel?.receiverPhone,
                                ));
                              }, icon: Icon(MdiIcons.whatsapp) , color: Colors.green, iconSize: 22,),
                            ],
                          ),

                        ],
                      ),
                    ) :
                   Padding(
                     padding: const EdgeInsets.all(15.0),
                     child: CircularCountDownTimer(
                       duration: 180,
                       initialDuration: 0,
                       controller: CountDownController(),
                       width: 40,
                       height: 40,
                       ringColor: Colors.grey,
                       ringGradient: null,
                       fillColor: Constants.blueColor,
                       fillGradient: null,
                       backgroundColor: Colors.white,
                       backgroundGradient: null,
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
                         setState(() {
                           showMsgButton = true ;
                         });
                       },
                     ),
                   ),
                    Container(
                      width: width! * 0.7,
                      child: Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: PinPut(
                          autofocus: false,
                          fieldsCount: 6,
                          onSubmit:(v){

                          },
                          controller: _codeController,
                          submittedFieldDecoration: BoxDecoration(
                              border: Border.all(color: Constants.blueColor),
                              borderRadius: BorderRadius.circular(15.0),
                              color: Colors.white
                          ),
                          selectedFieldDecoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          followingFieldDecoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ) else SizedBox(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15 , vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(!confirmed && widget.payment == 0)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Constants.blueColor, // background
                            onPrimary: Colors.white, // foreground
                          ),
                          onPressed: () {
                            setState(() {
                              confirmed = true;
                            });
                          },
                          child: Text('ok'.tr()),
                        ) else if (!confirmed && receipt != "")
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Constants.blueColor, // background
                          onPrimary: Colors.white, // foreground
                        ),
                        onPressed: () {
                          setState(() {
                            confirmed = true;
                          });
                        },
                        child: Text('ok'.tr()),
                      ) else SizedBox(),
                      // TextButton(
                      //   child: Text('ok'.tr()),
                      //   onPressed: () {
                      //     setState(() {
                      //       confirmed = true;
                      //     });
                      //   },
                      // ),

                      if(confirmed && widget.payment == 0)
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
                              },
                              child: Text('Cancel'.tr()),
                            ),
                            SizedBox(width: 70,),
                            loading ? CustomLoading()  :
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Constants.blueColor, // background
                                onPrimary: Colors.white, // foreground
                              ),
                              onPressed: () {
                                if(_codeController.text.length != 6){
                                  //Please enter the code
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:Text("Please enter the code".tr()),
                                        dismissDirection: DismissDirection.vertical,
                                        duration: Duration(seconds: 1),
                                        backgroundColor: Colors.red),
                                  );
                                }
                                else{
                                  pickupActionsBloc?.add(DeliverShipment(
                                      id: widget.ordersDataModel?.id,
                                      amount: widget.payment.toString(),
                                      code :_codeController.text,
                                      paymentMethodId: _currentSelectedPaymentMethod?.id,
                                      receipt: receipt));
                                }

                              },
                              child: Text('Yes'.tr()),
                            ),

                          ],
                        ) else if ( confirmed && receipt != "" )Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Constants.redColor, // background
                              onPrimary: Colors.white, // foreground
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'.tr()),
                          ),
                          SizedBox(width: 70,),
                          loading ? CustomLoading()  :
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Constants.blueColor, // background
                              onPrimary: Colors.white, // foreground
                            ),
                            onPressed: () {
                              if(_codeController.text.length != 6){
                                //Please enter the code
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:Text("Please enter the code".tr()),
                                      dismissDirection: DismissDirection.vertical,
                                      duration: Duration(seconds: 1),
                                      backgroundColor: Colors.red),
                                );
                              }
                              else{
                                pickupActionsBloc?.add(DeliverShipment(
                                    id: widget.ordersDataModel?.id,
                                    amount: widget.payment.toString(),
                                    code :_codeController.text,
                                    paymentMethodId: _currentSelectedPaymentMethod?.id,
                                    receipt: receipt));
                              }

                            },
                            child: Text('Yes'.tr()),
                          ),

                        ],
                      ) else SizedBox()

                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),

    );
  }

}

// showDialog(
// context: context,
// builder: (context) {
// return StatefulBuilder(
// builder: (context , setState2){
// if ((totalPayment ?? 0  ) > 0){
// return AlertDialog(
// title: Column(
// crossAxisAlignment:
// CrossAxisAlignment
//     .center,
// children: [
// Row(
// children: [
// Text(
// 'Deliver'
//     .tr(),
// maxLines: 2,
// style: TextStyle(
// fontSize:
// 13),
// ),
// SizedBox(
// width: 5,
// ),
// Text(
// '${widget.ordersDataModel?.id}',
// maxLines: 2,
// ),
// ],
// ),
// Padding(
// padding: EdgeInsets.all(width! *
// 0.02),
// child:
// Container(
// width:
// width! *
// 0.7,
// child: Row(
// mainAxisAlignment:
// MainAxisAlignment
//     .center,
// children: [
// Text(
// "$totalPayment"),
// SizedBox(
// width:
// 5,
// ),
// Text(
// "SR".tr(),
// style: TextStyle(
// fontSize:
// 11),
// )
// ],
// ),
// ),

// ),
// Container(
// decoration: BoxDecoration(
// color: Colors.white,
// border: Border.all(color: Colors.grey),
// borderRadius: BorderRadius.circular(8)
// ),
// child: Padding(
// padding: EdgeInsets.all(3.0),
// child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// Text("Payment Method".tr(), style: TextStyle(fontSize: 12),),
// DropdownButtonHideUnderline(
// child: DropdownButton<PaymentMethod>(
// items: widget.resourcesData?.paymentMethods?.map((PaymentMethod dropDownStringItem) {
// return DropdownMenuItem<PaymentMethod>(
// value: dropDownStringItem,
// child: Text(
// dropDownStringItem.name ?? "",
// style: TextStyle(
// color:Colors.black87, fontSize: 15),
// ),
// );
// }).toList(),
// onChanged: (PaymentMethod? newValue) {
// setState2(() {
// _currentSelectedPaymentMethod = newValue;
//
//
// });
// },
// value: _currentSelectedPaymentMethod,
// ),
// ),
// ],
// ),
// ),
// ),
// confirmed ? Padding(
// padding: const EdgeInsets.all(18.0),
// child: Text("Are you sure ?".tr() , style: TextStyle(fontSize: 22),),
// ) : Container(),
// Row(
// crossAxisAlignment: CrossAxisAlignment.center,
// children: [
// confirmed ? Container() :
// TextButton(
// child: Text(
// 'ok'.tr()),
// onPressed: () {
// setState2(() {
// confirmed = true ;
// });
// },
// ),
// confirmed ?
// TextButton(
// child: Text(
// 'Cancel'.tr() , style: TextStyle(color: Colors.red),),
// onPressed: () {
// Navigator.pop(context);
// },
// ): Container(),
// confirmed ?
// TextButton(
// child: Text(
// 'Yes'.tr()),
// onPressed: () {
// pickupActionsBloc!.add(DeliverShipment(
// id: widget.ordersDataModel?.id,
// amount: totalPayment.toString(),
// receipt: _currentSelectedPaymentMethod?.val2));
// Navigator.pop(context);
//
// },
// ): Container(),
//
// ],
// )
// ],
// ),
// );
// }else {
// return AlertDialog(
// title: Column(
// children: [
// Row(
// children: [
// Text(
// 'Deliver'.tr(),
// maxLines: 2,
// ),
// SizedBox(
// width: 5,
// ),
// EasyLocalization.of(
// context)!
//     .locale ==
// Locale(
// 'en')
// ? Text(
// '${widget.ordersDataModel?.id} ?',
// maxLines:
// 2,
// )
//     : Text(
// '${widget.ordersDataModel?.id} ؟ ',
// maxLines:
// 2,
// ),
// ],
// ),
// confirmed ? Padding(
// padding: const EdgeInsets.all(18.0),
// child: Text("Are you sure ?".tr() , style: TextStyle(fontSize: 22),),
// ) : Container(),
// Row(
// crossAxisAlignment: CrossAxisAlignment.center,
// children: [
// confirmed ? Container() :
// TextButton(
// child: Text(
// 'ok'.tr()),
// onPressed: () {
// setState2(() {
// confirmed = true ;
// });
// },
// ),
// confirmed ?
// TextButton(
// child: Text(
// 'Cancel'.tr() , style: TextStyle(color: Colors.red),),
// onPressed: () {
// Navigator.pop(context);
// },
// ): Container(),
// confirmed ?
// TextButton(
// child: Text(
// 'Yes'.tr()),
// onPressed: () {
// pickupActionsBloc?.add(
// DeliverShipment(
// id: widget.ordersDataModel?.id,));
// Navigator.pop(context);
//
// },
// ): Container(),
//
// ],
// )
//
// ],
// ),
// );
// }
// });
//
// });
