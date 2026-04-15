import 'package:flutter/material.dart';
import 'package:Fulgox/data_providers/models/clientPaymentsDataModel.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/utilities/idToNameFunction.dart';

class TransactionsCard extends StatefulWidget {
  ClientPaymentsDataModel? clientPaymentsDataModel ;
  ResourcesData? resourcesData ;

  TransactionsCard({this.clientPaymentsDataModel , this.resourcesData});
  @override
  _TransactionsCardState createState() => _TransactionsCardState();
}

class _TransactionsCardState extends State<TransactionsCard> {
  double? screenWidth, screenHeight, width, height;
  String? paymentType ;
  int amount = 0 ;
  String? dateDays ;
  String? dateMonth ;
  String? dateYear ;
  int timeH = 0;
  String? timeM ;
  String AMPM = "am";

  gettingDate(){
    timeM = widget.clientPaymentsDataModel?.stamp.toString().substring(14, 16);
    timeH = int.parse(widget.clientPaymentsDataModel?.stamp.toString().substring(11, 13) ?? "");
    if(timeH > 12 ){
      timeH = timeH - 12 ;
      AMPM = "pm".tr();

    }else if (timeH == 12){
      AMPM = "pm".tr();
    }else if (timeH == 0){
      timeH = timeH + 12 ;
      AMPM = "am".tr();
    }else{
      AMPM = 'am'.tr();
    }

  }
  getName(){
    print(widget.resourcesData?.paymentType?.length);
    paymentType = IdToName.idToName(
        'paymentType', widget.clientPaymentsDataModel?.type??"");
    // for(int i = 0 ; i < (widget.resourcesData?.paymentType?.length ?? 0) ; i++){
    //   if(widget.clientPaymentsDataModel?.type == widget.resourcesData?.paymentType?[i].id ){
    //     paymentType = widget.resourcesData?.paymentType?[i].name ;
    //   }
    // }
    if(widget.clientPaymentsDataModel?.amount != null){
       amount =int.parse(widget.clientPaymentsDataModel?.amount ?? "");
    }


  }
  @override
  void initState() {
    try{
      gettingDate();
      getName() ;
    }catch(e){}

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    height = size.height;
    width = size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: screenWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              // color: amount > 0 ? Color(0xFF56D340) : amount < 0 ? Colors.red : Colors.white ,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(widget.clientPaymentsDataModel?.stamp?.substring(0,10) ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          ),
                          SizedBox(width: 15,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text('$timeH:$timeM',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  Text(AMPM.tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      widget.clientPaymentsDataModel?.receipt != null ?
                      Row(
                        children: [
                          Text('Receipt:'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              )),
                          SizedBox(width: 2,),

                          Text(widget.clientPaymentsDataModel?.receipt ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ) : widget.clientPaymentsDataModel?.description != null ?
                      Row(
                        children: [
                          Text('Shipment id:'.tr()),
                          SizedBox(width: 2,),
                          Text(widget.clientPaymentsDataModel?.description ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ) : SizedBox()
                      // widget.clientPaymentsDataModel?.type == "5"  ||  widget.clientPaymentsDataModel?.type == "8" ||  widget.clientPaymentsDataModel?.type == "9"?
                      // Row(
                      //   children: [
                      //     Text('Shipment id:'.tr()),
                      //     SizedBox(width: 2,),
                      //     Text(widget.clientPaymentsDataModel?.description ?? '',
                      //         style: TextStyle(
                      //           fontWeight: FontWeight.w600,
                      //         )),
                      //   ],
                      // ) :
                      // widget.clientPaymentsDataModel?.type != "11" ?
                      // Row(
                      //       children: [
                      //         Text('Receipt:'.tr(),
                      //             style: TextStyle(
                      //               fontWeight: FontWeight.w600,
                      //             )),
                      //         SizedBox(width: 2,),
                      //
                      //         Text(widget.clientPaymentsDataModel?.receipt ?? '',
                      //   style: TextStyle(
                      //         fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      //       ],
                      //     ) : SizedBox()

                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(paymentType ?? "",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:  Colors.black ,
                          fontSize: 11
                        ),
                      ),
                      SizedBox(height: 8,),
                      Row(
                        children: [
                          Text(widget.clientPaymentsDataModel?.amount??'',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 19,
                              color:Colors.black ,
                            ),
                          ),
                          SizedBox(width: 5,),
                          Text("SR".tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 9,
                              color: Colors.black ,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          )

        ],
      ),
    );
  }
}
