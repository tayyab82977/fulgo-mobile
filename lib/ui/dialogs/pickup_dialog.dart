import 'package:flutter/material.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import '../courier/bulkPickupScreen.dart';
import '../courier/captainOrdersList.dart';

class PickupDialog {

  static showPickupDialog({required BuildContext context, required List<OrdersDataModelMix> capOrderList}){
    showDialog(
        context: context,
        builder: (BuildContext context){
          var mySize = MediaQuery.of(context).size;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            content: Container(
              height: mySize.height / 100 * 35,
              width:  mySize.width / 100 * 80,
              margin: EdgeInsets.all(15),
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CaptainOrdersListScreen(
                                    resourcesData: SavedData.resourcesData,
                                    orderList: capOrderList,
                                    reserved: true,
                                    index: 0
                                )));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(38)),
                          color: Color(0xFFf4f4f4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(38)),
                                color: Color(0xFFf4f4f4),
                              ),
                              width: mySize.width / 100 * 20,
                              margin: EdgeInsets.all(10),
                              child: Image.asset('assets/images/box.png',height: mySize.width / 100 * 15,),
                            ),
                            Expanded(
                              child: Text('Single Pickup'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                            )
                          ],
                        ),),
                    ),
                  ),
                  SizedBox(height: 30,),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    BulkPickUpScreen(
                                      resourcesData: SavedData.resourcesData,
                                      acceptedOrder: capOrderList,
                                      returnToClient: true,
                                    )));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(38)),
                          color: Color(0xFFf4f4f4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(38)),
                                color: Color(0xFFf4f4f4),
                              ),
                              width: mySize.width / 100 * 20,
                              margin: EdgeInsets.all(10),
                              child: Image.asset('assets/images/bulk_pickup.png', height: mySize.width / 100 * 15,),
                            ),
                            Expanded(
                              child: Container(
                                  child: Text('Bulk Pickup'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)),
                            ),
                          ],
                        ),),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}