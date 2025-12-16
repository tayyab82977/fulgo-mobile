import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/ui/custom%20widgets/counterWidget.dart';
// import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/utilities/Constants.dart';

import 'captainOrdersList.dart';
import '../custom widgets/CaptainAppBar.dart';
import '../custom widgets/drawerCaptain.dart';

class CaptianEditShipment extends StatefulWidget {
  ResourcesData? resourcesData;
  OrdersDataModelMix? ordersDataModel;
  List<OrdersDataModelMix>? ordersList;
  CaptianEditShipment(
      {this.resourcesData, this.ordersDataModel, this.ordersList});
  @override
  _CaptianEditShipmentState createState() => _CaptianEditShipmentState();
}

class _CaptianEditShipmentState extends State<CaptianEditShipment> {
  double? screenWidth, screenHeight;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  final _packageLengthController = TextEditingController();
  final _packageWidthController = TextEditingController();
  final _packageHeightController = TextEditingController();
  final _packageWeightController = TextEditingController();
  final _packageCommentController = TextEditingController();
  final _packageExtraController = TextEditingController();
  final _packageNoOfCartoonsController = TextEditingController();
  final _packageNoOfPiecesController = TextEditingController();

  List<ErCity> senderCities = [];
  List<ErCity> receiverCities = [];

  String? packaging;
  String? currentWeight;
  String? packageType;
  String? currentWeightId;
  Weight? _currentSelectedWeight = Weight();
  Packaging? _currentSelectedPackaging = Packaging();
  bool? checkedValue;
  String? senderCity;
  String? receiverCity;
  double total = 0;
  int noOfCartons = 0;
  int noOfPieces = 1;
  ErCity? receiverCityClass ;

  setPackageData() {
    senderCities.addAll(widget.resourcesData!.city!
        .where((element) => element.neighborhoods!.length > 0)
        .toList());
    receiverCities.addAll(widget.resourcesData!.city!
        .where((element) => element.neighborhoods!.length > 0)
        .toList());

    packageType = widget.ordersDataModel!.packaging;
    currentWeightId = widget.ordersDataModel!.weight;
    _packageWeightController.text = widget.ordersDataModel!.weight.toString();
    _packageHeightController.text = widget.ordersDataModel!.height.toString();
    _packageWidthController.text = widget.ordersDataModel!.width.toString();
    _packageLengthController.text = widget.ordersDataModel!.length.toString();
    if (widget.ordersDataModel!.noOfCartoons == null) {
      noOfCartons = 0;
    } else {
      var cartons = int.tryParse( widget.ordersDataModel!.noOfCartoons!);
     noOfCartons = cartons ?? 0 ;
    }
    if (widget.ordersDataModel!.quantity == null) {
      noOfPieces = 1 ;
    } else {
      var pieces = int.tryParse( widget.ordersDataModel!.quantity!);
      noOfPieces = pieces ?? 0 ;

    }
    if (widget.ordersDataModel!.fragile == '1') {
      checkedValue = true;
    } else {
      checkedValue = false;
    }

    for (int i = 0; i < widget.resourcesData!.packaging!.length; i++) {
      if (packageType == widget.resourcesData!.packaging![i].id) {
        packaging = widget.resourcesData!.packaging![i].name;
        _currentSelectedPackaging = widget.resourcesData!.packaging![i];
      }
    }

    for (int i = 0; i < widget.resourcesData!.city!.length; i++) {
      if (widget.ordersDataModel?.deliverCityId == widget.resourcesData!.city![i].id) {
        receiverCityClass = widget.resourcesData!.city![i] ;

      }
    }
    if(_currentSelectedPackaging?.name == null){
      _currentSelectedPackaging = widget.resourcesData!.packaging?.first ;
    }
    for (int i = 0; i < senderCities.length; i++) {
      for (int x = 0;
          x < senderCities.elementAt(i).neighborhoods!.length;
          x++) {
        if (widget.ordersDataModel!.pickupNeighborhood ==
            senderCities.elementAt(i).neighborhoods!.elementAt(x).id) {
          senderCity = senderCities.elementAt(i).id;
        }
      }
    }

    for (int i = 0; i < receiverCities.length; i++) {
      for (int x = 0;
          x < receiverCities.elementAt(i).neighborhoods!.length;
          x++) {
        if (widget.ordersDataModel!.deliverNeighborhood == receiverCities.elementAt(i).neighborhoods!.elementAt(x).id) {
          receiverCity = receiverCities.elementAt(i).id;
        }
      }
    }
  }

  @override
  void initState() {
    try {
      setPackageData();
    } catch (e) {}

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return SafeArea(
      child: Scaffold(
        key: _drawerKey,
        drawer: CaptainDrawer(
          resourcesData: widget.resourcesData,
          width: screenWidth,
          height: screenHeight,
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white])),
          child: Column(
            children: [
              CaptainAppBar(
                drawerKey: _drawerKey, screenName: 'Edit shipment'.tr(),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            '${widget.ordersDataModel!.id}',
                            maxLines: 2,
                            style: TextStyle(
                                color: Color(0xff595959), fontSize: 25),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        EasyLocalization.of(context)!.locale == Locale('en')
                            ? ButtonTheme(
                                minWidth: 78,
                                height: 40,
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // Navigator.pushReplacement(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             CaptainOrdersListScreen(
                                    //               resourcesData:
                                    //               widget.resourcesData,
                                    //               orderList: widget.ordersList,
                                    //               reserved: true,
                                    //               index:1
                                    //             )));
                                  },
                                  child: Container(
                                    width: 78,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border:
                                            Border.all(color: Colors.black)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          Icons.arrow_back,
                                          size: 15,
                                        ),
                                        Text('Back'.tr()),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : ButtonTheme(
                                minWidth: 78,
                                height: 40,
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  onPressed: () {
                                    Navigator.pop(context);

                                    // Navigator.pushReplacement(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             CaptainOrdersListScreen(
                                    //               resourcesData:
                                    //               widget.resourcesData,
                                    //               orderList: widget.ordersList,
                                    //               reserved: true,
                                    //                 index:1
                                    //             )));
                                  },
                                  child: Container(
                                    width: 78,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border:
                                            Border.all(color: Colors.black)),
                                    child: EasyLocalization.of(context)!
                                                .locale ==
                                            Locale('en')
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Icon(
                                                Icons.arrow_back,
                                                size: 15,
                                              ),
                                              Text('Back'.tr()),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text('Back'.tr()),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 15,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                    Text(
                      'Edit Package'.tr(),
                      style: TextStyle(color: Color(0xff595959)),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: screenWidth,
                      // height: 200,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(25),
                              topLeft: Radius.circular(25)),
                          color: Constants.greyColor),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Container(
                            width: 350,
                          ),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            // Padding(
                            //   padding: EdgeInsets.symmetric(horizontal: 10 , vertical: 0 ),
                            //   child: Text('Weight'.tr()),
                            // ),
                            // SizedBox(height: 10,),
                            // Padding(
                            //     padding: EdgeInsets.symmetric(horizontal: 10 , vertical: 0 ),
                            //     child: Container(
                            //       width: screenWidth,
                            //       decoration: BoxDecoration(
                            //           color: Colors.white,
                            //           border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            //           borderRadius: BorderRadius.circular(12)),
                            //       child:Padding(
                            //         padding: const EdgeInsets.symmetric(vertical: 5 ,horizontal: 10),
                            //         child: DropdownButtonHideUnderline(
                            //           child: DropdownButton<Weight>(
                            //             items: widget.resourcesData!.weight!.map((Weight
                            //             dropDownStringItem) {
                            //               return DropdownMenuItem<
                            //                   Weight>(
                            //                 value:
                            //                 dropDownStringItem,
                            //                 child: Text(
                            //                   dropDownStringItem
                            //                       .name!,
                            //                   style: TextStyle(
                            //                       color: Color(
                            //                           0xFF959595),
                            //                       fontSize: 15),
                            //                 ),
                            //               );
                            //             }).toList(),
                            //             onChanged:
                            //                 (Weight? newValue) {
                            //               setState(() {
                            //
                            //                 _currentSelectedWeight =
                            //                     newValue;
                            //                 total = CalcPackagePrice(
                            //                     resourcesData:
                            //                     widget.resourcesData,
                            //                     senderCity:
                            //                     senderCity,
                            //                     deliverCity:
                            //                     receiverCity,
                            //                     packagingId:
                            //                     _currentSelectedPackaging!
                            //                         .id,
                            //                     weightId: _currentSelectedWeight!.id
                            //                 );
                            //               });
                            //             },
                            //             value:
                            //             _currentSelectedWeight,
                            //           ),
                            //         ),
                            //       ),
                            //     )),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: _packageWeightController,
                                decoration: kTextFieldDecoration.copyWith(
                                  hintText: 'Weight'.tr(),
                                  labelText: 'Weight ( Kg )'.tr(),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                              child: Text('Measures (cm)'.tr()),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: kTextFieldDecoration.copyWith(
                                          hintText: 'length'.tr(),
                                          labelText: 'length'.tr()),
                                      onFieldSubmitted: (e) {
                                        setState(() {});
                                      },
                                      onChanged: (e) {
                                        setState(() {});
                                      },
                                      controller: _packageLengthController,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: kTextFieldDecoration.copyWith(
                                          hintText: 'width'.tr(),
                                          labelText: 'width'.tr()),
                                      onFieldSubmitted: (e) {
                                        setState(() {});
                                      },
                                      onChanged: (e) {
                                        setState(() {});
                                      },
                                      controller: _packageWidthController,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: kTextFieldDecoration.copyWith(
                                          hintText: 'height'.tr(),
                                          labelText: 'height'.tr()),
                                      onFieldSubmitted: (e) {
                                        setState(() {});
                                      },
                                      onChanged: (e) {
                                        setState(() {});
                                      },
                                      controller: _packageHeightController,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10,),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(child: Text("Number of Pieces".tr(),style: TextStyle(fontSize: 16,color: Colors.blue),)),
                                  // SizedBox(width: 40,),
                                  CounterWidget(
                                    counter: (e){
                                      noOfPieces = e ;
                                    },
                                    backgroundColor: Colors.grey.withOpacity(0.1),
                                    initialValue: noOfPieces,


                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                              child: Text('Packaging'.tr()),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                // border: Border.all(color: Colors.grey.withOpacity(0.4))
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 0),
                                      child: Container(
                                        width: screenWidth,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Colors.grey.withOpacity(0.2)),
                                            borderRadius: BorderRadius.circular(12)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<Packaging>(
                                              items: widget.resourcesData!.packaging!
                                                  .map(
                                                      (Packaging dropDownStringItem) {
                                                return DropdownMenuItem<Packaging>(
                                                  value: dropDownStringItem,
                                                  child: Text(
                                                    dropDownStringItem.name!,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (Packaging? newValue) {
                                                setState(() {
                                                  _currentSelectedPackaging =
                                                      newValue;
                                                });
                                              },
                                              value: _currentSelectedPackaging,
                                            ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(child: Text("Number of Cartoons".tr(),style: TextStyle(fontSize: 16,color: Color(0xffCE5C5C)),)),
                                            // SizedBox(width: 40,),
                                            CounterWidget(
                                              counter: (e){
                                                noOfCartons = e ;
                                              },
                                              backgroundColor: Color(0xffCE5C5C).withOpacity(0.3),
                                              initialValue: noOfCartons,
                                              acceptZero: true,

                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),





                            Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                child: Container(
                                  width: screenWidth,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.grey.withOpacity(0.2)),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: CheckboxListTile(
                                    title: Text("fragile".tr()),
                                    value: checkedValue,
                                    onChanged: (newValue) {
                                      setState(() {
                                        checkedValue = !checkedValue!;
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .leading, //  <-- leading Checkbox
                                  ),
                                )),
                            SizedBox(
                              height: 10,
                            ),

                            // Padding(
                            //   padding:
                            //       const EdgeInsets.symmetric(horizontal: 10),
                            //   child: TextFormField(
                            //     keyboardType: TextInputType.number,
                            //     inputFormatters: [
                            //       FilteringTextInputFormatter.digitsOnly
                            //     ],
                            //     controller: _packageExtraController,
                            //     decoration: kTextFieldDecoration.copyWith(
                            //         hintText: 'extra'.tr()),
                            //   ),
                            // ),

                            // Padding(
                            //   padding: EdgeInsets.symmetric(horizontal: 10 , vertical: 10 ),
                            //   child: Container(
                            //     width: screenWidth,
                            //     height: 40,
                            //     decoration: BoxDecoration(
                            //         color: Colors.white,
                            //       border: Border.all(color: Colors.grey),
                            //       borderRadius: BorderRadius.all(Radius.circular(12))
                            //     ),
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       crossAxisAlignment: CrossAxisAlignment.center,
                            //       children: [
                            //         Text('Price : '.tr()),
                            //         Text('$total',
                            //         style: TextStyle(
                            //           fontSize: 23,
                            //           color: Constants.capPurple,
                            //           fontWeight: FontWeight.w400
                            //         ),
                            //         ),
                            //         SizedBox(width: 5,),
                            //         Text('SR'.tr(),
                            //         style: TextStyle(
                            //           fontSize: 13
                            //         ),
                            //         )
                            //
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            SizedBox(
                              height: 10,
                            ),

                            ButtonTheme(
                              child: FlatButton(
                                padding: EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                highlightColor: Constants.capPurple,
                                onPressed: () {
                                  if(receiverCityClass?.cod == "0" && _currentSelectedPackaging?.id == "4"){
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                              title: Text('Note !'.tr()),
                                              content: Text(
                                                'The cold packaging is not supported for the selected receiver city'
                                                    .tr(),
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text('ok'.tr()),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ]);
                                        });

                                  }else{
                                    setState(() {
                                      widget.ordersDataModel!.packaging =
                                          _currentSelectedPackaging!.id;
                                      // widget.ordersDataModel!.weight = _currentSelectedWeight!.id;
                                      widget.ordersDataModel!.weight =
                                          _packageWeightController.text;
                                      // widget.ordersDataModel!.comment =
                                      //     _packageCommentController.text;
                                      widget.ordersDataModel!.height =
                                          _packageHeightController.text;
                                      widget.ordersDataModel!.width =
                                          _packageWidthController.text;
                                      widget.ordersDataModel!.extra =
                                          _packageExtraController.text;
                                      widget.ordersDataModel!.length =
                                          _packageLengthController.text;
                                      widget.ordersDataModel!.accepted = true;
                                      widget.ordersDataModel!.noOfCartoons = noOfCartons.toString();
                                      widget.ordersDataModel!.quantity = noOfPieces.toString();

                                      if (checkedValue!) {
                                        widget.ordersDataModel!.fragile = '1';
                                      } else {
                                        widget.ordersDataModel!.fragile = '0';
                                      }

                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CaptainOrdersListScreen(
                                                      resourcesData:
                                                      widget.resourcesData,
                                                      orderList:
                                                      widget.ordersList,
                                                      reserved: true,
                                                      index: 1)));
                                    });





                                  }



                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Container(
                                    width: screenWidth,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            // colors: [Color(0xffE0DAE8), Color(0xffE6C7D0)])
                                            colors: [
                                              Constants.blueColor,
                                              Constants.redColor
                                            ])),
                                    child: Center(
                                        child: Text(
                                      'Confirm package'.tr(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 17),
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
