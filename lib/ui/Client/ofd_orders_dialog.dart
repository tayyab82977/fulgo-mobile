import 'package:flutter/material.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/ui/custom%20widgets/OrdersCard.dart';
import 'package:xturbox/utilities/Constants.dart';


class OfdOrdersDialog extends StatefulWidget {
  ResourcesData? resourcesData;
  List<OrdersDataModelMix>? ordersList;
  bool? hasAction;
  ProfileDataModel? dashboardDataModel;
  Key? key;
  int? index;
  bool? showStatus;
  String? taskId ;
   OfdOrdersDialog({this.dashboardDataModel , this.ordersList , this.resourcesData , this.hasAction}) ;

  @override
  _OfdOrdersDialogState createState() => _OfdOrdersDialogState();
}

class _OfdOrdersDialogState extends State<OfdOrdersDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50,
              width: 700,
              decoration: BoxDecoration(
                color: Constants.blueColor
              ),
              child: Center(child: Text("Shipments out for delivery",style: TextStyle(color: Colors.white),)),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.ordersList?.length,
                    itemBuilder: (context , i){
                      return OrdersCard(
                        ordersDataModel: widget.ordersList?[i],
                        dashboardDataModel: widget.dashboardDataModel,
                        resourcesData: widget.resourcesData,
                        hasAction: false,
                      );
                    }),
              ),
            )
            // Wrap(
            //   children: (widget.ordersList ?? []).map((e) => OrdersCard(
            //     ordersDataModel: e,
            //     dashboardDataModel: widget.dashboardDataModel,
            //     resourcesData: widget.resourcesData,
            //     hasAction: false,
            //   )).toList(),
            // )
          ],
        ),
    );
  }
}
