import 'package:flutter/material.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';

import '../courier/captainDashboard.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';
import 'custom_loading.dart';
import 'package:Fulgox/ui/custom widgets/custom_button.dart';



class EmptyListView extends StatelessWidget {
  ResourcesData? resourcesData ;

  EmptyListView({this.resourcesData});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/images/empty-white-box.svg",
          color: Colors.black54,
          placeholderBuilder: (context) => CustomLoading(),
          height: 110.0,
          width: 130,
        ),
        SizedBox(height: 10,),
        Text('There are no orders'.tr(),
        style: TextStyle(
          color: Constants.capGrey,
          fontSize: 19,
        ),
        ),
        SizedBox(height: 5,),

        Text('When you reserve orders they will'.tr(),
        style: TextStyle(
          color: Constants.capGrey,
          fontSize: 19,
        ),
        ),
        Text('appear here'.tr(),
        style: TextStyle(
          color: Constants.capGrey,
          fontSize: 19,
        ),
        ),
        SizedBox(height: 50,),
        ButtonTheme(
          child: CustomButton(
            shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),
            padding: EdgeInsets.all(3),
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CaptainDashboard(
                        resourcesData:resourcesData,
                      )));
            },
            child: Container(
              width: 179,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      // colors: [Color(0xffE0DAE8), Color(0xffE6C7D0)])
                      colors: [Color(0xff6E6AAD), Color(0xffC25F74)])
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Go to orders'.tr(), style: TextStyle(color: Colors.white,fontSize: 17),),
                  SvgPicture.asset(
                    "assets/images/check-list.svg",
                    color: Colors.white,
                    placeholderBuilder: (context) => CustomLoading(),
                    height: 30.0,
                    width: 30,
                  ),


                ],

              ),
            ),
          ),
        )

      ],
    );
  }
}
