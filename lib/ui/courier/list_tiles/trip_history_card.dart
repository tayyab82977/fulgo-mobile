import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:xturbox/data_providers/models/tripModel.dart';
import 'package:xturbox/utilities/Constants.dart';

class TripHistoryCard extends StatefulWidget {
  TripModel tripModel ;
  TripHistoryCard({ required this.tripModel});

  @override
  State<TripHistoryCard> createState() => _TripHistoryCardState();
}

class _TripHistoryCardState extends State<TripHistoryCard> {

   var start ;
   var end ;
  Duration? drivingTime  ;


   List<String> durationToString(int? minutes) {
     var d = Duration(minutes:minutes ?? 0);
     List<String> parts = d.toString().split(':');
     List<String> result = [];
     result.add(parts[0].padLeft(2, '0'));
     result.add(parts[1].padLeft(2, '0'));
     return result;
   }

   @override
  void initState() {
     try{
       start =  DateTime.parse(widget.tripModel.createdAt ?? "1974-03-20 00:00:00.000");
       end =  DateTime.parse(widget.tripModel.updatedAt ?? "1974-03-20 00:00:00.000");
       drivingTime = end.difference(start);
     }catch(e){

     }

    super.initState();
  }

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      children: [
                        Container(
                            decoration:BoxDecoration(
                              color: Constants.blueColor,
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text( widget.tripModel.origin ??"" , style: TextStyle(color: Colors.white , fontSize: 17), ),
                            )),

                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward , size: 22,),
                  Flexible(
                    child: Column(
                      children: [
                        Container(
                            decoration:BoxDecoration(
                                color: Constants.blueColor,
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(widget.tripModel.destination ?? "" , style: TextStyle(color:Colors.white , fontSize: 17), ),
                            )),

                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              drivingTime != null ?  Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(durationToString(drivingTime?.inMinutes)[0] + " "+ "Hour".tr(), style: TextStyle(color: Constants.blueColor , fontSize: 17), ),
                  SizedBox(width: 10,),
                  Text(durationToString(drivingTime?.inMinutes)[1] + " " +"Minute".tr()  , style: TextStyle(color: Constants.blueColor , fontSize: 17), ),
                ],
              ) : SizedBox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text((widget.tripModel.km  ?? "")+ " "+ "Km".tr(), style: TextStyle(color: Constants.blueColor , fontSize: 17), ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(DateFormat('yyyy-MM-dd').format(DateFormat("yyyy-MM-dd").parse(widget.tripModel.createdAt ?? "")) , style: TextStyle(color: Colors.grey , fontSize: 14),),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
