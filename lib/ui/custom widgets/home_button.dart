import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/ui/Client/HomeScreenNew.dart';
import 'package:xturbox/ui/Client/MyOrders.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Client/more_screen.dart';



class HomeButton extends StatefulWidget {
  bool isHome = false ;
  bool isMore = false ;
  bool isMyShipments = false ;

  HomeButton({this.isHome = false  , this.isMore = false , this.isMyShipments = false});
  @override
  _HomeButtonState createState() => _HomeButtonState();
}

class _HomeButtonState extends State<HomeButton> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.8 ;
    return Hero(
      tag: "homeButton",
      child: Material(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: width,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,

                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (){
                    if(!widget.isMyShipments){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyOrdersScreen(
                                dashboardDataModel: SavedData.profileDataModel,
                                resourcesData: SavedData.resourcesData,
                              )));
                    }
                   },
                  child: Container(
                    height: 50,
                    width:width*0.3 ,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/images/my-orders.svg",width: 20),
                        SizedBox(height: 3,),
                        Text("My Shipments".tr() , style: TextStyle(color: Colors.black , fontSize: 9 , fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: InkWell(
                    onTap: (){
                      if(!widget.isHome){
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => NewHomeScreen(),
                          ),
                              (route) => false,
                        );
                      }
                     },
                    radius: 1,
                    child: Container(
                      padding: EdgeInsets.zero,
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white,width: 2),
                          shape: BoxShape.circle,
                          color: Constants.blueColor
                      ),
                      child: Icon(Icons.home_outlined , color: Colors.white, size: 40,),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    if(!widget.isMore){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MoreScreen(
                                resourcesData: SavedData.resourcesData,
                              )));
                    }
                   },
                  child: Container(
                    width:width*0.3,
                    height: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SvgPicture.asset("assets/images/my-orders.svg",width: 20,),
                        Icon(Icons.more_horiz_outlined , color: Colors.black, size: 20,),
                        // SizedBox(height: 3,),
                        Text("more".tr() , style: TextStyle(color: Colors.black , fontSize: 9 , fontWeight: FontWeight.bold),),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}