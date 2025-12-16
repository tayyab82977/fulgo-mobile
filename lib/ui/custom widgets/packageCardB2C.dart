import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/captainOrdersDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/ui/Client/addOrderB2c.dart';
import 'package:xturbox/ui/custom%20widgets/dialog.dart';
import 'package:xturbox/utilities/idToNameFunction.dart';

class PackageCardB2C extends StatefulWidget {

  // Packages? packages ;
  bool newPackage = false ;
  ErCity? currentCitySelected = ErCity();
  ErCity? currentReceiverCitySelected = ErCity();
  Neighborhoods? currentZone = Neighborhoods();
  Neighborhoods? currentZoneReceiver = Neighborhoods();
  VoidCallback? deleteBtnFun ;
  List<OrdersDataModelMix>? packagesList ;
  int? index ;
  OrdersDataModelMix? ordersDataModelMix;

  PackageCardB2C({
    // this.packages,
    this.ordersDataModelMix,
    this.currentCitySelected,
    this.currentReceiverCitySelected,
    this.currentZone,
    this.newPackage = false  ,
    this.deleteBtnFun ,
    this.packagesList,
    this.index,
    this.currentZoneReceiver});

  @override
  _PackageCardB2CState createState() => _PackageCardB2CState();
}

class _PackageCardB2CState extends State<PackageCardB2C> {

  late double screenWidth  ;
  late  double screenHeight ;
  bool checkedBoxLocal = false ;
  String packaging = '';
  String? pickUpCity;
  String? pickUpZone;
  String? deliverCity;
  String? deliverZone;

  idToNames(OrdersDataModelMix? ordersDataModelMix) {
    pickUpCity = IdToName.idToName('city', ordersDataModelMix?.pickupCity.toString()??"");
    if(pickUpCity == '' || pickUpCity == null){
      pickUpCity = IdToName.idToName(
          'cityFromNeighborhood', ordersDataModelMix?.pickupNeighborhood.toString()??"");
    }

    pickUpZone = IdToName.idToName(
        'zone', ordersDataModelMix?.pickupNeighborhood.toString()??"");

    deliverCity =
        IdToName.idToName('city', ordersDataModelMix?.deliverCity.toString()??"");

    if(deliverCity == '' || deliverCity == null){
      deliverCity = IdToName.idToName(
          'cityFromNeighborhood', ordersDataModelMix?.deliverNeighborhood.toString()??"");
    }

    deliverZone = IdToName.idToName(
        'zone', ordersDataModelMix?.deliverNeighborhood.toString()??"");

    packaging = IdToName.idToName("packaging", widget.packagesList?[widget.index ?? 0].packaging.toString() ?? "");
    checkedBoxLocal = widget.packagesList?[widget.index ?? 0].fragile == "1" ? true : false ;

  }


  @override
  void initState() {
    try{

      idToNames(widget.ordersDataModelMix);
    }catch(e){

    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try{

      idToNames(widget.ordersDataModelMix);
    }catch(e){

    }
    Size size = MediaQuery.of(context).size ;
    screenHeight = size.height ;
    screenWidth = size.width ;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(197, 197, 197, 0.1),
              //Colors.black26,
              blurRadius: 3.0, // soften the shadow
              spreadRadius: 3, //extend the shadow
            )
          ],
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.withOpacity(0.5), //deepOrange,
            width: 1,
            //borderRadius: BorderRadius.circular(radius),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Sender Name:'.tr(),
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.03),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    child: Text(
                      widget.packagesList?[widget.index ?? 0].senderName?.toString() ?? '',
                      style: TextStyle(fontSize: screenWidth * 0.03),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Sender Location:'.tr(),
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.03),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    child: Text(
                        (pickUpCity ?? '') + ", " +(pickUpZone ?? ""),
                      style: TextStyle(fontSize: screenWidth * 0.03),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Receiver Name:'.tr(),
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.03),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    child: Text(
                      widget.packagesList?[widget.index ?? 0].receiverName?.toString() ?? '',
                      style: TextStyle(fontSize: screenWidth * 0.03),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Receiver Location:'.tr(),
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.03),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Flexible(
                    child: Text(
                      (deliverCity ?? '') + ", " +(deliverZone ?? ""),
                      style: TextStyle(fontSize: screenWidth * 0.03),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Type :'.tr(),
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.03),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    packaging,
                    style: TextStyle(fontSize: screenWidth * 0.03),
                  ),
                ],
              ),
              SizedBox(height: 2,),
              Row(
                children: [
                  checkedBoxLocal
                      ? Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Fragile'.tr(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.03),
                      ),
                    ],
                  )
                      : Container(),
                ],
              ),
              SizedBox(height: 2,),
              widget.packagesList?[widget.index ?? 0].cod != "0" && widget.packagesList?[widget.index ?? 0].cod != "" ?
              Row(
                children: [
                  Text(
                    'cash on delivery'.tr(),
                    style: TextStyle(
                        fontSize: screenWidth * 0.03),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    widget.packagesList?[widget.index ?? 0].cod ?? '',
                    style: TextStyle(
                        fontSize: screenWidth * 0.03),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Text(
                    'SR'.tr(),
                    style: TextStyle(
                        fontSize: screenWidth * 0.02),
                  ),
                ],
              ) : Container(),
              SizedBox(height: 2,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'parcel details'.tr() + ":",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.03),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Flexible(
                    child: Text(
                      widget.packagesList?[widget.index ?? 0].comment ?? "",
                      style: TextStyle(fontSize: screenWidth * 0.03),
                    ),
                  ),
                ],
              ),
              widget.packagesList?[widget.index ?? 0].deductFromCod != "0" &&
                  widget.packagesList?[widget.index ?? 0].deductFromCod != "" &&
                  widget.packagesList?[widget.index ?? 0].deductFromCod != ""
                  ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                mainAxisAlignment:
                MainAxisAlignment.start,
                children: [
                    Text('deductFromCod'.tr(),style: TextStyle(fontSize: screenWidth * 0.03),),
                    Icon(Icons.check , size: 18,)
                ],
              ),
                  )
                  : Container(),

              widget.packagesList?[widget.index ?? 0].rc != "0" &&
                  widget.packagesList?[widget.index ?? 0].rc != "" &&
                  widget.packagesList?[widget.index ?? 0].rc != ""
                  ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.start,
                  children: [
                    Text('bill receiver for shopping'.tr(),style: TextStyle(fontSize: screenWidth * 0.03),),
                    Icon(Icons.check , size: 18,)
                  ],
                ),
              )
                  : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                      onTap: () async {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>

                            B2cOrderCreation(
                              newOrder: (e){
                                setState(() {
                                  widget.packagesList?[widget.index ?? 0] = e ;
                                  widget.ordersDataModelMix = e ;

                                });

                              }, showAddingOrder: (e){} , resourcesData: SavedData.resourcesData,ordersDataModel: widget.ordersDataModelMix ,) ));

                      },
                      child: Padding(
                          padding: EdgeInsets.only(
                            top: screenWidth * 0.01,
                            right: screenWidth * 0.02,
                            bottom: screenWidth * 0.01,
                          ),
                          child: Container(
                              child: Center(
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black87,
                                    size: screenWidth * 0.05,
                                  ))))),

                  InkWell(
                      onTap: widget.deleteBtnFun,
                      child: Padding(
                          padding: EdgeInsets.only(
                              top: screenWidth * 0.01,
                              right: screenWidth * 0.02,
                              bottom: screenWidth * 0.01,
                              left: screenWidth * 0.02),
                          child: Container(
                              child: Center(
                                  child: Icon(
                                    Icons.delete_forever_outlined,
                                    color: Color(0xFFF4693F),
                                    size: 20.05,
                                  ))))),
                ],
              ),

            ],
          ),
        ),
      ),
    );
    return  Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Container(
        // width: width,
         height: 499,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(197, 197, 197, 0.1),
                //Colors.black26,
                blurRadius: 3.0, // soften the shadow
                spreadRadius: 3, //extend the shadow
              )
            ],
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.withOpacity(0.5), //deepOrange,
              width: 1,
              //borderRadius: BorderRadius.circular(radius),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Type :'.tr(),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: screenWidth * 0.03),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  packaging,
                                  style: TextStyle(fontSize: screenWidth * 0.03),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                checkedBoxLocal
                                    ? Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fragile'.tr(),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: screenWidth * 0.03),
                                    ),
                                  ],
                                )
                                    : Container(),
                              ],
                            ),
                            widget.packagesList?[widget.index ?? 0].cod != "0" &&
                                widget.packagesList?[widget.index ?? 0].cod != ""
                                ? Row(
                              children: [
                                Text(
                                  'cash on delivery'.tr(),
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.03),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  widget.packagesList?[widget.index ?? 0].cod ?? '',
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.03),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  'SR'.tr(),
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.02),
                                ),
                              ],
                            )
                                : Container(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'No. of pieces :'.tr(),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: screenWidth * 0.03),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  widget.packagesList?[widget.index ?? 0].quantity
                                      .toString() ?? "1",
                                  style: TextStyle(fontSize: screenWidth * 0.03),
                                ),
                              ],
                            ),
                            widget.packagesList?[widget.index ?? 0].comment != null &&  widget.packagesList?[widget.index ?? 0].comment != ""
                                ? Container(
                                width: screenWidth * 0.5,
                                child: AutoSizeText(
                                  '${widget.packagesList?[widget.index ?? 0].comment}',
                                  maxLines: 2,
                                  minFontSize: 7,
                                  maxFontSize: 11,
                                ))
                                : Container(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Sender Name:'.tr(),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: screenWidth * 0.03),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  widget.packagesList?[widget.index ?? 0].senderName?.toString() ?? '',
                                  style: TextStyle(fontSize: screenWidth * 0.03),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Sender Location:'.tr(),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: screenWidth * 0.03),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  pickUpCity ?? '',
                                  style: TextStyle(fontSize: screenWidth * 0.03),
                                ),
                              ],
                            ),
                            Flexible(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Receiver Name:'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: screenWidth * 0.03),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    widget.packagesList?[widget.index ?? 0].receiverName?.toString() ?? '',
                                    style: TextStyle(fontSize: screenWidth * 0.03),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Receiver Location:'.tr(),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: screenWidth * 0.03),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  deliverCity ?? '',
                                  style: TextStyle(fontSize: screenWidth * 0.03),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // checkedBoxLocal ? Text('-') : Container(),

              Row(
                children: [
                  InkWell(
                      onTap: () async {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>

                            B2cOrderCreation(
                              newOrder: (e){
                             setState(() {
                               widget.packagesList?[widget.index ?? 0] = e ;
                               widget.ordersDataModelMix = e ;

                             });

                            }, showAddingOrder: (e){} , resourcesData: SavedData.resourcesData,ordersDataModel: widget.ordersDataModelMix ,) ));

                      },
                      child: Padding(
                          padding: EdgeInsets.only(
                            top: screenWidth * 0.01,
                            right: screenWidth * 0.02,
                            bottom: screenWidth * 0.01,
                          ),
                          child: Container(
                              child: Center(
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black87,
                                    size: screenWidth * 0.05,
                                  ))))),

                 InkWell(
                      onTap: widget.deleteBtnFun,
                      child: Padding(
                          padding: EdgeInsets.only(
                              top: screenWidth * 0.01,
                              right: screenWidth * 0.02,
                              bottom: screenWidth * 0.01,
                              left: screenWidth * 0.02),
                          child: Container(
                              child: Center(
                                  child: Icon(
                                    Icons.delete_forever_outlined,
                                    color: Color(0xFFF4693F),
                                    size: 20.05,
                                  ))))),
                ],
              )
            ],
          )),
    );
  }
}
