import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:odometer/odometer.dart';
import 'package:xturbox/blocs/bloc/odoMeter_bloc.dart';
import 'package:xturbox/blocs/events/odoMeter_events.dart';
import 'package:xturbox/blocs/states/odoMeter_states.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'dart:ui' as ui;
// import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart'as mv;
import 'package:xturbox/utilities/Constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/utilities/comFunctions.dart';

class ODOMeterScreen extends StatefulWidget {
  ResourcesData? resourcesData ;
  String? type ;
  ODOMeterScreen({this.resourcesData , this.type});
  @override
  _ODOMeterScreenState createState() => _ODOMeterScreenState();
}

class _ODOMeterScreenState extends State<ODOMeterScreen> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  double? screenWidth , screenHeight , width , height ;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  final _valueController = TextEditingController();

  // int? _cameraOcr = mv.FlutterMobileVision.CAMERA_BACK;
  // mv.Size? _previewOcr;
  // String testText = '' ;
  // List<mv.OcrText> texts = [];

  _showScanBtn(){
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary:Colors.white, // background
        onPrimary: Constants.blueColor , // foreground
      ),
      onPressed: () async{

        // try {
        //   texts = await mv.FlutterMobileVision.read(
        //       flash: false,
        //       autoFocus: true,
        //       multiple: false,
        //       showText: true,
        //       preview: _previewOcr!,
        //       scanArea: mv.Size( 800,300),
        //       fps: 5.0,
        //       forceCloseCameraOnTap: true,
        //       waitTap: true
        //   );
        //   for(mv.OcrText text in texts){
        //     print(text.value);
        //     if(text.value.isNotEmpty){
        //       setState(() {
        //         _valueController.text = texts[0].value;
        //       });
        //     }
        //   }
        //
        // } on Exception {
        //   texts.add(new mv.OcrText('Failed to recognize text.'));
        // }
      },
      child: Row(
        children: [
          Icon(Icons.camera_alt,size: 14,),
          SizedBox(width: 4,),
          Text('Scan'.tr()),
        ],
      ),
    );
  }

  @override
  void initState() {
    // mv.FlutterMobileVision.start().then((previewSizes) => setState(() {
    //   _previewOcr = previewSizes[_cameraOcr]!.first;
    // }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    height = size.height;
    width = size.width;
    return ProgressHUD(
      barrierEnabled: false,
      backgroundColor: Constants.blueColor,
      child: BlocListener<ODOMeterBloc , ODOMeterStates>(
        listener: (context , state){
          if(state is ODOMeterLoading){
            final progress = ProgressHUD.of(context);
            progress?.show();
          }else{
            final progress = ProgressHUD.of(context);
            progress?.dismiss();
          }

          if(state is ODOMeterSetSuccess){
            ComFunctions.showToast(text: "Done".tr(), color: Colors.green);


            if(SavedData.profileDataModel.meter == null){
              _valueController.clear() ;
              setState(() {});
            }else{
              Navigator.of(context).pop();
            }
          }

          if(state is ODOMeterError){
            state.errorList?.forEach((element) {
              ComFunctions.showToast(text:element , color: Colors.red);

            });
          }
        },
        child: Dialog(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth,
                  decoration: BoxDecoration(
                    color: Constants.blueColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ODO Meter".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white,fontSize: 18),),
                    SavedData.profileDataModel.meter?.start != "0"
                    &&  SavedData.profileDataModel.meter?.start != null && (SavedData.profileDataModel.meterYesterday?.end.toString() != "0" || SavedData.profileDataModel.meterYesterday?.end != null)
                        ?  GestureDetector(
                            onTap: (){
                              Navigator.of(context).pop();
                            },
                            child: Icon(Icons.close , color: Colors.white,)) : SizedBox()

                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20,),
                      SavedData.profileDataModel.meter?.start != null ?
                      Container(
                        height: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Start read".tr() + " : ",style: TextStyle(color: Constants.blueColor , fontSize: 14),),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_outlined , color: Colors.grey, size: 18,),
                                    SizedBox(width: 4,),
                                    Text(DateFormat('kk:mm').format(SavedData.profileDataModel.meter?.created_at ??  "2023-01-01 20:29:02") , style: TextStyle(color: Colors.grey , fontSize: 14),),
                                  ],
                                ),
                              ],
                            ),
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Constants.blueColor),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Directionality(
                                    textDirection: ui.TextDirection.ltr,
                                    child: AnimatedSlideOdometerNumber(
                                      numberTextStyle: TextStyle(fontSize: 19 , color: Constants.blueColor),
                                      odometerNumber: OdometerNumber(int.tryParse(SavedData.profileDataModel.meter?.start.toString() ?? "")?? 0),
                                      duration: Duration(seconds: 1), letterWidth: 20,),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ) : SizedBox(),
                      SizedBox(height: 20,),
                      if(SavedData.profileDataModel.meterYesterday?.end.toString() == "0")
                        Text('Yesterday End read'.tr(), style: TextStyle(fontSize: 15,color: Constants.blueColor),)
                      else if(SavedData.profileDataModel.meter == null)
                        Text('Start read'.tr(), style: TextStyle(fontSize: 15,color: Constants.blueColor),)
                      else if(SavedData.profileDataModel.meter?.end.toString() == "0")
                        Text('End read'.tr(), style: TextStyle(fontSize: 15,color: Constants.blueColor),),


                      SizedBox(height: 20,),
                      SavedData.profileDataModel.meter?.end != null &&SavedData.profileDataModel.meter?.end.toString() != "0" ?
                      Container(
                        height: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("End read".tr() + " : ",style: TextStyle(color: Constants.blueColor , fontSize: 14),),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_outlined , color: Colors.grey, size: 18,),
                                    SizedBox(width: 4,),
                                    Text(DateFormat('kk:mm').format(SavedData.profileDataModel.meter?.updated_at ??  "2023-01-01 20:29:02") , style: TextStyle(color: Colors.grey , fontSize: 14),),
                                  ],
                                ),
                              ],
                            ),
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Constants.blueColor),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Directionality(
                                    textDirection: ui.TextDirection.ltr,
                                    child: AnimatedSlideOdometerNumber(
                                      numberTextStyle: TextStyle(fontSize: 19 , color: Constants.blueColor),
                                      odometerNumber: OdometerNumber(int.tryParse(SavedData.profileDataModel.meter?.end.toString() ?? "")?? 0),
                                      duration: Duration(seconds: 1), letterWidth: 20,),
                                  ),
                                ),
                              ),
                            ),

                            // Flexible(child: Text((SavedData.profileDataModel.meter?.start.toString() ?? "") + " " + "Km".tr(),style: TextStyle(color: Constants.blueColor,fontSize: 20),)),
                          ],
                        ),
                      ) :
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                                      LengthLimitingTextInputFormatter(7),
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'please enter the value'.tr();
                                      }
                                      return null;
                                    },
                                    decoration: kTextFieldDecoration.copyWith(
                                      labelText: 'Km'.tr(),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15,),
                              _showScanBtn(),


                            ],
                          ),
                          SizedBox(height: 10,),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Constants.blueColor, // background
                              onPrimary: Colors.white, // foreground
                            ),
                            onPressed: () {
                              if(_formKey.currentState!.validate()){
                                BlocProvider.of<ODOMeterBloc>(context).add(SetODOMeterValue(
                                    value: _valueController.text,
                                    id:  SavedData.profileDataModel.meter?.id,
                                    type: SavedData.profileDataModel.meterYesterday?.end.toString() == '0'? "late" : SavedData.profileDataModel.meter == null ? "start" : "end"));
                              }
                            },
                            child: Text('Save'.tr()),
                          )
                        ],
                      ),
                      SizedBox(height: 30,),



                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text('End shift read'.tr(), style: TextStyle(fontSize: 15,color: Constants.blueColor),),
                      //     SizedBox(width: 20,),
                      //     Flexible(
                      //       child: Container(
                      //         decoration: BoxDecoration(
                      //             color: Colors.white,
                      //             borderRadius: BorderRadius.circular(15),
                      //             border: Border.all(color: Constants.blueColor)
                      //         ),
                      //         child: Padding(
                      //           padding: const EdgeInsets.all(20.0),
                      //           child: AnimatedSlideOdometerNumber(
                      //             numberTextStyle: TextStyle(fontSize: 19 , color: Constants.blueColor),
                      //             odometerNumber: OdometerNumber(_counter),
                      //             duration: Duration(seconds: 1), letterWidth: 20,),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(height: 10,),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Container(
                      //       width: screenWidth!*0.5,
                      //       child: TextFormField(
                      //         keyboardType: TextInputType.number,
                      //         controller: _startReadController,
                      //         onChanged: (value){
                      //           setState(() {
                      //             _counter = int.tryParse(value) ?? 0 ;
                      //           });
                      //         },
                      //         inputFormatters: [
                      //           LengthLimitingTextInputFormatter(9),
                      //           FilteringTextInputFormatter.digitsOnly
                      //         ],
                      //         validator: (String? value) {
                      //           if (value!.isEmpty) {
                      //             return 'please enter the value'.tr();
                      //           }
                      //           return null;
                      //         },
                      //         decoration: kTextFieldDecoration.copyWith(
                      //           labelText: 'Amount ( Liters )'.tr(),
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(width: 15,),
                      //     ElevatedButton(
                      //       style: ElevatedButton.styleFrom(
                      //         primary: Constants.blueColor, // background
                      //         onPrimary: Colors.white, // foreground
                      //       ),
                      //       onPressed: () {
                      //         setState(() {
                      //         });
                      //       },
                      //       child: Text('Save'.tr()),
                      //     )
                      //   ],
                      // ),
                      // Container(),
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
