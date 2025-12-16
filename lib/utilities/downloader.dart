import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/utilities/Constants.dart';

class Downloader {

 static UserRepository userRepository = UserRepository();

 static String _localPath = '';

static ReceivePort _port = ReceivePort();



 static Future<String> _findLocalPath() async {
    Directory? directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }
 static downloadPDFAndroid(String? taskId , OrdersDataModelMix? ordersDataModelMix) async {
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    String path = '';
    final status = await Permission.storage.request();
    String? token = await userRepository.getAuthToken();
    if(status.isGranted){
      taskId = await FlutterDownloader.enqueue(
        url: '${EventsAPIs.url}files/${ordersDataModelMix!.id}/shipment',
        headers: {
          HttpHeaders.authorizationHeader:token!,
          "compatibility":EventsAPIs.compatibility,
        },
        savedDir: _localPath,
        fileName:'${ordersDataModelMix.id}.pdf',
        showNotification: true, // show download progress in status bar (for Android)
        openFileFromNotification: true, // click on notification to open downloaded file (for Android)
      );
    }else {

      taskId = await FlutterDownloader.enqueue(
        url: '${EventsAPIs.url}files/${ordersDataModelMix!.id}/shipment',
        headers: {
          HttpHeaders.authorizationHeader:token!,
          "compatibility":EventsAPIs.compatibility,
        },
        savedDir: _localPath,
        fileName:'${ordersDataModelMix.id}.pdf',
        showNotification: true, // show download progress in status bar (for Android)
        openFileFromNotification: true, // click on notification to open downloaded file (for Android)
      );
    }
  }
 static downloadPDFAndroid2(String? taskId , String url , String fileName) async {
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    String path = '';
    final status = await Permission.storage.request();
    String? token = await userRepository.getAuthToken();
    if(status.isGranted){
      taskId = await FlutterDownloader.enqueue(
        url: url,
        headers: {
          HttpHeaders.authorizationHeader:token!,
          "compatibility":EventsAPIs.compatibility,
        },
        savedDir: _localPath,
        fileName:'$fileName.pdf',
        showNotification: true, // show download progress in status bar (for Android)
        openFileFromNotification: true, // click on notification to open downloaded file (for Android)
      );
    }else {

      taskId = await FlutterDownloader.enqueue(
        url: url,
        headers: {
          HttpHeaders.authorizationHeader:token!,
          "compatibility":EventsAPIs.compatibility,
        },
        savedDir: _localPath,
        fileName:'$fileName.pdf',
        showNotification: true, // show download progress in status bar (for Android)
        openFileFromNotification: true, // click on notification to open downloaded file (for Android)
      );
    }
  }

 static downloadPDFIOS(String? taskId , OrdersDataModelMix? ordersDataModelMix) async {
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    String path = '';
    String? token = await userRepository.getAuthToken();
    taskId = await FlutterDownloader.enqueue(
      url: '${EventsAPIs.url}files/${ordersDataModelMix!.id}/shipment',
      headers: {
        HttpHeaders.authorizationHeader:token!,
        "compatibility":EventsAPIs.compatibility,
       "ACCEPT-LANGUAGE":Constants.currentLocale

    },
      savedDir: _localPath,
      fileName:'${ordersDataModelMix.id}.pdf',
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );

  }
 static downloadPDFIOS2(String? taskId , String url , String fileName) async {
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    print(url);

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    String path = '';
    String? token = await userRepository.getAuthToken();
    taskId = await FlutterDownloader.enqueue(
      url: url,
      headers: {
        HttpHeaders.authorizationHeader:token!,
        "compatibility":EventsAPIs.compatibility,
       "ACCEPT-LANGUAGE":Constants.currentLocale

    },
      savedDir: _localPath,
      fileName:'$fileName.pdf',
      showNotification: true, // show download progress in status bar (for Android)
      openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    );

  }

 static void downloadCallback( id,  status,  progress) {
   final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
   send.send([id, status, progress]);
 }


static void unbindBackgroundIsolate() {
   IsolateNameServer.removePortNameMapping('downloader_send_port');
 }
static void bindBackgroundIsolate(OrdersDataModelMix? ordersDataModelMix , BuildContext context) {
   bool isSuccess = IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
   if (!isSuccess) {
     unbindBackgroundIsolate();
     bindBackgroundIsolate(ordersDataModelMix  , context);
     return;
   }
   _port.listen((dynamic data) {
     print('_port.listen');
     String? id = data[0];
     DownloadTaskStatus? status = data[1];
     int? progress = data[2];
     print('real id $id ');

       ordersDataModelMix!.taskId = id ;
      ordersDataModelMix.statusDownload = status ;
       ordersDataModelMix.progress = progress ;
     });

     if(ordersDataModelMix!.statusDownload == DownloadTaskStatus.complete){
       Future.delayed(Duration(seconds: 1), () {
         FlutterDownloader.open(taskId: ordersDataModelMix.taskId!);
       });
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('File Downloaded'.tr()),
           backgroundColor: Colors.green,
         ),
       );


     }



 }




}