import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Fulgox/data_providers/models/memberBalanceModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/utilities/Constants.dart';

class ClientBalanceDialog {
  static showClientBalanceDialog(
      ClientBalanceModel? memberBalanceModel, BuildContext context) {
    String pricingOutside = '';
    String pricingInside = '';
    String priceInside = SavedData.resourcesData.priceInside ?? "";
    String priceOutside = SavedData.resourcesData.priceOutside ?? "";
    bool existInPricing = false;
    if ((memberBalanceModel?.pricing?.length ?? 0) > 1) {
      existInPricing = true;
      pricingOutside = memberBalanceModel?.pricing?[1].total.toString() ?? "";
      pricingInside = memberBalanceModel?.pricing?[0].total.toString() ?? "";
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "Balance : ".tr(),
                        style: TextStyle(fontSize: 15),
                      ),
                      (memberBalanceModel?.balance ?? 0) > 0
                          ? Flexible(
                              child: Text(
                                  memberBalanceModel?.balance.toString() ?? "",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  )))
                          : Flexible(
                              child: Text(
                                  memberBalanceModel?.balance.toString() ?? "",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ))),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "SR".tr(),
                        style: TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 1,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "Price inside : ".tr(),
                        style: TextStyle(fontSize: 15),
                      ),
                      existInPricing
                          ? Flexible(
                              child: Text(
                              pricingInside,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ))
                          : Flexible(
                              child: Text(
                              priceInside,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            )),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "SR".tr(),
                        style: TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 1,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "Price outside : ".tr(),
                        style: TextStyle(fontSize: 15),
                      ),
                      existInPricing
                          ? Flexible(
                              child: Text(
                              pricingOutside,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ))
                          : Flexible(
                              child: Text(
                              priceOutside,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            )),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "SR".tr(),
                        style: TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 1,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "Offers :".tr(),
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    // height: 60,
                    child: ListView.builder(
                        itemCount:
                            memberBalanceModel?.packageOffer?.length ?? 0,
                        itemBuilder: (context, i) {
                          return offerCard(
                              memberBalanceModel?.packageOffer?[i]);
                        }),
                  ),
                )
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("ok".tr()))
            ],
          );
        });
  }

  static Widget offerCard(PackageOffer? offer) {
    // String packaging = "";
    // String weightRange = "";
    // for (int i = 0; i < (SavedData.resourcesData.packaging?.length ?? 0); i++) {
    //   if (offer?.package == SavedData.resourcesData.packaging?[i].id) {
    //     packaging = SavedData.resourcesData.packaging![i].name.toString();
    //   }
    // }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
            color: Constants.capLigthPurple,
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  right: 8.0, top: 8.0, left: 8.0, bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    decoration: ShapeDecoration(
                      color: Constants.capDarkPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Center(
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                          child: Text(
                            "Distance".tr(),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Container(
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(offer?.distance.toString() ?? "",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: 8.0, top: 4.0, left: 8.0, bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    decoration: ShapeDecoration(
                      color: Constants.capDarkPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Center(
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                          child: Text(
                            "Packaging".tr(),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Container(
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(offer?.package ?? "",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              )),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: 8.0, top: 4.0, left: 8.0, bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    decoration: ShapeDecoration(
                      color: Constants.capDarkPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Center(
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                          child: Text(
                            "Weight".tr(),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    child: Container(
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(offer?.weight ?? "",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              )),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: 8.0, top: 4.0, left: 8.0, bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    decoration: ShapeDecoration(
                      color: Constants.capDarkPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Center(
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                          child: Text(
                            "Count".tr(),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          )),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Container(
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(offer?.count.toString() ?? "",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              )),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
