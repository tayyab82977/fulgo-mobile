import 'package:auto_size_text/auto_size_text.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/models/captainOrdersDataModel.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/courier/captainEditShipment.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/courier/captainOrdersList.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/custom%20widgets/customCheckBox.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/utilities/idToNameFunction.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';

import '../courier/DetailedCaptainOrder.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import '../Client/DetailedOrder.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';

class CapOrdersCard extends StatefulWidget {
  ResourcesData? resourcesData;

  List<OrdersDataModelMix>? ordersList;
  OrdersDataModelMix? ordersDataModel;
  bool? reserved;
  bool? cancel;
  CapOrdersCard(
      {this.ordersDataModel,
      this.resourcesData,
      this.ordersList,
      this.reserved,
      this.cancel});

  @override
  _OrdersCardState createState() => _OrdersCardState();
}

class _OrdersCardState extends State<CapOrdersCard> {
  double? width, height;

  String? pickUpCity;
  String? deliverCity;
  String? pickUpTime;
  String? deliverTime;
  String? shipmentStatus;
  String? pickUpZone;
  String? deliverZone;

  String? packaging;
  String? currentWeight;

  idToNames() {
    pickUpCity = IdToName.idToName(
        'city', widget.ordersDataModel?.pickupCityId.toString() ?? "");

    pickUpZone = IdToName.idToName(
        'zone', widget.ordersDataModel?.pickupNeighborhood.toString() ?? "");

    deliverCity = IdToName.idToName(
        'city', widget.ordersDataModel?.deliverCityId.toString() ?? "");

    deliverZone = IdToName.idToName(
        'zone', widget.ordersDataModel?.deliverNeighborhood.toString() ?? "");

    pickUpTime = IdToName.idToName(
        'times', widget.ordersDataModel?.pickupTime.toString() ?? "");

    deliverTime = IdToName.idToName(
        'times', widget.ordersDataModel?.deliverTime.toString() ?? "");

    shipmentStatus = IdToName.idToName(
        'shipmentStatus', widget.ordersDataModel?.status.toString() ?? "");

    for (int i = 0; i < (widget.resourcesData?.packaging?.length ?? 0); i++) {
      if (widget.ordersDataModel?.packaging ==
          widget.resourcesData?.packaging?[i].id) {
        packaging = widget.resourcesData?.packaging?[i].name;
      }
    }
  }

  bool tileExpanded = false;

  void changTitleColor({bool? value}) {
    setState(() {
      tileExpanded = true;
    });
  }

  @override
  void initState() {
    try {
      idToNames();
    } catch (e) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    double screenHeight = size.height;
    width = size.width;
    height = size.height;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailedCapOrder(
                      resourcesData: widget.resourcesData,
                      ordersDataModel: widget.ordersDataModel,
                    )));
      },
      child: Padding(
        padding: EdgeInsets.only(top: 15, left: 12, right: 12),
        child: Container(
          width: width,
          // height: height * 0.16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 15,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              widget.cancel == null
                                  ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          widget.ordersDataModel?.selected =
                                              !(widget.ordersDataModel
                                                      ?.selected ??
                                                  false);
                                          if (widget
                                                  .ordersDataModel?.selected ??
                                              false) {
                                            widget.ordersDataModel?.accepted =
                                                true;
                                            widget.reserved = true;
                                          } else {
                                            widget.reserved = true;
                                            widget.ordersDataModel?.accepted =
                                                null;
                                          }
                                        });
                                      },
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CustomCheckBox(
                                            backgroundColor: Colors.white,
                                            checked: widget
                                                .ordersDataModel?.selected,
                                            checkedColor: Constants.blueColor,
                                            unCheckedColor:
                                                Constants.blueColor),
                                      ),
                                    )
                                  : SizedBox(),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "#" + (widget.ordersDataModel?.id ?? ""),
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          widget.ordersDataModel?.cod != '' &&
                                  widget.ordersDataModel?.cod != '0' &&
                                  widget.ordersDataModel?.cod != null
                              ? Row(
                                  children: [
                                    Text(
                                      'Cash on delivery'.tr(),
                                      style: TextStyle(
                                        color: Constants.capOrange,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Text(
                                      widget.ordersDataModel?.cod ?? '',
                                      style: TextStyle(
                                        color: Constants.capOrange,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Text('SR'.tr(),
                                        style: TextStyle(
                                          color: Constants.capOrange,
                                        ))
                                  ],
                                )
                              : Container(),
                          widget.ordersDataModel?.comment != '' &&
                                  widget.ordersDataModel?.comment != null
                              ? Container(
                                  width: width! * 0.7,
                                  child: AutoSizeText(
                                    widget.ordersDataModel?.comment ?? '',
                                    style: TextStyle(
                                      color: Constants.capOrange,
                                    ),
                                  ))
                              : Container()
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        widget.cancel != null &&
                                widget.ordersDataModel!.accepted == true
                            ? CustomButton(
                                padding: EdgeInsets.all(0),
                                minWidth: 35,
                                height: 30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: Color(0xffFDE3D0),
                                child: Icon(
                                  MdiIcons.deleteForever,
                                  color: Constants.capOrange,
                                ),
                                onPressed: () {
                                  widget.ordersDataModel?.accepted = null;
                                  widget.ordersDataModel?.selected = false;
                                  widget.ordersDataModel?.extra = "0";
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CaptainOrdersListScreen(
                                                  resourcesData:
                                                      widget.resourcesData,
                                                  orderList: widget.ordersList,
                                                  reserved: true,
                                                  index: 0)));
                                })
                            : Container(),
                        widget.reserved! && widget.cancel == null
                            ? CustomButton(
                                padding: EdgeInsets.all(0),
                                minWidth: 35,
                                height: 30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: Color(0xffF1F1F1),
                                child:
                                    Icon(Icons.edit, color: Color(0xff6D6D6D)),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CaptianEditShipment(
                                                resourcesData:
                                                    widget.resourcesData,
                                                ordersDataModel:
                                                    widget.ordersDataModel,
                                                ordersList: widget.ordersList,
                                              )));
                                })
                            : Container(),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'weight :'.tr(),
                              style: TextStyle(
                                color: Constants.blueColor,
                              ),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              widget.ordersDataModel?.weight ?? "",
                              style: TextStyle(
                                  // color: Colors.white
                                  ),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              'KG'.tr(),
                              style: TextStyle(
                                  // color:Colors.white
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Measures :'.tr(),
                              style: TextStyle(
                                color: Constants.blueColor,
                              ),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            AutoSizeText(
                              (widget.ordersDataModel?.length.toString() ??
                                      "") +
                                  "x" +
                                  (widget.ordersDataModel?.width.toString() ??
                                      "") +
                                  "x" +
                                  (widget.ordersDataModel?.height.toString() ??
                                      ""),
                              maxLines: 2,
                              style: TextStyle(
                                  // color: Colors.white,
                                  fontSize: width! * 0.015,
                                  // fontWeight: FontWeight.bold,
                                  fontFamily: "Schyler"),
                            ),
                            Text(
                              'cm'.tr(),
                              style: TextStyle(
                                fontSize: width! * 0.025,
                                // color: Colors.white
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Type :'.tr(),
                              style: TextStyle(
                                color: Constants.blueColor,
                              ),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            AutoSizeText(
                              packaging ?? '',
                              maxLines: 2,
                              style: TextStyle(
                                  // color: Colors.white,
                                  fontSize: width! * 0.015,
                                  // fontWeight: FontWeight.bold,
                                  fontFamily: "Schyler"),
                            ),
                          ],
                        ),
                        widget.ordersDataModel?.noOfCartoons != null
                            ? Row(
                                children: [
                                  Text(
                                    'No of Cartoons : '.tr(),
                                    style: TextStyle(
                                      color: Constants.blueColor,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  AutoSizeText(
                                    widget.ordersDataModel?.noOfCartoons ?? "1",
                                    maxLines: 2,
                                    style: TextStyle(
                                        // color: Colors.white,
                                        fontSize: width! * 0.015,
                                        // fontWeight: FontWeight.bold,
                                        fontFamily: "Schyler"),
                                  ),
                                ],
                              )
                            : Container(),
                        Row(
                          children: [
                            Text(
                              'No. of pieces :'.tr(),
                              style: TextStyle(
                                color: Constants.blueColor,
                              ),
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            AutoSizeText(
                              widget.ordersDataModel?.quantity ?? "1",
                              maxLines: 2,
                              style: TextStyle(
                                  // color: Colors.white,
                                  fontSize: width! * 0.015,
                                  // fontWeight: FontWeight.bold,
                                  fontFamily: "Schyler"),
                            ),
                          ],
                        ),
                        widget.ordersDataModel?.extra != "0" &&
                                widget.ordersDataModel?.extra != null &&
                                widget.ordersDataModel?.extra != ''
                            ? Row(
                                children: [
                                  Text(
                                    'Extra :'.tr(),
                                    style: TextStyle(
                                      color: Constants.blueColor,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  AutoSizeText(
                                    widget.ordersDataModel?.extra ?? '',
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: 13, fontFamily: "Schyler"),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    'SR'.tr(),
                                    style: TextStyle(fontSize: 11),
                                  )
                                ],
                              )
                            : Container(),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        widget.ordersDataModel?.fragile == '1'
                            ? Column(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          color: Constants.capOrange,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            'Fragile'.tr(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ))),
                                ],
                              )
                            : Container(),
                        widget.ordersDataModel?.rc != '0' &&
                                widget.ordersDataModel?.rc != '' &&
                                widget.ordersDataModel?.rc != null
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                          color: Color(0xffebbfc1),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          'Delivery on receiver'.tr(),
                                          style: TextStyle(
                                              color: Color(0xff851e23)),
                                        ),
                                      )),
                                ],
                              )
                            : Container(),
                        widget.ordersDataModel?.deductFromCod != '0' &&
                                widget.ordersDataModel?.deductFromCod != '' &&
                                widget.ordersDataModel?.deductFromCod != null
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    width: width! * 0.4,
                                    decoration: BoxDecoration(
                                        color: Constants.capPurple,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: AutoSizeText(
                                          'deductFromCod'.tr(),
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        )),
                                  )
                                ],
                              )
                            : Container(),
                      ],
                    )
                  ],
                ),
                // ExpansionTile(
                //   color: Constants.capPurple,
                //   tilePadding: EdgeInsets.symmetric(horizontal: 5),
                //   childrenPadding: EdgeInsets.symmetric(horizontal: 15),
                //
                //   title: Text('Show details'.tr() , style: TextStyle(
                //     color: tileExpanded ? Colors.white : Constants.capPurple
                //   ),),
                //   onExpansionChanged:(changeColor){
                //     if(changeColor){
                //       setState(() {
                //         tileExpanded = true ;
                //       });
                //     }else{
                //
                //       setState(() {
                //         tileExpanded = false ;
                //       });
                //
                //     }
                //
                //   },
                //   children: <Widget>[
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Row(
                //               children: [
                //                 Text('weight :'.tr(),
                //                 style: TextStyle(
                //                   color: Color(0xffA1A2CE)
                //                 ),
                //                 ),
                //                 SizedBox(width: 3,),
                //                 Text(currentWeight,
                //                   style: TextStyle(
                //                       color: Colors.white
                //                   ),
                //                 ),
                //                 SizedBox(width: 3,),
                //                 Text('KG'.tr() ,
                //                   style: TextStyle(
                //                       color:Colors.white
                //                   ),
                //                 ),
                //
                //               ],
                //             ),
                //             Row(
                //               children: [
                //                 Text('Measures :'.tr(),
                //                   style: TextStyle(
                //                       color: Color(0xffA1A2CE)
                //                   ),
                //                 ),
                //                 SizedBox(width: 3,),
                //                 AutoSizeText(
                //                   '${widget.ordersDataModel.length.toString()}x${widget.ordersDataModel.width.toString()}x${widget.ordersDataModel.height.toString()} ',
                //                   maxLines: 2,
                //                   style: TextStyle(
                //                       color: Colors.white,
                //                       fontSize: width * 0.015,
                //                       fontWeight: FontWeight.bold,
                //                       fontFamily: "Schyler"),
                //                 ),
                //                 Text('cm'.tr(),
                //                 style: TextStyle(
                //                   fontSize: width * 0.025,
                //                   color: Colors.white
                //                 ),)
                //               ],
                //             ),
                //             Row(
                //               children: [
                //                 Text('Type :'.tr(),
                //                   style: TextStyle(
                //                       color: Color(0xffA1A2CE)
                //                   ),
                //                 ),
                //                 SizedBox(width: 3,),
                //                 AutoSizeText(
                //                   packaging??'',
                //                   maxLines: 2,
                //                   style: TextStyle(
                //                       color: Colors.white,
                //                       fontSize: width * 0.015,
                //                       fontWeight: FontWeight.bold,
                //                       fontFamily: "Schyler"),
                //                 ),
                //               ],
                //             ),
                //             widget.ordersDataModel.extra != "0" && widget.ordersDataModel.extra != null && widget.ordersDataModel.extra != ''  ?
                //             Row(
                //               children: [
                //                 Text('Extra :'.tr(),
                //                   style: TextStyle(
                //                       color: Color(0xffA1A2CE)
                //                   ),
                //                 ),
                //                 SizedBox(width: 3,),
                //                 AutoSizeText(
                //                   widget.ordersDataModel.extra??'',
                //                   maxLines: 2,
                //                   style: TextStyle(
                //                       color: Colors.white,
                //                       fontSize: width * 0.015,
                //                       fontWeight: FontWeight.bold,
                //                       fontFamily: "Schyler"),
                //                 ),
                //                 SizedBox(width: 3,),
                //                 Text('SR'.tr(), style: TextStyle(color: Colors.white,fontSize: 11),)
                //
                //               ],
                //             ) : Container(),
                //           ],
                //         ),
                //         widget.ordersDataModel.fragile == '1'?
                //         Container(
                //             decoration: BoxDecoration(
                //               color: Colors.white,
                //               borderRadius: BorderRadius.circular(15)
                //             ),
                //             child: Padding(
                //               padding: const EdgeInsets.all(5.0),
                //               child: Text('Fragile'.tr(),
                //               style: TextStyle(
                //                 color: Constants.capOrange
                //               ),
                //               ),
                //             )) : Container(),
                //       ],
                //     ),
                //
                //
                //
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
