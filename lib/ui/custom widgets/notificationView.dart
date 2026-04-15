import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:Fulgox/data_providers/models/notificationDataModel.dart';
import 'package:Fulgox/ui/custom%20widgets/notification_widget.dart';

class NotificationView extends StatefulWidget {
  RemoteMessage? message ;
  NotificationView({this.message});
  @override
  _NotificationViewState createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  String? msg ;
  String? title ;
  String? image ;
  NotificationDataModel notificationDataModel =  NotificationDataModel ();

  getMessage(){


    msg = widget.message!.notification!.body;
    title = widget.message!.notification!.title;


    // var decodedData = jsonDecode(widget.message);
    // notificationDataModel = NotificationDataModel.fromJson(decodedData);

      // msg = notificationDataModel.notification.body ;
      // title = notificationDataModel.notification.title;

  }
  @override
  void initState() {

    getMessage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: (){
        showDialog(
            context: context,
            builder: (context){
              return NotificationWidget(widget.message?.notification?.title ?? "" , widget.message?.notification?.body ?? "",
                  widget.message?.notification?.android?.imageUrl , widget.message?.notification?.apple?.imageUrl

              );
            }
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: SafeArea(
          child: ListTile(
            leading: SizedBox.fromSize(
                size: const Size(40, 40),
                child:EasyLocalization.of(context)!.locale == Locale('en') ?
                Image.asset('assets/images/appstore.png',
                  colorBlendMode: BlendMode.darken,
                  // fit: BoxFit.fitWidth,
                ):
                Image.asset('assets/images/logo-ar.png',
                  colorBlendMode: BlendMode.darken,
                  // fit: BoxFit.fitWidth,
                ),
            ),
            title: Text(title ?? ""),
            subtitle: Text(msg ??''),
            trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  OverlaySupportEntry.of(context)!.dismiss();
                }),
          ),
        ),
      ),
    );
  }
}
