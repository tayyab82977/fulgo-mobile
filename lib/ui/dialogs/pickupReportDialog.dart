import 'package:flutter/material.dart';
import 'package:Fulgox/data_providers/models/pickupReportModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/ui/courier/captainDashboard.dart';
import 'package:Fulgox/utilities/Constants.dart';

class PickupReportDialog {
  static showPickupReportDialog(PickupReportModel pickupReportModel,
      BuildContext context, ResourcesData resourcesData) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          if (pickupReportModel.fail != 0 &&
              (pickupReportModel.errors?.isNotEmpty ?? false)) {
            return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Successfully picked'.tr(),
                          style: TextStyle(
                            fontSize: 19,
                            color: Constants.capLightGreen,
                          ),
                        ),
                        Text(
                          " : ",
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          '${pickupReportModel.success.toString()}',
                          style: TextStyle(
                              color: Constants.capLightGreen, fontSize: 22),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Row(
                      children: [
                        Text(
                          'Failed picked'.tr(),
                          style: TextStyle(
                            fontSize: 19,
                            color: Constants.capDarkPink,
                          ),
                        ),
                        Text(
                          " : ",
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          '${pickupReportModel.fail.toString()}',
                          style: TextStyle(
                              color: Constants.capDarkPink, fontSize: 22),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                            // border: Border.all(color: Constants.capDarkPink,
                            // color:  Constants.capDarkPurple,
                            borderRadius: BorderRadius.circular(10)),
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                            itemCount: pickupReportModel.errors?.length ?? 0,
                            itemBuilder: (context, i) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pickupReportModel.errors![i].id.toString() +
                                        " : ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Constants.capDarkPink,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: (pickupReportModel
                                                  .errors?[i].error?.length ??
                                              0) *
                                          80,
                                      child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: pickupReportModel
                                                  .errors?[i].error?.length ??
                                              0,
                                          itemBuilder: (context, j) {
                                            return Text(
                                                pickupReportModel
                                                    .errors![i].error![j]
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black));
                                          }),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              );
                            }),
                      ),
                    )
                  ],
                ),
                actions: [
                  ElevatedButton(
                    child: Text('ok'.tr()),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => CaptainDashboard(
                            resourcesData: resourcesData,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ]);
          } else {
            return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                title: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Successfully picked'.tr(),
                          style: TextStyle(
                            fontSize: 19,
                            color: Constants.capLightGreen,
                          ),
                        ),
                        Text(
                          " : ",
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          '${pickupReportModel.success.toString()}',
                          style: TextStyle(
                              color: Constants.capLightGreen, fontSize: 22),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed picked'.tr(),
                          style: TextStyle(
                            fontSize: 19,
                            color: Constants.capDarkPink,
                          ),
                        ),
                        Text(
                          " : ",
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          '${pickupReportModel.fail.toString()}',
                          style: TextStyle(
                              color: Constants.capDarkPink, fontSize: 22),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    child: Text('ok'.tr()),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => CaptainDashboard(
                            resourcesData: resourcesData,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ]);
          }
        });
  }
}
