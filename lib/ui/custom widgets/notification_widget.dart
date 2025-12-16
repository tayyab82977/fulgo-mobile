import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationWidget extends StatefulWidget {
  final String title;
  final String body;
  String? imageAndroid;
  String? imageIOS;

  NotificationWidget(this.title, this.body , this.imageAndroid , this.imageIOS);

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      margin: EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
            borderRadius: BorderRadius.circular(25),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Platform.isIOS && widget.imageIOS != null   ?
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                  imageUrl: widget.imageIOS ?? "https://i.ibb.co/Y7sq81j/logo-ar.png",
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ) : SizedBox() ,
                  Platform.isAndroid && widget.imageAndroid != null ?
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                     imageUrl: widget.imageAndroid ?? "https://i.ibb.co/Y7sq81j/logo-ar.png",
                     progressIndicatorBuilder: (context, url, downloadProgress) =>
                         CircularProgressIndicator(value: downloadProgress.progress),
                     errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ) : SizedBox(),
                  SizedBox(height: 10,),
                  Text("${widget.title}" , style: TextStyle(color:Colors.black , fontSize: 22, fontWeight: FontWeight.w700),),
                  SizedBox(height: 20,),

                  Text("${widget.body}" , style: TextStyle(color: Colors.black , fontSize: 18 , fontWeight: FontWeight.w400),),

                  SizedBox(height: 50,),

                  GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color:  Colors.white , width: 2),
                        ),
                        padding: EdgeInsets.all(20),
                        alignment: Alignment.center,
                        child: Text("ok".tr() , style: TextStyle(color: Colors.blue , fontSize: 16, fontWeight: FontWeight.w700, decoration: TextDecoration.underline),),
                      ),
                      onTap: ()  => Navigator.of(context).pop()
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
