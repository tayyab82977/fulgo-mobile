import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:Fulgox/controllers/client_cancel_order_controller.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';

import '../../data_providers/models/memberBalanceModel.dart';
import '../../utilities/Constants.dart';
import '../../utilities/comFunctions.dart';
import '../../utilities/idToNameFunction.dart';
import '../Client/paymentMethod_dialog.dart';
import '../custom widgets/custom_loading.dart';

class ShipmentDetailsDialog extends StatefulWidget {
  OrdersDataModelMix ordersDataModelMix;
  ClientCancelOrderController clientCancelOrderController;
  ShipmentDetailsDialog(
      {required this.ordersDataModelMix, required this.clientCancelOrderController});

  @override
  State<ShipmentDetailsDialog> createState() => _ShipmentDetailsDialogState();
}

class _ShipmentDetailsDialogState extends State<ShipmentDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: ShipmentDetailsComponent(
        ordersDataModelMix: widget.ordersDataModelMix,
        clientCancelOrderController: widget.clientCancelOrderController,
      ),
    );
  }
}

class ShipmentDetailsComponent extends StatefulWidget {
  OrdersDataModelMix ordersDataModelMix;
  ClientCancelOrderController clientCancelOrderController;
  ShipmentDetailsComponent(
      {required this.ordersDataModelMix, required this.clientCancelOrderController});

  @override
  State<ShipmentDetailsComponent> createState() =>
      _ShipmentDetailsComponentState();
}

class _ShipmentDetailsComponentState extends State<ShipmentDetailsComponent> {
  String? pickUpCity;

  String? pickUpZone;

  String? deliverCity;

  String? deliverZone;

  var pickUpTime;

  String? deliverTime;

  String? shipmentStatus;

  String? packagingType;

  String? cancelReason;

  double? screenWidth, screenHeight;

  bool dataChanged = false;
  PaymentMethods paymentMethod =
      PaymentMethods(id: "0", name: "", selected: false);

  idToNames(OrdersDataModelMix ordersDataModelMix) {
    pickUpCity =
        IdToName.idToName('city', ordersDataModelMix.pickupCity.toString());
    if (pickUpCity == '' || pickUpCity == null) {
      pickUpCity = IdToName.idToName('cityFromNeighborhood',
          ordersDataModelMix.pickupNeighborhood.toString());
    }

    pickUpZone = IdToName.idToName(
        'zone', ordersDataModelMix.pickupNeighborhood.toString());

    deliverCity =
        IdToName.idToName('city', ordersDataModelMix.deliverCity.toString());

    if (deliverCity == '' || deliverCity == null) {
      deliverCity = IdToName.idToName('cityFromNeighborhood',
          ordersDataModelMix.deliverNeighborhood.toString());
    }

    deliverZone = IdToName.idToName(
        'zone', ordersDataModelMix.deliverNeighborhood.toString());

    pickUpTime = DateTime.tryParse(ordersDataModelMix.pickupTime.toString());

    shipmentStatus =
        IdToName.idToName('trackType', ordersDataModelMix.trackType.toString());

    paymentMethod.name = IdToName.idToName(
        'payment_method', ordersDataModelMix.payment_method.toString());
    packagingType =
        IdToName.idToName('packaging', ordersDataModelMix.packaging.toString());

    cancelReason = IdToName.idToName(
        'cancellation', ordersDataModelMix.cancellation.toString());
  }

  @override
  void initState() {
    idToNames(widget.ordersDataModelMix);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return Container(
      decoration: BoxDecoration(
        color: Constants.clientBackgroundGrey,
        // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10) , bottomRight: Radius.circular(10))
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Reverse shipment".tr(),
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/images/regular.svg",
                              height: 38.0,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '#'.tr(),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      widget.ordersDataModelMix.id ?? "",
                                      style: TextStyle(fontSize: 16),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${widget.ordersDataModelMix.stamp!.substring(0, 11)}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Shipment information'.tr(),
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: () {
                              _paymentMethodDialog(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Constants.blueColor,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Payment method'.tr()),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(paymentMethod.name ?? ""),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Packaging'.tr()),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(packagingType ?? ''),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('no. of pieces'.tr()),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      widget.ordersDataModelMix.quantity ??
                                          '1'),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    widget.ordersDataModelMix.comment != null &&
                            widget.ordersDataModelMix.comment != ""
                        ? Column(
                            children: [
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('parcel details'.tr()),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: AutoSizeText(
                                            widget.ordersDataModelMix.comment ??
                                                '',
                                            textAlign:
                                                EasyLocalization.of(context)!
                                                            .currentLocale ==
                                                        Locale("en")
                                                    ? TextAlign.right
                                                    : TextAlign.left,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 8,
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Pickup time'.tr()),
                                // pickUpTime != null && ordersDataModelMix.pickupTime.toString().length > 1 ?
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Row(
                                //     children: [
                                //       Text(pickUpTime!.day.toString() + "-" + pickUpTime!.month.toString() + "-" + pickUpTime!.year.toString() ),
                                //       SizedBox(width: 10,),
                                //       Text(pickUpTime!.hour.toString() + ":" + pickUpTime!.minute.toString() ),
                                //     ],
                                //   ),
                                // ) :  Text(pickUpTime.toString() ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                    widget.ordersDataModelMix.por == '1'
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Shipping on receiver'.tr()),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.check),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    widget.ordersDataModelMix.fragile == '1'
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Fragile'.tr()),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.check),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    widget.ordersDataModelMix.cod != '0' &&
                            widget.ordersDataModelMix.cod != null &&
                            widget.ordersDataModelMix.cod != ''
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text('Cash on delivery'.tr()),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            Text(
                                                widget.ordersDataModelMix.cod ??
                                                    ''),
                                            SizedBox(
                                              width: 3,
                                            ),
                                            Text(
                                              'SR'.tr(),
                                              style: TextStyle(fontSize: 11),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    widget.ordersDataModelMix.deductFromCod != "0" &&
                            widget.ordersDataModelMix.deductFromCod != "" &&
                            widget.ordersDataModelMix.deductFromCod != ""
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('deductFromCod'.tr()),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.check),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    widget.ordersDataModelMix.rc != '0' &&
                            widget.ordersDataModelMix.rc != '' &&
                            widget.ordersDataModelMix.rc != null
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text('Shipping on receiver'.tr()),
                                          // ordersDataModelMix.status == "1" ||
                                          //         ordersDataModelMix.status ==
                                          //             "2" ||
                                          //         ordersDataModelMix.status ==
                                          //             "3" ||
                                          //         ordersDataModelMix.status ==
                                          //             "4"
                                          //     ? InkWell(
                                          //         onTap: () {
                                          //           showDialog(
                                          //               context: context,
                                          //               barrierDismissible:
                                          //                   true,
                                          //               builder: (context) {
                                          //                 return AlertDialog(
                                          //                   title: Column(
                                          //                     children: [
                                          //                       Text('Are you sure ?'
                                          //                           .tr()),
                                          //                     ],
                                          //                   ),
                                          //                   actions: [
                                          //                     ElevatedButton(
                                          //                       child: Text(
                                          //                         'No'.tr(),
                                          //                         style: TextStyle(
                                          //                             color: Colors
                                          //                                 .green),
                                          //                       ),
                                          //                       onPressed:
                                          //                           () {
                                          //                         Navigator.pop(
                                          //                             context);
                                          //                       },
                                          //                     ),
                                          //                     ElevatedButton(
                                          //                       child: Text(
                                          //                         'Yes'.tr(),
                                          //                         style: TextStyle(
                                          //                             color: Colors
                                          //                                 .red),
                                          //                       ),
                                          //                       onPressed:
                                          //                           () {
                                          //                         cancelOrderBloc!.add(ZeroRC(
                                          //                             shipmentId:
                                          //                                 ordersDataModelMix.id));
                                          //                         Navigator.pop(
                                          //                             context);
                                          //                       },
                                          //                     ),
                                          //                   ],
                                          //                 );
                                          //               });
                                          //         },
                                          //         child: Padding(
                                          //           padding:
                                          //               EdgeInsets.symmetric(
                                          //                   vertical: 8,
                                          //                   horizontal:
                                          //                       screenWidth! *
                                          //                           0.03),
                                          //           child: Container(
                                          //             width:
                                          //                 screenWidth! * 0.12,
                                          //             height: 30,
                                          //             decoration:
                                          //                 BoxDecoration(
                                          //               color:
                                          //                   Color(0xFFFA8154),
                                          //               borderRadius:
                                          //                   BorderRadius
                                          //                       .circular(40),
                                          //             ),
                                          //             child: Center(
                                          //                 child: AutoSizeText(
                                          //               'Cancel'.tr(),
                                          //               style: TextStyle(
                                          //                   color:
                                          //                       Colors.white,
                                          //                   fontSize: 11,
                                          //                   fontWeight:
                                          //                       FontWeight
                                          //                           .w900),
                                          //             )),
                                          //           ),
                                          //         ),
                                          //       )
                                          //     : Container()
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.check),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    widget.ordersDataModelMix.extra != "0" &&
                            widget.ordersDataModelMix.extra != null
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('extra'.tr()),
                                      Row(
                                        children: [
                                          Text(
                                            widget.ordersDataModelMix.extra ??
                                                "",
                                            style: TextStyle(),
                                          ),
                                          SizedBox(
                                            width: 3,
                                          ),
                                          Text(
                                            "SR".tr(),
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    widget.ordersDataModelMix.cancellation != '0'
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Cancellation reason'.tr()),
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(cancelReason ?? ''),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    widget.ordersDataModelMix.reject != null
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Rejection reason'.tr()),
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            widget.ordersDataModelMix.reject ??
                                                ''),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    Row(
                      children: [
                        Text(
                          'Sender information'.tr(),
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Full name'.tr(),
                              style: TextStyle(fontSize: 11),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Text(
                                widget.ordersDataModelMix.receiverName ?? '',
                              ),
                            )
                            // Text(ordersDataModelMix.senderName)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Phone number'.tr(),
                                style: TextStyle(fontSize: 11)),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Text(
                                widget.ordersDataModelMix.receiverPhone ?? '',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('City'.tr(), style: TextStyle(fontSize: 11)),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Text(
                                deliverCity ?? '',
                              ),
                            )

                            // Text(ordersDataModelMix.senderName)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Neighborhood'.tr(),
                                style: TextStyle(fontSize: 11)),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Text(
                                deliverZone ?? '',
                              ),
                            )

                            // Text(ordersDataModelMix.senderName)
                          ],
                        ),
                      ),
                    ),
                    widget.ordersDataModelMix.deliverAddress != null &&
                            widget.ordersDataModelMix.deliverAddress != ''
                        ? Column(
                            children: [
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(child: Text('Address'.tr())),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Flexible(
                                        flex: 4,
                                        child: Container(
                                          child: Text(
                                            widget.ordersDataModelMix
                                                    .deliverAddress ??
                                                '',
                                            maxLines: 3,
                                          ),
                                        ),
                                      )
                                      // Text(ordersDataModelMix.senderName)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 8,
                    ),
                    widget.ordersDataModelMix.deliverMap != '' &&
                            widget.ordersDataModelMix.deliverMap != null
                        ? Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  ComFunctions.launchURL(
                                      widget.ordersDataModelMix.deliverMap ??
                                          '');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Color(0xFF56D340), width: 2),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: SvgPicture.asset(
                                          "assets/images/google-maps.svg",
                                          placeholderBuilder: (context) =>
                                              CustomLoading(),
                                          // height: 18.0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Flexible(
                                        child: Text(
                                          'Position on Google Maps'.tr(),
                                          style: TextStyle(
                                            color: Color(0xFF56D340),
                                            fontSize: 17,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                    Row(
                      children: [
                        Text(
                          'Receiver information'.tr(),
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Full name'.tr(),
                              style: TextStyle(fontSize: 11),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Text(
                                widget.ordersDataModelMix.senderName ?? '',
                              ),
                            )
                            // Text(ordersDataModelMix.senderName)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Phone number'.tr(),
                                style: TextStyle(fontSize: 11)),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Text(
                                widget.ordersDataModelMix.senderPhone ?? '',
                              ),
                            ),

                            // Text(ordersDataModelMix.senderName)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('City'.tr(), style: TextStyle(fontSize: 11)),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Text(
                                pickUpCity ?? '',
                                maxLines: 1,
                              ),
                            )

                            // Text(ordersDataModelMix.senderName)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Neighborhood'.tr(),
                                style: TextStyle(fontSize: 11)),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Text(
                                pickUpZone ?? '',
                              ),
                            )

                            // Text(ordersDataModelMix.senderName)
                          ],
                        ),
                      ),
                    ),
                    widget.ordersDataModelMix.pickupAddress != null &&
                            widget.ordersDataModelMix.pickupAddress != ''
                        ? Column(
                            children: [
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Address'.tr()),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Flexible(
                                        flex: 4,
                                        child: Container(
                                          child: Text(
                                            widget.ordersDataModelMix
                                                    .pickupAddress ??
                                                '',
                                          ),
                                        ),
                                      )
                                      // Text(ordersDataModelMix.senderName)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 8,
                    ),
                    widget.ordersDataModelMix.pickupMap != '' &&
                            widget.ordersDataModelMix.pickupMap != null
                        ? Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  ComFunctions.launchURL(
                                      widget.ordersDataModelMix.pickupMap ??
                                          '');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Color(0xFF56D340), width: 2),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: SvgPicture.asset(
                                          "assets/images/google-maps.svg",
                                          placeholderBuilder: (context) =>
                                              CustomLoading(),
                                          // height: 18.0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Flexible(
                                        child: Text(
                                          'Position on Google Maps'.tr(),
                                          style: TextStyle(
                                            color: Color(0xFF56D340),
                                            fontSize: 17,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.clientCancelOrderController.reverseMyOrder(
                          shipmentId: widget.ordersDataModelMix.id.toString(),
                          ordersDataModelMix: widget.ordersDataModelMix);
                      Navigator.of(context).pop();
                    },
                    child: Text('Confirm'.tr()),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel'.tr(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _paymentMethodDialog(BuildContext context) {
    showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (context) {
          return PaymentMethodDialog(
            paymentMethod: (selectedMethod) {
              setState(() {
                paymentMethod = selectedMethod;
                widget.ordersDataModelMix.payment_method = paymentMethod.id;
              });
            },
          );
        });
  }
}
