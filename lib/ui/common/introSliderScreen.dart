import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intl/locale.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:Fulgox/ui/custom%20widgets/myAppBar.dart';
import 'package:Fulgox/ui/common/dashboard.dart';

class IntroSliderScreen extends StatefulWidget {
  @override
  _IntroSliderScreenState createState() => _IntroSliderScreenState();
}

class _IntroSliderScreenState extends State<IntroSliderScreen> {
  List<ContentConfig> slides = [];
  Function? goToTab;

  @override
  void initState() {
    super.initState();

    slides.add(
      new ContentConfig(
        title: "Safe delivery".tr(),
        styleTitle: TextStyle(
            color: Color(0xff222d66),
            fontSize: 30.0,
            fontWeight: FontWeight.w900,
            fontFamily: 'Cairo'),
        description:
        "".tr(),
        styleDescription: TextStyle(
          color: Color(0xff585858),
          fontSize: 20.0,
          fontStyle: FontStyle.italic,
        ),
        pathImage: "assets/images/introSafe.png",


      ),
    );
    slides.add(
      new ContentConfig(
        title: "From Door to Door Delivery".tr(),
        styleTitle: TextStyle(
            color: Color(0xff222d66),
            fontSize: 30.0,
            fontWeight: FontWeight.w900,
            fontFamily: 'Cairo'),
        description:
        "".tr(),
        styleDescription: TextStyle(
          color: Color(0xff585858),
          fontSize: 20.0,
          fontStyle: FontStyle.italic,
        ),
        pathImage: "assets/images/introDoorToDoor.png",

      ),
    );
    slides.add(
      new ContentConfig(
        title: "Fast Delivery".tr(),
        styleTitle: TextStyle(
            color: Color(0xff222d66),
            fontSize: 30.0,
            fontWeight: FontWeight.w900,
            fontFamily: 'Cairo'),
        description:
        "".tr(),
        styleDescription: TextStyle(
          color: Color(0xff585858),
          fontSize: 20.0,
          fontStyle: FontStyle.italic,
        ),
        pathImage: "assets/images/introFastDelivery.png",

      ),
    );
  }


  void onDonePress() {
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (BuildContext context) => ResourcesScreen()),
          (route) => false,);
  }

  void onTabChangeCompleted(index) {
    // Index of current tab is focused
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: Color(0xff222d66),
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return Text("Done".tr(),
      style: TextStyle(
          color: Color(0xff222d66)
      ),
    );
    return Icon(
      Icons.done,
      color: Color(0xFF4C8FF8),
    );

  }

  Widget renderSkipBtn() {
    return Text("Skip".tr(),
      style: TextStyle(
        color: Color(0xff585858),
      ),
    );
    // return Icon(
    //   Icons.skip_next,
    //   color: Color(0xFF4C8FF8),
    // );
  }

  List<Widget> renderListCustomTabs() {
    List<Widget> tabs = [];
    for (int i = 0; i < slides.length; i++) {
      ContentConfig currentSlide = slides[i];
      tabs.add(Container(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          margin: EdgeInsets.only(bottom: 60.0, top: 60.0),
          child: ListView(
            children: <Widget>[
              SizedBox(height: 40,),

              Container(
                child: Text(
                  currentSlide.title!,
                  style: currentSlide.styleTitle,
                  textAlign: TextAlign.center,
                ),
                margin: EdgeInsets.only(top: 20.0 ),
              ),
              Container(
                child: Text(
                  currentSlide.description!,
                  style: currentSlide.styleDescription,
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
                margin: EdgeInsets.only(top: 20.0 , left: 30 , right: 30),
              ),
              SizedBox(height: 50,),
              Container(
                  child: Image.asset(
                    currentSlide.pathImage!,
                    width: 300.0,
                    height: 300.0,
                    fit: BoxFit.contain,
                  )
              ),
            ],
          ),
        ),
      ));
    }
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntroSlider(
        // List slides
        listContentConfig: this.slides,
        // Skip button
        renderSkipBtn: this.renderSkipBtn(),
        // colorSkipBtn: Color(0xfff2f7ff),
        // highlightColorSkipBtn: Color(0xFF4C8FF8),

        // Next button
        renderNextBtn: this.renderNextBtn(),

        // Done button
        renderDoneBtn: this.renderDoneBtn(),
        onDonePress: this.onDonePress,
        // colorDoneBtn: Color(0xfff2f7ff),
        // highlightColorDoneBtn: Color(0xFF4C8FF8),
   
        // typeDotAnimation: dotSliderAnimation.SIZE_TRANSITION,

        // Tabs
        listCustomTabs: this.renderListCustomTabs(),
        refFuncGoToTab: (refFunc) {
          this.goToTab = refFunc;
        },

        // Show or hide status bar


        // On tab change completed
        onTabChangeCompleted: this.onTabChangeCompleted,
      ),
    );
  }
}