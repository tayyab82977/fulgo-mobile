import 'package:flutter/material.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:flutter/services.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/models/captainOrdersDataModel.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/ui/custom%20widgets/customCheckBox.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/utilities/comFunctions.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';

import 'custom_loading.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';

class Dialogs {
  static double CalcPackagePrice(
      {String? senderCity,
      String? deliverCity,
      ResourcesData? resourcesData,
      String? weightId,
      String? packagingId}) {
    double total;
    double weightPrice;
    double? packagingPrice;

    if (senderCity == deliverCity) {
      // for (int i = 0; i < resourcesData.weight.length; i++) {
      //   if (weightId == resourcesData.weight[i].id) {
      //     var weightPriceDouble =
      //     double.parse(resourcesData.weight[i].prices[0].price);
      //     weightPrice = weightPriceDouble;
      //   }
      // }
      var weightPriceDouble = double.parse(resourcesData!.priceInside);
      weightPrice = weightPriceDouble;
      var packagingPriceDouble;
      for (int i = 0; i < resourcesData.packaging!.length; i++) {
        if (packagingId == resourcesData.packaging![i].id) {
          packagingPriceDouble =
              double.tryParse(resourcesData.packaging?[i].extra ?? "0");

          packagingPrice = packagingPriceDouble;
        }
      }
      if (packagingPrice == null) {
        packagingPriceDouble =
            double.tryParse(resourcesData.packaging?.first.extra ?? "0");
      }

      total = weightPrice + (packagingPriceDouble ?? 0);

      return total;
    } else {
      // for (int i = 0; i < widget.resourcesData.weight.length; i++) {
      //   if (weightId == widget.resourcesData.weight[i].id) {
      //     var weightPriceDouble =
      //     double.parse(widget.resourcesData.weight[i].prices[0].price);
      //     weightPrice = weightPriceDouble;
      //   }
      // }
      var weightPriceDouble = double.parse(resourcesData!.priceOutside);
      weightPrice = weightPriceDouble;
      var packagingPriceDouble;
      for (int i = 0; i < resourcesData.packaging!.length; i++) {
        if (packagingId == resourcesData.packaging![i].id) {
          packagingPriceDouble =
              double.tryParse(resourcesData.packaging![i].extra!);
          // double packagingPriceDouble = 10 ;

          packagingPrice = packagingPriceDouble;
        }
      }
      total = weightPrice + (packagingPriceDouble ?? 0);

      return total;
    }
  }

  static Future<Packages> CreateShipmentDialog(
      BuildContext context,
      ErCity senderCity,
      ErCity receiverCity,
      Neighborhoods senderZone,
      Neighborhoods receiverZone,
      double width,
      double height,
      Packages? editedPackage,
      String? selectedPackaging) async {
    //create / edit package

    bool checkedValue = false;

    final _codController = TextEditingController();
    final _packageCommentController = TextEditingController();
    final _quantityController = TextEditingController();
    double codDoubleValue = 0;
    bool codCheckedValue = false;
    Packaging? _currentSelectedPackaging;

    //fill the data for the edit package

    if (editedPackage != null) {
      codDoubleValue = 0;
      checkedValue = editedPackage.fragile == '1' ? true : false;
      _packageCommentController.text = editedPackage.comment ?? "";
      _codController.text = editedPackage.cod ?? "";
      _quantityController.text = editedPackage.quantity ?? "";
      codCheckedValue = editedPackage.cod != null &&
              editedPackage.cod != '0' &&
              editedPackage.cod != ''
          ? true
          : false;
      for (int i = 0; i < SavedData.resourcesData.packaging!.length; i++) {
        if (editedPackage.packaging ==
            SavedData.resourcesData.packaging![i].id) {
          _currentSelectedPackaging = SavedData.resourcesData.packaging![i];
        }
      }
      if (editedPackage.cod != "" && editedPackage.cod != null) {
        try {
          codDoubleValue = double.parse(editedPackage.cod!);
        } catch (e) {
          codDoubleValue = 0.0;
        }
      }
    } else {
      try {
        if (selectedPackaging != null) {
          try {
            switch (selectedPackaging) {
              case "noPackaging":
                {
                  _currentSelectedPackaging =
                      SavedData.resourcesData.packaging![0];
                }
                break;

              case "liquid":
                {
                  _currentSelectedPackaging =
                      SavedData.resourcesData.packaging![1];
                }
                break;
              case "frozen":
                {
                  _currentSelectedPackaging =
                      SavedData.resourcesData.packaging![2];
                }
                break;
              default:
                {
                  _currentSelectedPackaging =
                      SavedData.resourcesData.packaging![0];
                }
                break;
            }
          } catch (e) {
            _currentSelectedPackaging = SavedData.resourcesData.packaging![0];
          }
        } else {
          _currentSelectedPackaging = SavedData.resourcesData.packaging!.first;
        }
      } catch (e) {
        _currentSelectedPackaging = Packaging();
      }
    }
    Packages package = await showDialog(
        context: context,
        builder: (BuildContext context) {
          double price = 0;
          // setThePackagingType();
          try {
            price = CalcPackagePrice(
                resourcesData: SavedData.resourcesData,
                senderCity: senderCity.id,
                deliverCity: receiverCity.id,
                packagingId: _currentSelectedPackaging!.id);
          } catch (e) {}

          return StatefulBuilder(
            builder: (context, setState2) {
              return Align(
                alignment: Alignment.topCenter,
                child: AlertDialog(
                  contentPadding: EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                            width: width,
                            decoration: BoxDecoration(
                                color: Color(0xffF9F9F9),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Add Package'.tr(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Icon(
                                          Icons.close,
                                          size: 15,
                                        ))
                                  ]),
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: Center(
                              child: InkWell(
                                onTap: () {
                                  setState2(() {
                                    checkedValue = !checkedValue;
                                  });
                                },
                                child: Container(
                                  width: width,
                                  height: 45,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: checkedValue
                                              ? Constants.blueColor
                                              : Colors.grey)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Theme(
                                              data: Theme.of(context).copyWith(
                                                unselectedWidgetColor:
                                                    Constants.blueColor,
                                              ),
                                              child: SizedBox(
                                                  height: 20.0,
                                                  width: 20.0,
                                                  child: CustomCheckBox(
                                                    checkedColor:
                                                        Constants.blueColor,
                                                    unCheckedColor: Colors.grey,
                                                    backgroundColor:
                                                        Colors.white,
                                                    checked: checkedValue,
                                                  )),
                                            ),
                                            SizedBox(
                                              width: 12,
                                            ),
                                            Text(
                                              'fragile'.tr(),
                                              style: TextStyle(
                                                  fontSize: width * 0.03,
                                                  color: checkedValue
                                                      ? Constants.blueColor
                                                      : Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: SvgPicture.asset(
                                          "assets/images/fragile.svg",
                                          width: 25,
                                          height: 25,
                                          color:
                                              checkedValue ? null : Colors.grey,
                                          placeholderBuilder: (context) =>
                                              CustomLoading(),

                                          // height: 18.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Container(
                            width: width,
                            height: 45,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Constants.blueColor)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    'Packaging'.tr(),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                SavedData.resourcesData.packaging!.length > 0
                                    ? Expanded(
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<Packaging>(
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                            },
                                            items: SavedData
                                                .resourcesData.packaging
                                                ?.map((Packaging
                                                    dropDownStringItem) {
                                              return DropdownMenuItem<
                                                  Packaging>(
                                                key:
                                                    const ValueKey('packaging'),
                                                value: dropDownStringItem,
                                                child: Text(
                                                  dropDownStringItem.name ?? "",
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 14),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (Packaging? newValue) {
                                              setState2(() {
                                                _currentSelectedPackaging =
                                                    newValue!;
                                                try {
                                                  price = CalcPackagePrice(
                                                      resourcesData: SavedData
                                                          .resourcesData,
                                                      senderCity: senderCity.id,
                                                      deliverCity:
                                                          receiverCity.id,
                                                      packagingId:
                                                          _currentSelectedPackaging!
                                                              .id);
                                                } catch (e) {}
                                              });
                                            },
                                            value: _currentSelectedPackaging,
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                        receiverCity.cod == "1"
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                child: Column(
                                  children: [
                                    Center(
                                      child: InkWell(
                                        key: const ValueKey('cod'),
                                        onTap: () {
                                          setState2(() {
                                            codCheckedValue = !codCheckedValue;
                                            if (!codCheckedValue) {
                                              _codController.clear();
                                            }
                                          });
                                        },
                                        child: Container(
                                          width: width,
                                          height: 45,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: codCheckedValue
                                                  ? BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(8),
                                                      topLeft:
                                                          Radius.circular(8))
                                                  : BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: codCheckedValue
                                                      ? Constants.blueColor
                                                      : Colors.grey)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Theme(
                                                          data:
                                                              Theme.of(context)
                                                                  .copyWith(
                                                            unselectedWidgetColor:
                                                                Constants
                                                                    .blueColor,
                                                          ),
                                                          child: SizedBox(
                                                              height: 20.0,
                                                              width: 20.0,
                                                              child:
                                                                  CustomCheckBox(
                                                                checkedColor:
                                                                    Constants
                                                                        .blueColor,
                                                                unCheckedColor:
                                                                    Colors.grey,
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                checked:
                                                                    codCheckedValue,
                                                              )),
                                                        ),
                                                        SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(
                                                          'Cash on delivery'
                                                              .tr(),
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: codCheckedValue
                                                                  ? Constants
                                                                      .blueColor
                                                                  : Colors
                                                                      .grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    child: SvgPicture.asset(
                                                      "assets/images/cash-payment.svg",
                                                      width: 25,
                                                      height: 25,
                                                      color: codCheckedValue
                                                          ? null
                                                          : Colors.grey,
                                                      placeholderBuilder:
                                                          (context) =>
                                                              CustomLoading(),

                                                      // height: 18.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    codCheckedValue && receiverCity.cod == "1"
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextFormField(
                                                key: const ValueKey('codValue'),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                decoration: kTextFieldDecoration
                                                    .copyWith(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    8.0),
                                                            bottomRight: Radius
                                                                .circular(8.0)),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey,
                                                        width: 1.15),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    8.0),
                                                            bottomRight: Radius
                                                                .circular(8.0)),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Constants.blueColor,
                                                        width: 1.15),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    8.0),
                                                            bottomRight: Radius
                                                                .circular(8.0)),
                                                  ),
                                                  prefixIcon: Icon(
                                                    MdiIcons.cash,
                                                    color: Color(0xFF414141),
                                                    size: 20,
                                                  ),
                                                  hintText: 'value'.tr(),
                                                  hintStyle: TextStyle(
                                                      fontSize: width * 0.03),
                                                ),
                                                controller: _codController,
                                                onFieldSubmitted: (value) {
                                                  try {
                                                    setState2(() {
                                                      codDoubleValue =
                                                          double.parse(value);
                                                    });
                                                  } catch (e) {}
                                                },
                                                onChanged: (value) {
                                                  try {
                                                    setState2(() {
                                                      codDoubleValue =
                                                          double.parse(value);
                                                    });
                                                  } catch (e) {}
                                                },
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                'This value that will get back to you after delivery'
                                                    .tr(),
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Text(
                                                "Pleas do not add the delivery cost on this value just if the the delivery cost on you"
                                                    .tr(),
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ],
                                ))
                            : Container(),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: TextFormField(
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: false),
                            decoration: kTextFieldDecoration.copyWith(
                              prefixIcon: Icon(
                                MdiIcons.counter,
                                color: Color(0xFF414141),
                                size: 20,
                              ),
                              hintText: 'no. of pieces'.tr(),
                              hintStyle: TextStyle(fontSize: width * 0.03),
                            ),
                            controller: _quantityController,
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: TextFormField(
                            decoration: kTextFieldDecoration.copyWith(
                              prefixIcon: Icon(
                                MdiIcons.comment,
                                color: Color(0xFF414141),
                                size: 20,
                              ),
                              hintText: 'parcel details'.tr(),
                              hintStyle: TextStyle(fontSize: width * 0.03),
                            ),
                            controller: _packageCommentController,
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Container(
                            height: 70,
                            width: width,
                            decoration: BoxDecoration(
                              color: Color(0xffF9F9F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Estimated price'.tr(),
                                  style: TextStyle(fontSize: 7),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$price',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Constants.blueColor,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text('SR'.tr(),
                                        style: TextStyle(fontSize: 9)),
                                  ],
                                ),
                                Text(
                                  "(Taxes Included)".tr(),
                                  style: TextStyle(fontSize: 9),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: width,
                          height: 50,
                          child: ElevatedButton(
                              key: const ValueKey('savePackage'),
                              child: Text(
                                'Add Package'.tr(),
                                style: TextStyle(
                                    fontSize: width * 0.04,
                                    color: Colors.white),
                              ),
                              onPressed: () {
                                setState2(() {
                                  if (!codCheckedValue) {
                                    _codController.clear();
                                  }

                                  Packages myNewPackage = Packages(
                                    extra: "0",
                                    quantity:
                                        _quantityController.text.isNotEmpty
                                            ? _quantityController.text
                                            : "1",
                                    length: 0,
                                    width: 0,
                                    fragile: checkedValue ? '1' : '0',
                                    packaging: _currentSelectedPackaging!.id,
                                    weight: "1",
                                    height: 0,
                                    comment: _packageCommentController.text,
                                    cod: _codController.text.isEmpty
                                        ? ''
                                        : _codController.text,
                                    price: price,
                                  );
                                  _packageCommentController.clear();
                                  // pop out of the dialog and return package data
                                  Navigator.of(context).pop(myNewPackage);
                                });
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });

    return package;
  }
}
