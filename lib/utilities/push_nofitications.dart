import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:xturbox/ui/custom%20widgets/notificationView.dart';

import 'Constants.dart';
class PushNotificationManager {

 static late FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;


 static setupNotificationSettings() async{
if(Platform.isIOS){
 await PushNotificationManager.firebaseMessaging.requestPermission(sound: true, badge: true, alert: true, provisional: false);

}
 await PushNotificationManager.firebaseMessaging.setForegroundNotificationPresentationOptions(sound: true, badge: true, alert: true);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
   if (message.notification != null) {
     showOverlayNotification((context) {
      return NotificationView(message: message,) ;
     }, duration: Duration(milliseconds: 3000));
   }
  });

  String? token = await PushNotificationManager.firebaseMessaging.getToken();
  print("Firebase token: $token");
  userRepository.persistNotificationToken(fcmToken: token!);

 }








}