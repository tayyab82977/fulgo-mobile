import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/captainOrdersDataModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/ui/custom%20widgets/dialog.dart';
import 'package:xturbox/utilities/idToNameFunction.dart';

class PackageCard extends StatefulWidget {

  // Packages? packages ;
  bool newPackage = false ;
  ErCity? currentCitySelected = ErCity();
  ErCity? currentReceiverCitySelected = ErCity();
  Neighborhoods? currentZone = Neighborhoods();
  Neighborhoods? currentZoneReceiver = Neighborhoods();
  VoidCallback? deleteBtnFun ;
  List<Packages>? packagesList ;
  int? index ;

  PackageCard({
    // this.packages,
    this.currentCitySelected,
    this.currentReceiverCitySelected,
    this.currentZone,
    this.newPackage = false  ,
    this.deleteBtnFun ,
    this.packagesList,
    this.index,
    this.currentZoneReceiver});

  @override
  _PackageCardState createState() => _PackageCardState();
}

class _PackageCardState extends State<PackageCard> {

 late double screenWidth  ;
 late  double screenHeight ;
 bool checkedBoxLocal = false ;
 String packaging = '';
 
 @override
  void initState() {
    try{
     checkedBoxLocal =  widget.packagesList?.elementAt(widget.index ?? 0).fragile == "1" ? true : false;
     packaging = IdToName.idToName("packaging", widget.packagesList?.elementAt(widget.index ?? 0).packaging.toString() ?? "");


    }catch(e){

    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    Size size = MediaQuery.of(context).size ;
    screenHeight = size.height ;
    screenWidth = size.width ;
    return  Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Container(
        // width: width,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(197, 197, 197, 0.1),
                //Colors.black26,
                blurRadius: 3.0, // soften the shadow
                spreadRadius: 3, //extend the shadow
              )
            ],
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.withOpacity(0.5), //deepOrange,
              width: 1,
              //borderRadius: BorderRadius.circular(radius),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  widget.packagesList?.elementAt(widget.index ?? 0).packaging == '1'
                      ? Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: SvgPicture.asset(
                      "assets/images/regular.svg",
                      height: screenHeight * 0.04,
                    ),
                  )
                      : widget.packagesList?.elementAt(widget.index ?? 0)
                      .packaging == '2'
                      ? Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    child: SvgPicture.asset(
                      "assets/images/save.svg",
                      height: screenHeight * 0.04,
                    ),
                  ):
                  widget.packagesList?.elementAt(widget.index ?? 0)
                      .packaging == '3'
                      ? Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    child: SvgPicture.asset(
                      "assets/images/liquid.svg",
                      height: screenHeight * 0.04,
                    ),
                  )
                      : widget.packagesList?.elementAt(widget.index ?? 0)
                      .packaging == '4'
                      ? Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    child: SvgPicture.asset(
                      "assets/images/cold.svg",
                      height: screenHeight * 0.04,
                    ),
                  )
                     : Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    child: SvgPicture.asset(
                      "assets/images/save.svg",
                      height: screenHeight * 0.04,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Type :'.tr(),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenWidth * 0.03),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              packaging,
                              style: TextStyle(fontSize: screenWidth * 0.03),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            checkedBoxLocal
                                ? Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Fragile'.tr(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.03),
                                ),
                              ],
                            )
                                : Container(),
                          ],
                        ),
                        widget.packagesList?.elementAt(widget.index ?? 0)
                            .cod != "0" &&
                            widget.packagesList?.elementAt(widget.index ?? 0)
                                .cod != ""
                            ? Row(
                          children: [
                            Text(
                              'cash on delivery'.tr(),
                              style: TextStyle(
                                  fontSize: screenWidth * 0.03),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              widget.packagesList?.elementAt(widget.index ?? 0)
                                  .cod ?? '',
                              style: TextStyle(
                                  fontSize: screenWidth * 0.03),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              'SR'.tr(),
                              style: TextStyle(
                                  fontSize: screenWidth * 0.02),
                            ),
                          ],
                        )
                            : Container(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'No. of pieces :'.tr(),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenWidth * 0.03),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              widget.packagesList?.elementAt(widget.index ?? 0).quantity
                                  .toString() ?? "1",
                              style: TextStyle(fontSize: screenWidth * 0.03),
                            ),
                          ],
                        ),
                        widget.packagesList?.elementAt(widget.index ?? 0).comment != null &&  widget.packagesList?.elementAt(widget.index ?? 0).comment != ""
                            ? Container(
                            width: screenWidth * 0.5,
                            child: AutoSizeText(
                              '${widget.packagesList?.elementAt(widget.index ?? 0)
                                  .comment}',
                              maxLines: 2,
                              minFontSize: 7,
                              maxFontSize: 11,
                            ))
                            : Container(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Price :'.tr(),
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenWidth * 0.03),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Row(
                              children: [
                                Text(
                                  widget.packagesList?.elementAt(widget.index ?? 0)
                                      .price
                                      .toString() ?? "",
                                  style:
                                  TextStyle(fontSize: screenWidth * 0.03),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  'SR'.tr(),
                                  style: TextStyle(fontSize: 8),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                      onTap: () async {
                        try {
                          widget.packagesList?[widget.index ?? 0] =
                          await Dialogs.CreateShipmentDialog(
                              context,
                              widget.currentCitySelected!,
                              widget.currentReceiverCitySelected!,
                              widget.currentZone!,
                              widget.currentZoneReceiver!,
                              screenWidth,
                              screenHeight,
                              widget.packagesList!.elementAt(widget.index!),
                              null);
                          packaging = IdToName.idToName("packaging", widget.packagesList?.elementAt(widget.index ?? 0).packaging.toString() ?? "");
                          checkedBoxLocal =  widget.packagesList?.elementAt(widget.index ?? 0).fragile == "1" ? true : false;

                          setState(() {});
                        } catch (e) {}
                      },
                      child: Padding(
                          padding: EdgeInsets.only(
                            top: screenWidth * 0.01,
                            right: screenWidth * 0.02,
                            bottom: screenWidth * 0.01,
                          ),
                          child: Container(
                              child: Center(
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black87,
                                    size: screenWidth * 0.05,
                                  ))))),

               widget.newPackage ?   InkWell(
                      onTap: widget.deleteBtnFun,
                      child: Padding(
                          padding: EdgeInsets.only(
                              top: screenWidth * 0.01,
                              right: screenWidth * 0.02,
                              bottom: screenWidth * 0.01,
                              left: screenWidth * 0.02),
                          child: Container(
                              child: Center(
                                  child: Icon(
                                    Icons.delete_forever_outlined,
                                    color: Color(0xFFF4693F),
                                    size: screenWidth * 0.05,
                                  ))))) : SizedBox(width: 10,),
                ],
              )
            ],
          )),
    );
  }
}
