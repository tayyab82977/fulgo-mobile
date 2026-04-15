import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:Fulgox/data_providers/models/violation.dart';
import 'package:Fulgox/utilities/Constants.dart';


class ViolationsCard extends StatelessWidget {
  ViolationModel? violationModel ;
  ViolationsCard({this.violationModel});
  @override
  Widget build(BuildContext context) {
    return  Padding(
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
              Text(violationModel?.name ?? "" , style: TextStyle(color: Constants.blueColor , fontSize: 17), ),
              Text(violationModel?.description ?? "" , style: TextStyle(color: Constants.blueColor.withOpacity(0.6) , fontSize: 15), ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color:violationModel?.status.toString() == "1" ?  Colors.green : violationModel?.status.toString() == "2"  ?Colors.grey : Constants.redColor ,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(violationModel?.statusName ?? "" , style: TextStyle(color: Colors.white , fontSize: 15), ),
                    ),

                  ),
                  SizedBox(width: 10,),
                  Container(
                    decoration: BoxDecoration(
                      color: Constants.redColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(violationModel?.groupName ?? "" , style: TextStyle(color: Colors.white , fontSize: 15), ),
                    ),

                  ),
                ],
              ),
              SizedBox(height: 10,),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(DateFormat('yyyy-MM-dd').format(DateFormat("yyyy-MM-dd").parse(violationModel?.createdAt ?? "")) , style: TextStyle(color: Colors.grey , fontSize: 14),),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
