import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/ui/Client/addOrder.dart';

class QuickAccessCard extends StatelessWidget {
  ResourcesData? resourcesData;
  String? text;
  String? image;
  bool? hasAction;
  Color? color;
  Color? color2;
  Function? function;
  String? price;

  QuickAccessCard(
      {this.text,
      this.hasAction,
      this.image,
      this.color,
      this.price,
      this.color2,
      this.resourcesData,
      this.function});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double screenHeight = size.width;
    double screenWidth = size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: GestureDetector(
        onTap: function as void Function()?,
        child: Container(
          // width: screenWidth,
          // height: screenHeight*0.7,
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    hasAction!
                        ? Material(
                            type: MaterialType
                                .transparency, //Makes it usable on any background color, thanks @IanSmith
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: color2!, width: 1.0),
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                    15.0), //Something large to ensure a circle
                                focusColor: Colors.grey,
                                highlightColor: Colors.red,
                                onTap: function as void Function()?,
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 1),
                                    child:
                                        EasyLocalization.of(context)!.locale ==
                                                Locale('en')
                                            ? Icon(
                                                Icons.arrow_right_alt_sharp,
                                                color: color2,
                                                size: 30,
                                              )
                                            : Icon(
                                                Icons.keyboard_arrow_left_sharp,
                                                color: color2,
                                                size: 30,
                                              )),
                              ),
                            ))
                        : Padding(
                            padding: EdgeInsets.all(15),
                            child: Container(
                              height: 70,
                            ),
                          ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      image!,
                      width: screenWidth * 0.4,
                      height: screenHeight * 0.3,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      text!,
                      style: TextStyle(fontSize: 17),
                    ),
                    image == 'assets/images/cold.png' ||
                            image == 'assets/images/coldCartoon.png'
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "4 - 15".tr(),
                                    style: TextStyle(fontSize: 17),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    "°C".tr(),
                                    style: TextStyle(fontSize: 17),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Container(),
                    price != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "+ $price",
                                    style: TextStyle(fontSize: 17),
                                  ),
                                  SizedBox(
                                    width: 1,
                                  ),
                                  Text(
                                    "SR".tr(),
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    "(Taxes Included)".tr(),
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 30,
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
