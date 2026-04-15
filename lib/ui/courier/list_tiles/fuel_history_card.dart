import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:Fulgox/data_providers/models/fuel.dart';
import 'package:Fulgox/utilities/Constants.dart';


class FuelHistoryCard extends StatelessWidget {
  FuelEntryModel? fuelEntryModel ;
  FuelHistoryCard({this.fuelEntryModel});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Amount".tr() + " : " , style: TextStyle(color: Constants.blueColor.withOpacity(0.6) , fontSize: 17), ),
                  SizedBox(width: 4,),
                  Text((fuelEntryModel?.amount ?? "") +" "+"SR".tr() , style: TextStyle(color: Constants.blueColor , fontSize: 17), ),
                ],
              ),
              Row(
                children: [
                  Text("Type".tr() + " : " , style: TextStyle(color: Constants.blueColor.withOpacity(0.6) , fontSize: 17), ),
                  SizedBox(width: 4,),
                  Text(fuelEntryModel?.grade ?? "" , style: TextStyle(color: Constants.blueColor , fontSize: 17), ),
                ],
              ),
              Row(
                children: [
                  Text("receipt number".tr() + " : " , style: TextStyle(color: Constants.blueColor.withOpacity(0.6) , fontSize: 17), ),
                  SizedBox(width: 4,),
                  Text(fuelEntryModel?.reference ?? "" , style: TextStyle(color: Constants.blueColor , fontSize: 17), ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(fuelEntryModel?.station ?? "" , style: TextStyle(color: Constants.blueColor , fontSize: 13), ),
                  Icon(Icons.location_pin,size: 14,),

                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(DateFormat('yyyy-MM-dd').format(DateFormat("yyyy-MM-dd").parse(fuelEntryModel?.createdAt.toString() ??  "2022-01-01 20:29:02" )) , style: TextStyle(color: Colors.grey , fontSize: 14),),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}