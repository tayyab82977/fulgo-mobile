import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Fulgox/controllers/get_orders_controller.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/ui/Client/MyOrders.dart';
import 'package:Fulgox/ui/custom%20widgets/myAppBar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/utilities/Constants.dart';

class SuccessOrderScreen extends StatelessWidget {
  ResourcesData? resourcesData;
  ProfileDataModel? dashboardDataModel;
  bool fromHomeScreen = false;
  GetOrdersController? getOrdersController;

  SuccessOrderScreen(
      {this.resourcesData,
      this.dashboardDataModel,
      this.fromHomeScreen = false,
      this.getOrdersController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.clientBackgroundGrey,
      body: Column(
        children: [
          const ClientAppBar(),
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/images/success.svg",
                    height: 40,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your Shipment has been add successfully'.tr(),
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Color(0xFF008000), fontSize: 14),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  Text(
                    'Our courier will contact you soon'.tr(),
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: Text(
                      'Note_For_Client'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 21,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Image.asset(
                      'assets/images/noteForShipID.jpeg',
                    ),
                  ),
                  ButtonTheme(
                    minWidth: 300,
                    height: 50,
                    child: ElevatedButton(
                        key: const ValueKey("newOrderSuccess"),
                        child: Text(
                          'Continue'.tr(),
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        onPressed: () {
                          if (fromHomeScreen) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      MyOrdersScreen(
                                        dashboardDataModel: dashboardDataModel,
                                        resourcesData: resourcesData,
                                      )),
                            );
                          } else {
                            Navigator.of(context).pop();
                            getOrdersController?.getOrders();
                          }
                        }),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
