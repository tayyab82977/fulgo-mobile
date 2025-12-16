import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
class CaptainAppBar extends StatefulWidget {
  GlobalKey<ScaffoldState> drawerKey ;
  String screenName;
  CaptainAppBar({required this.drawerKey, required this.screenName});


  @override
  _CaptainAppBarState createState() => _CaptainAppBarState();
}

class _CaptainAppBarState extends State<CaptainAppBar> {
  Color blueColor = Color(0xFF2f3a92);
  Color greyColor = Color(0xFFf4f4f4);
  Color redColor = Color(0xFFBE2C33);
  @override
  Widget build(BuildContext context) {
    var mySize = MediaQuery.of(context).size;
    return Container(
      height: 80,
      padding: EdgeInsets.only(top: mySize.height / 100 * 2, bottom: mySize.height / 100 * 1, right: mySize.width / 100 * 7, left: mySize.width / 100 * 7),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(38), ),
          color: blueColor,
          // color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(120, 135, 198, .3).withOpacity(0.6),
              // color: Color(0xFFbebebe),
              blurRadius: 5,
              offset: Offset(0, 5),
            )
          ]
    ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              IconButton(onPressed: (){
                widget.drawerKey.currentState!.openDrawer();
              }, icon: Icon(Icons.menu), color: Colors.white, iconSize: 30,),
              Expanded(
                child: Row(
                  children: [

                   //AutoSizeText(SavedData.profileDataModel.name  ?? "",
                   // Text(SavedData.profileDataModel.name  ?? "",
                    Expanded(
                      child: AutoSizeText( widget.screenName,
                        maxLines: 1,
                        maxFontSize: 22,
                        minFontSize: 15,
                        textAlign: TextAlign.center,
                        // textAlign: EasyLocalization.of(context)?.currentLocale == Locale("en") ? TextAlign.right : TextAlign.left,
                        style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),),
                    ),
                    SizedBox(width: mySize.width / 100 * 3),
                    Container(
                      // padding: EdgeInsets.all(5),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.all(Radius.circular(15)),
                      //
                      // ),

                      // height: mySize.height / 100 * 4,
                      child: Image.asset('assets/images/xturbo_white_icon.png', height: mySize.height / 100 * 3,)
                      // child: ClipRRect(
                      //   borderRadius: BorderRadius.all(Radius.circular(20)),//add border radius here
                      //   child: Icon(
                      //     MdiIcons.accountCircle, color: Colors.white, size: 50,
                      //
                      //   )
                        // child: Image.network('https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png'),//add image location here
                      ),

                  ],


                ),
              ),

            ],
          )
        ],
      ),
    );
  }
}
