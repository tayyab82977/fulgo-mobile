import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/ui/courier/odo_meter.dart';
import 'package:Fulgox/ui/custom%20widgets/custom_loading.dart';
import 'package:Fulgox/utilities/location.dart';

class ComFunctions {
  static launchURL(String url) async {
    print('launcher activated');
    if (await canLaunch(url)) {
      print('launcher success');

      await launch(url);
    } else {
      print('launcher failed');

      throw 'Could not launch $url';
    }
  }

  static launcWhatsappWithMsg(String? phone) async {
    // var whatsappUrl ="whatsapp://send?phone=+966$phone";
    // var whatsappUrl ="https://api.whatsapp.com/send?phone=+9660535635936?text=Hello";

    String s2 = """
    السلام عليكم ورحمة الله وبركاته
    *معك مندوب شركة Fulgo للتوصيل والشحن 🚚
    في شحنة مسجلة باسمكم 📦
    الرجاء ارسال الموقع! 📍
    و تحديد طريقة الدفع :
    1- كاش 💵
    2- شبكة💳
    شركة Fulgo ترحب بكم وتعلن عن انطلاقتها في المملكة العربية السعودية العزيزة. نتشرف بخدمتكم ورضاكم هو غايتنا
    الرجاء تحميل التطبيق من اللينك: https://Fulgox.page.link/test
    نتشرف بزيارتكم في موقعنا على الانترنت:  https://Fulgox.com/
    حنا يمك - Fulgox
  """;

    var whatsappUrl =
        "https://wa.me/+966${phone}?text=${SavedData.resourcesData.whatsappMsg}";

    await canLaunch(whatsappUrl)
        ? launch(whatsappUrl)
        : Fluttertoast.showToast(
            msg: "there is no whatsapp installed".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            fontSize: 16.0);

    // var _url = "https://api.whatsapp.com/send?phone=91";
    // void _launchURL(txt) async => await canLaunch(_url + txt)
    //     ? await launch(_url + txt)
    //     : throw 'Could not launch $_url';

    print(
        "open whatsapp app link or do a snackbar with notification that there is no whatsapp installed");
  }

  static launcWhatsapp(String? phone) async {
    var whatsappUrl = "whatsapp://send?phone=+966$phone";
    await canLaunch(whatsappUrl)
        ? launch(whatsappUrl)
        : Fluttertoast.showToast(
            msg: "there is no whatsapp installed".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            textColor: Colors.red,
            backgroundColor: Colors.white,
            fontSize: 16.0);

    print(
        "open whatsapp app link or do a snackbar with notification that there is no whatsapp installed");
  }

  static launcPhone(String? phone) async {
    print('launcher activated');
    // bool res = await FlutterPhoneDirectCaller.callNumber(phone ?? "") ?? false;

    launch("tel://0$phone");
  }

  static launcPhone2(String phone) async {
    print('launcher activated');
    launch("tel://$phone");
  }

  static MsgDialog(BuildContext context, String? text) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text("Rejected".tr()),
            content: Column(
              children: [
                Text(text ?? ""),
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("ok".tr()))
            ],
          );
        });
  }

  static showList({required BuildContext context, List<String>? list}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Wrap(
        runAlignment: WrapAlignment.start,
        direction: Axis.vertical,
        children: (list ?? [])
            .map((e) => Text(e, style: TextStyle(color: Colors.white)))
            .toList(),
      ),
      backgroundColor: Colors.red,
    ));
  }

  static showMeterDialog(BuildContext context) async {
    await Future.delayed(Duration(milliseconds: 200));
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ODOMeterScreen(
            resourcesData: SavedData.resourcesData,
          );
        });
  }

  static noLocationPermissionDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "Make sure the location is opened and the permission has granted for the Xtrubo"
                    .tr()),
            // content:Column(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     Text(text ?? ""),
            //   ],
            // ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    bool check =
                        await LocationServices.checkLocationPermission();
                    if (check) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("ok".tr()))
            ],
          );
        });
  }

  static ProgressDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Loading...'.tr()),
                Container(width: 20, height: 20, child: CustomLoading()),
              ],
            ),
          );
        });
  }

  static showToast({Color? color, required String text}) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.red,
        backgroundColor: Colors.white,
        fontSize: 16.0);
  }

  static launchStore() async {
    final InAppReview inAppReview = InAppReview.instance;
    await inAppReview.openStoreListing(appStoreId: '1544086125');

    // Old implementation:
    // LaunchReview.launch(androidAppId:"com.bytes.fulgo" , iOSAppId:"1544086125" , writeReview: false );
    // OpenAppstore.launch(androidAppId: "com.bytes.fulgo", iOSAppId: "1544086125");
  }

  static showToastEditable(
      {Color? color,
      required String text,
      ToastGravity? toastGravity,
      Toast? length}) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: length,
        gravity: toastGravity,
        timeInSecForIosWeb: 1,
        textColor: Colors.red,
        backgroundColor: Colors.white,
        fontSize: 16.0);
  }

  static bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static DateTime convertIntToDate(int? timestamp) {
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
    return date;
  }
}
