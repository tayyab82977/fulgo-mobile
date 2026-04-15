import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/ResponseViewModel.dart';
import 'package:Fulgox/data_providers/models/callLogModel.dart';
import 'package:Fulgox/data_providers/models/captainOrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/clientPaymentsDataModel.dart';
import 'package:Fulgox/data_providers/models/fuel.dart';
import 'package:Fulgox/data_providers/models/geoCodingDataModel.dart';
import 'package:Fulgox/data_providers/models/memberBalanceModel.dart';
import 'package:Fulgox/data_providers/models/newForCaptainOrders.dart';
import 'package:Fulgox/data_providers/models/pickUpDataModel.dart';
import 'package:Fulgox/data_providers/models/pickupReportModel.dart';
import 'package:Fulgox/data_providers/models/postOrderData.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/data_providers/models/trackingDataModel.dart';
import 'package:Fulgox/data_providers/models/tripModel.dart';
import 'package:Fulgox/data_providers/models/violation.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Fulgox/utilities/URLs.dart';
import 'package:Fulgox/utilities/comFunctions.dart';
import 'package:Fulgox/utilities/endPoints.dart';

class EventsApiCaptain {

  static Future<MyResponseModel<bool>> checkIn({String? token, String? signature}) async {
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    Map data = {
      "signature": signature,
    };
    var body = json.encode(data);
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response responseViewModel =
        await http.post(Uri.parse(EventsAPIs.url + EndPoints.myAttendance),
            headers: {
              "Content-Type": "application/json",
              "compatibility": EventsAPIs.compatibility,
              HttpHeaders.authorizationHeader: '$token',
              "appVersion": Constants.appVersion,
              "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale
            },
            body: body);
    myResponseModel.statusCode = responseViewModel.statusCode;
    print(responseViewModel.request!.url);
    print('check in call call ${responseViewModel.statusCode}');
    print('check in call ${responseViewModel.body}');
    if (responseViewModel.statusCode == 201 || responseViewModel.statusCode == 200 ) {
      myResponseModel.statusCode = responseViewModel.statusCode;

      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      myResponseModel.statusCode = responseViewModel.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }

  static Future<MyResponseModel<CapOrdersDataModel>> getCaptainOrders({String? token}) async {
    print('Hello from get orders call');
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.myOrders),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": EventsAPIs.compatibility,
        "fbId": fcm.toString(),
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "appVersion": Constants.appVersion
      },
    );
    print(response.request!.url);
    print('Captain orders call ${response.statusCode}');
    print('Captain orders call ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<CapOrdersDataModel>();
    CapOrdersDataModel capOrdersDataModel = CapOrdersDataModel();

    if (response.statusCode == 200) {
      try {
        var decodedData = json.decode(response.body);
         capOrdersDataModel =
            CapOrdersDataModel.fromJson(decodedData);

        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = capOrdersDataModel;
        myResponseModel.errorsList = List<String>.empty(growable: false);

        return myResponseModel as FutureOr<MyResponseModel<CapOrdersDataModel>>;
      } catch (e) {
        print(e);
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = capOrdersDataModel;
        myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(null);

      }
    } else if (response.statusCode == 204) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      myResponseModel.responseData = capOrdersDataModel;
    } else {
      var errorListBad;
      var errorList;

      try {
        var decodedData = jsonDecode(response.body);
        errorListBad = decodedData['error'];
        errorList = errorListBad.cast<String>();
      } catch (e) {
        errorList = List<String>.empty(growable: false);
      }
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = null;
      myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(null);

    }
    return myResponseModel as FutureOr<MyResponseModel<CapOrdersDataModel>>;

  }

  static Future<MyResponseModel<bool>> reserveClient({String? token, String? id}) async {
    UserRepository userRepository = UserRepository();
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    Response response = await http.patch(
      Uri.parse(EventsAPIs.url + EndPoints.myOrders + "/$id/reserveMember"),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": EventsAPIs.compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "appVersion": Constants.appVersion,
        "fbId": fcm.toString()
      },
    );
    print(response.request!.url);
    print('reserve order call ${response.statusCode}');
    print('reserve order call ${response.body}');
    myResponseModel.statusCode = response.statusCode;
    if (response.statusCode == 200 || response.statusCode == 204) {
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      myResponseModel.responseData = false;
      var decodedData = jsonDecode(response.body);
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }

  static Future<MyResponseModel< List<OrdersDataModelMix>>> getCaptainReserves({String? token}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http
        .get(Uri.parse(EventsAPIs.url + EndPoints.myReserved), headers: {
      "Content-Type": "application/json",
      HttpHeaders.authorizationHeader: '$token',
      "compatibility": EventsAPIs.compatibility,
      "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
      "fbId": fcm.toString(),
      "appVersion": Constants.appVersion
    });
    print(response.request!.url);
    print('get captain reserve ${response.statusCode}');
    print('get captain reserve ${response.body}');

    MyResponseModel myResponseModel =
        MyResponseModel< List<OrdersDataModelMix>>();
    if (response.statusCode == 200) {
      try {
        var decodedData = jsonDecode(response.body);
        final list = decodedData.map((data) => OrdersDataModelMix.fromJson(data)).toList();
        var myPickedList = list.cast<OrdersDataModelMix>();
        // List<List<OrdersDataModelMix>> welcomeFromJson(String str) =>
        //     List<List<OrdersDataModelMix>>.from(json.decode(str).map((x) =>
        //         List<OrdersDataModelMix>.from(
        //             x.map((x) => OrdersDataModelMix.fromJson(x)))));
        // final welcome = welcomeFromJson(response.body);

        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = myPickedList;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        print(e);
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = List<OrdersDataModelMix>.empty(growable: false);
        myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(null);
      }
    } else if (response.statusCode == 204) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = List<OrdersDataModelMix>.empty(growable: false);
      myResponseModel.errorsList = List<String>.empty(growable: false);
    } else {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = List<OrdersDataModelMix>.empty(growable: false);
      myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(null);


    }
    return myResponseModel as FutureOr<MyResponseModel< List<OrdersDataModelMix>>>;

  }

  static Future<MyResponseModel<bool>> captainCancelClient({String? token, String? id}) async {
    UserRepository userRepository = UserRepository();
    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.patch(
        Uri.parse(
            EventsAPIs.url + EndPoints.myReserved + "/$id/reserveMemberCancel"),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: '$token',
          "compatibility": EventsAPIs.compatibility,
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        });
    print(response.request!.url);
    print('captain cancel clien ${response.statusCode}');
    print('captain cancel clien ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    if (response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      var decodedData = jsonDecode(response.body);
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }
  static Future<MyResponseModel<PickupReportModel>> captainPickup({String? token, String? memberId, String? amount, String? receipt, String? paymentMethodId, String? msgCode, required List<OrdersDataModelMix> pickupList, List<Credit>? creditList}) async {
    List encondeToJson(List<OrdersDataModelMix> list) {
      List jsonList = [];
      list.map((item) => jsonList.add(item.toJson())).toList();
      return jsonList;
    }
   print(msgCode);
    Map data = {
      "payment": {

        // "credits":encondeToJson2(creditList)
      },
      "amount": amount,
      "receipt": receipt,
      "methodId":paymentMethodId,
      "shipments": encondeToJson(pickupList),
      "code":msgCode
    };

    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    var body = json.encode(data);

    http.Response response = await http.patch(
        Uri.parse(EventsAPIs.url + EndPoints.myReserved + "/$memberId/pickup"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
        body: body);

    print(response.request!.url);
    print('pickup response ${response.statusCode}');
    print('pickup response ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<PickupReportModel>();
    PickupReportModel pickupReportModel = PickupReportModel();

    if (response.statusCode == 201 ||
        response.statusCode == 200) {

      try {
        var decodedData = jsonDecode(response.body);
        pickupReportModel = PickupReportModel.fromJson(decodedData);
      } catch (e) {

      }

      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = pickupReportModel;
      myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(null);
    } else {
      var errorListBad;
      var errorList;
      try {
        var decodedData = jsonDecode(response.body);

        errorListBad = decodedData['error'];
        errorList = ['$errorListBad'];
      } catch (e) {
        errorList = ['Something went wrong please try again'.tr()];
      }
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = pickupReportModel;
      myResponseModel.errorsList = errorList;
    }
    return myResponseModel as FutureOr<MyResponseModel<PickupReportModel>>;

  }
  static Future<MyResponseModel<List<String>>> returnShipmentsToClient({String? token, String? memberId, String? amount, String? receipt, required List<OrdersDataModelMix> pickupList, required String methodId , required String code}) async {
    List encondeToJson(List<OrdersDataModelMix> list) {
      List jsonList = [];
      list.map((item) => jsonList.add(item.toJson())).toList();
      return jsonList;
    }
    Map data = {
      "shipments": encondeToJson(pickupList),
      "receipt": receipt,
      "methodId":methodId,
      "code":code,
      "amount":amount
    };

    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    var body = json.encode(data);

    http.Response response = await http.post(
        Uri.parse(EventsAPIs.url + EndPoints.returnToClient + "/returnFees"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
        body: body);

    print(response.request!.url);
    print('return to client response ${response.statusCode}');
    print('return to client response ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<List<String>>();
    if (response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 200) {
      String successNo;
      String failNo;
      try {
        var decodedData = jsonDecode(response.body);
        successNo = decodedData["success"].toString();
        failNo = decodedData["fail"].toString();
      } catch (e) {
        successNo = '';
        failNo = '';
      }

      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = [successNo, failNo];
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<List<String>>>;
    } else {
      var errorListBad;
      var errorList;
      try {
        var decodedData = jsonDecode(response.body);

        errorListBad = decodedData['error'];
        errorList = ['$errorListBad'];
      } catch (e) {
        errorList = ['Something went wrong please try again'.tr()];
      }
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = List<String>.empty(growable: false);
      myResponseModel.errorsList = errorList;
      return myResponseModel as FutureOr<MyResponseModel<List<String>>>;
    }
  }
  static Future<MyResponseModel<PickUpDataModel>> getMyPickups({String? token}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http
        .get(Uri.parse(EventsAPIs.url + EndPoints.myPickup), headers: {
      "Content-Type": "application/json",
      "compatibility": EventsAPIs.compatibility,
      HttpHeaders.authorizationHeader: '$token',
      "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
      "fbId": fcm.toString(),
      "appVersion": Constants.appVersion
    });

    print(response.request!.url);
    print('print pickup call ${response.statusCode}');
    print('print pickup call ${response.body}');
    // CapOrdersDataModel capOrdersDataModel = CapOrdersDataModel.fromJson(decodedData);

    MyResponseModel myResponseModel = MyResponseModel<PickUpDataModel>();

    if (response.statusCode == 200) {
      PickUpDataModel pickUpDataModel = PickUpDataModel();
      try {
        var decodedData = jsonDecode(response.body);
        pickUpDataModel = PickUpDataModel.fromJson(decodedData);
        print(e);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = pickUpDataModel;
        myResponseModel.errorsList = ['Error'];
        return myResponseModel as FutureOr<MyResponseModel<PickUpDataModel>>;
      }

      // final list = decodedData.map((data) => OrdersDataModelMix.fromJson(data)).toList();
      // var myPicedList = list.cast<OrdersDataModelMix>();

      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = pickUpDataModel;
      myResponseModel.errorsList = List<String>.empty(growable: false);
    } else {
      PickUpDataModel pickUpDataModel = PickUpDataModel();

      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = pickUpDataModel;
      myResponseModel.errorsList = List<String>.empty(growable: false);
    }
    return myResponseModel as FutureOr<MyResponseModel<PickUpDataModel>>;
  }
  static Future<MyResponseModel<bool>> captainDeliverShipment({String? token, String? id, String? amount, String? receipt , String? paymentMethodId,String? code}) async {
    Map data = {
      "amount": amount,
      "receipt": receipt,
      "methodId":paymentMethodId,
      "code":code
    };

    var body = json.encode(data);

    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.patch(
        Uri.parse(EventsAPIs.url + EndPoints.myPickup + "/$id/deliver"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
        body: body);
    print(response.request!.url);

    print('captain deliver shipment ${response.statusCode}');
    print('captain deliver shipment ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    if (response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }
  static Future<MyResponseModel<bool>> captainCancelShipment({String? token, String? id, String? cancelId,  List<CallLogModel>? logHistory}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    List encondeToJson(List<CallLogModel>? list) {
      List jsonList = [];
      list?.map((item) => jsonList.add(item.toJson())).toList();
      return jsonList;
    }

    Map data = {
      "cancel": cancelId,
      'callLog': encondeToJson(logHistory)
    };

    var body = json.encode(data);

    http.Response response = await http.patch(
        Uri.parse(EventsAPIs.url + EndPoints.myPickup + "/$id/cancel"),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: '$token',
          "compatibility": EventsAPIs.compatibility,
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
        body: body);
    print(response.request!.url);
    print('captain cancel shipment ${response.statusCode}');
    print('captain cancel shipment ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    if (response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }
  static Future<MyResponseModel<bool>> captainRejectShipment({String? token, String? id, String? reason}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    Map data = {
      "reject": reason,
    };

    var body = json.encode(data);

    http.Response response = await http.patch(
        Uri.parse(EventsAPIs.url + EndPoints.myPickup + "/$id/reject"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
        body: body);
    print(response.request!.url);

    print('captain reject shipment ${response.statusCode}');
    print('captain reject shipment ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    if (response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }
  static Future<MyResponseModel<bool>> captainRescheduleShipment({String? token, String? id, String? reason}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();
    Map data = {
      "reschedule": reason,
    };

    var body = json.encode(data);
    http.Response response = await http.patch(
        Uri.parse(EventsAPIs.url + EndPoints.myPickup + "/$id/reschedule"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
        body: body);
    print(response.request!.url);
    print('captain reschedule shipment ${response.statusCode}');
    print('captain reschedule shipment ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    if (response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }
  static Future<MyResponseModel<bool>> captainLostShipment({String? token, String? id}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.patch(
        Uri.parse(EventsAPIs.url + EndPoints.myPickup + "/$id/lost"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        });
    print(response.request!.url);
    print('captain lost shipment ${response.statusCode}');
    print('captain lost shipment ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    if (response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      var decodedData = jsonDecode(response.body);
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }
  static Future<MyResponseModel<bool>> captainDamagedShipment({String? token, String? id}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.patch(
        Uri.parse(EventsAPIs.url + EndPoints.myPickup + "/$id/damaged"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        });
    print(response.request!.url);
    print('captain damaged shipment ${response.statusCode}');
    print('captain damaged shipment ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    if (response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      var decodedData = jsonDecode(response.body);
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }
  static Future<MyResponseModel<OrdersDataModelMix>> getShipmentByIdBulkPickup({String? id, String? token}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + "getShipment/" + id! + "/bulkPickup"),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: token!,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "appVersion": Constants.appVersion
      },
    );
    print(response.request!.url);
    print('get shipment by id ${response.statusCode}');
    print('get shipment by id ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<OrdersDataModelMix>();
    OrdersDataModelMix ordersDataModelMix = OrdersDataModelMix();

    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body);
      try {
        ordersDataModelMix = OrdersDataModelMix.fromJson(decodedData);
        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = ordersDataModelMix;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = ordersDataModelMix;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      }
    } else if (response.statusCode == 204) {
      myResponseModel.statusCode = 400;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      myResponseModel.responseData = ordersDataModelMix;
    } else {
      if (response.statusCode != 500 &&
          response.statusCode != 404 &&
          response.statusCode != 204) {
        var decodedData;
        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = ordersDataModelMix;
        myResponseModel.errorsList =
            GeneralHandler.handleErrorsFromApi(decodedData);
      } else {
        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = ordersDataModelMix;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      }
    }
    return myResponseModel as FutureOr<MyResponseModel<OrdersDataModelMix>>;
  }
  static Future<MyResponseModel<OrdersDataModelMix>> getShipmentByIdReturnToClient({String? id, String? token}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + "getShipment/" + id! + "/returnToClient"),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: token!,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "appVersion": Constants.appVersion
      },
    );
    print(response.request!.url);
    print('get shipment by id ${response.statusCode}');
    print('get shipment by id ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<OrdersDataModelMix>();
    OrdersDataModelMix ordersDataModelMix = OrdersDataModelMix();

    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body);
      try {
        ordersDataModelMix = OrdersDataModelMix.fromJson(decodedData);
        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = ordersDataModelMix;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = ordersDataModelMix;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      }
    } else if (response.statusCode == 204) {
      myResponseModel.statusCode = 400;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      myResponseModel.responseData = ordersDataModelMix;
    } else {
      if (response.statusCode != 500 &&
          response.statusCode != 404 &&
          response.statusCode != 204) {
        var decodedData;

        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = ordersDataModelMix;
        myResponseModel.errorsList =
            GeneralHandler.handleErrorsFromApi(decodedData);
      } else {
        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = ordersDataModelMix;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      }
    }
    return myResponseModel as FutureOr<MyResponseModel<OrdersDataModelMix>>;
  }
  static Future<MyResponseModel<bool>> bulktoreOutShipment({String? token, required List<OrdersDataModelMix> list }) async {
    UserRepository userRepository = UserRepository();

    List encondeToJson(List<OrdersDataModelMix> list) {
      List jsonList = [];
      list.map((item) => jsonList.add(item.toJson())).toList();
      return jsonList;
    }
    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    Map data = {
      "shipments": encondeToJson(list),
    };
    var body = json.encode(data);

    http.Response response = await http.patch(
        Uri.parse(EventsAPIs.url + EndPoints.myOrders + "/0/bulksSoreOut"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
    body: body);
    print(response.request!.url);
    print('captain storeOut shipment ${response.statusCode}');
    print('captain storeOut shipment ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    if (response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }



  static Future<MyResponseModel<bool>> captainStoreOutShipment({String? token, String? id}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.patch(
        Uri.parse(EventsAPIs.url + EndPoints.myOrders + "/$id/storeOut"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        });
    print(response.request!.url);
    print('captain storeOut shipment ${response.statusCode}');
    print('captain storeOut shipment ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    if (response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }
  static Future<MyResponseModel<bool>> captainReActiveShipment({String? token, String? id}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.patch(
        Uri.parse(EventsAPIs.url + EndPoints.myPickup + "/$id/reActive"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        });
    print(response.request!.url);
    print('captain storeOut shipment ${response.statusCode}');
    print('captain storeOut shipment ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    if (response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }
  static Future<MyResponseModel<bool>> captainDispatchShipment({String? token, String? id  }) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.patch(
        Uri.parse(EventsAPIs.url + EndPoints.myOrders + "/$id/dispatchIssue"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        });
    print(response.request!.url);
    print('captain dispatch issue shipment ${response.statusCode}');
    print('captain dispatch issue shipment ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    if (response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }
  static Future<MyResponseModel<bool>> captainPostponeShipment({String? token, String? id, String? reason , String? date ,  List<CallLogModel>? logHistory}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    List encondeToJson(List<CallLogModel>? list) {
      List jsonList = [];
      list?.map((item) => jsonList.add(item.toJson())).toList();
      return jsonList;
    }

    Map data = {
      "postpone": reason,
      "date":date,
      'callLog': encondeToJson(logHistory)
    };
    print("date from api $date");
    var body = json.encode(data);

    http.Response response = await http.patch(
        Uri.parse(EventsAPIs.url + EndPoints.myPickup + "/$id/postpone"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
        body: body);
    print(response.request!.url);
    print('captain postpone shipment ${response.statusCode}');
    print('captain postpone shipment ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    if (response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }
  static Future<MyResponseModel<List<String>>> getClientCredit({String? memberId, String? token, required List<OrdersDataModelMix> acceptedList}) async {
    UserRepository userRepository = UserRepository();

    List encondeToJson(List<OrdersDataModelMix> list) {
      List jsonList = [];
      list.map((item) => jsonList.add(item.toJson())).toList();
      return jsonList;
    }

    Map data = {"shipments": encondeToJson(acceptedList)};

    var body = json.encode(data);

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    MyResponseModel myResponseModel = MyResponseModel<List<String>>();

    http.Response response = await http.post(
        Uri.parse(EventsAPIs.url + EndPoints.calculates + "/$memberId"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
        body: body);

    print(response.request!.url);
    print('get client credit shipment ${response.statusCode}');
    print('get client credit shipment ${response.body}');

    List<String> calculation = [];
    myResponseModel.statusCode = response.statusCode;
    if (response.statusCode == 200) {
      try {
        var decodedData = jsonDecode(response.body);
        // final list = decodedData.map((data) => Credit.fromJson(data)).toList();
        // var clientCredit = list.cast<Credit>();

        //returns amount
        var amount = decodedData["amount"];
        calculation.insert(0, amount.toString());

        //return suspected price
        var suspectedPrice = decodedData["suspectedPrice"];
        calculation.insert(1, suspectedPrice.toString());

        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = calculation;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = calculation;
        myResponseModel.errorsList = List<String>.empty(growable: false);
        print(e);
      }
    } else {
      try {
        myResponseModel.responseData = calculation;
        var decodedData = jsonDecode(response.body);
        myResponseModel.errorsList =
            GeneralHandler.handleErrorsFromApi(decodedData);
      } catch (e) {
        myResponseModel.responseData = calculation;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      }
    }
    return myResponseModel as FutureOr<MyResponseModel<List<String>>>;
  }
  static Future<MyResponseModel<List<String>>> getReturnCharges({String? memberId, String? token, required List<OrdersDataModelMix> acceptedList}) async {
    UserRepository userRepository = UserRepository();

    List encondeToJson(List<OrdersDataModelMix> list) {
      List jsonList = [];
      list.map((item) => jsonList.add(item.toJson())).toList();
      return jsonList;
    }

    Map data = {"shipments": encondeToJson(acceptedList)};

    var body = json.encode(data);

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    MyResponseModel myResponseModel = MyResponseModel<List<String>>();

    http.Response response = await http.post(
        Uri.parse(EventsAPIs.url + EndPoints.returnToClient+"/calculateReturnFees"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
        body: body);

    print(response.request!.url);
    print('getReturnCharges ${response.statusCode}');
    print('getReturnCharges ${response.body}');

    List<String> calculation = [];
    myResponseModel.statusCode = response.statusCode;
    if (response.statusCode == 200) {
      try {
        var decodedData = jsonDecode(response.body);
        // final list = decodedData.map((data) => Credit.fromJson(data)).toList();
        // var clientCredit = list.cast<Credit>();

        //returns amount  100028832 100028834
        var amount = decodedData["amount"];
        calculation.insert(0, amount.toString());

        //return suspected price
        var suspectedPrice = decodedData["suspectedPrice"];
        calculation.insert(1, suspectedPrice.toString());

        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = calculation;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = calculation;
        myResponseModel.errorsList = List<String>.empty(growable: false);
        print(e);
      }
    } else {
      try {
        myResponseModel.responseData = calculation;
        var decodedData = jsonDecode(response.body);
        myResponseModel.errorsList =
            GeneralHandler.handleErrorsFromApi(decodedData);
      } catch (e) {
        myResponseModel.responseData = calculation;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      }
    }
    return myResponseModel as FutureOr<MyResponseModel<List<String>>>;
  }
  static Future<MyResponseModel<String>> getReceipt({String? paymentMethod ,  String? storeId}) async {
    UserRepository userRepository = UserRepository();

    List encondeToJson(List<OrdersDataModelMix> list) {
      List jsonList = [];
      list.map((item) => jsonList.add(item.toJson())).toList();
      return jsonList;
    }

    Map data = {
      "paymentMethod": paymentMethod,
      "storeId":storeId
    };

    var body = json.encode(data);

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();
    String? token = await userRepository.getAuthToken();

    MyResponseModel myResponseModel = MyResponseModel<String>();

    http.Response response = await http.post(
        Uri.parse(EventsAPIs.url + EndPoints.getReceipt),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: "$token",
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
        body: body);

    print(response.request!.url);
    print('getReceipt ${response.statusCode}');
    print('getReceipt ${response.body}');

    myResponseModel.statusCode = response.statusCode;
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        var decodedData = jsonDecode(response.body);
        var receipt = decodedData["receipt"];
        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = receipt;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = "";
        myResponseModel.errorsList = List<String>.empty(growable: false);
        print(e);
      }
    } else {
      var decodedData ;
      try {
        var decodedData = jsonDecode(response.body);
        myResponseModel.responseData = "";

        myResponseModel.errorsList =
            GeneralHandler.handleErrorsFromApi(decodedData);
      } catch (e) {
        myResponseModel.responseData = "";
        myResponseModel.errorsList = List<String>.empty(growable: false);
        myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(decodedData);
      }
    }
    return myResponseModel as FutureOr<MyResponseModel<String>>;
  }
  static Future<MyResponseModel<String>> setMsgType({String? msgType ,  String? receiverId , String? receiverPhone}) async {
    UserRepository userRepository = UserRepository();

    List encondeToJson(List<OrdersDataModelMix> list) {
      List jsonList = [];
      list.map((item) => jsonList.add(item.toJson())).toList();
      return jsonList;
    }

    Map data = {
      "msgType": msgType,
      "memberId":receiverId,
      "memberPhone" : receiverPhone,
    };

    var body = json.encode(data);

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();
    String? token = await userRepository.getAuthToken();

    MyResponseModel myResponseModel = MyResponseModel<String>();

    http.Response response = await http.post(
        Uri.parse(EventsAPIs.url + EndPoints.sendMsg),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: "$token",
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
        body: body);

    print(response.request!.url);
    print('setMsgType ${response.statusCode}');
    print('setMsgType ${response.body}');

    myResponseModel.statusCode = response.statusCode;
    if (response.statusCode == 200 || response.statusCode == 201) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = "";
      myResponseModel.errorsList = List<String>.empty(growable: false);
    }
    else {
      var decodedData ;
      try {
        var decodedData = jsonDecode(response.body);
        myResponseModel.responseData = "";

        myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(decodedData);
      } catch (e) {
        print(e);
        myResponseModel.responseData = "";
        myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(decodedData);
      }
    }
    return myResponseModel as FutureOr<MyResponseModel<String>>;
  }
  static Future<MyResponseModel<bool>> pickupIssue({String? reasonId, String? token2, required List<OrdersDataModelMix> acceptedList}) async {
    UserRepository userRepository = UserRepository();

    List encondeToJson(List<OrdersDataModelMix> list) {
      List jsonList = [];
      list.map((item) => jsonList.add(item.toJson())).toList();
      return jsonList;
    }

    Map data = {
      "shipments": encondeToJson(acceptedList),
      "pickupIssue": reasonId
    };

    var body = json.encode(data);

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();
    String? token = await userRepository.getAuthToken();

    MyResponseModel myResponseModel = MyResponseModel<bool>();

    http.Response response = await http.post(
        Uri.parse(EventsAPIs.url +
            EndPoints.myReserved ),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
        body: body);

    print(response.request!.url);
    print('pickup issue shipment ${response.statusCode}');
    print('pickup issue shipment ${response.body}');

    List<String> calculation = [];

    if (response.statusCode == 200 || response.statusCode == 201) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
    } else {
      try {
        myResponseModel.responseData = false;
        var decodedData = jsonDecode(response.body);
        myResponseModel.errorsList =
            GeneralHandler.handleErrorsFromApi(decodedData);
      } catch (e) {
        myResponseModel.responseData = false;
        myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(null);
      }
    }
    return myResponseModel as FutureOr<MyResponseModel<bool>>;
  }


  static Future<MyResponseModel<List<FuelEntryModel>>> getFuelHistory() async {
    UserRepository userRepository = UserRepository();
    MyResponseModel myResponseModel = MyResponseModel<List<FuelEntryModel>>();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();
    String? token = await userRepository.getAuthToken();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.fuel),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
    );
    print('${response.request!.url}');
    print('get fuel history ${response.statusCode}');
    print('get fuel history ${response.body}');

    myResponseModel.statusCode = response.statusCode;

    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body);

      try {
        final welcomeFromJson = decodedData.map((data) => FuelEntryModel.fromJson(data)).toList();
        var invoicesList = welcomeFromJson.cast<FuelEntryModel>();
        myResponseModel.responseData = invoicesList;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        print(e);
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = null;
        myResponseModel.errorsList =GeneralHandler.handleErrorsFromApi(decodedData);
        return myResponseModel as FutureOr<MyResponseModel<List<FuelEntryModel>>>;

      }
    } else {

      myResponseModel.responseData = <FuelEntryModel>[];
      myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(json.decode(response.body));
    }
    return myResponseModel as FutureOr<MyResponseModel<List<FuelEntryModel>>>;


  }

  static Future<MyResponseModel<bool>> postNewFuelEntry({required FuelEntryModel fuelEntryModel}) async {
    var body = json.encode(fuelEntryModel.toJson());
    String? token = await userRepository.getAuthToken();
    print(fuelEntryModel.createdAt);
    http.Response response = await http.post(Uri.parse(EventsAPIs.url + EndPoints.fuel),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: token.toString(),
          "ACCEPT-LANGUAGE": Constants.currentLocale,
          "appVersion": Constants.appVersion
        },
        body: body);
    print(response.request!.url);
    print('post new fuel ${response.statusCode}');
    print('post new fuel  ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<bool>();

    if (response.statusCode == 201 || response.statusCode == 204 || response.statusCode == 200 ) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }


  static Future<MyResponseModel<List<FuelEntryModel>>> getCarSrvHistory() async {
    UserRepository userRepository = UserRepository();
    MyResponseModel myResponseModel = MyResponseModel<List<FuelEntryModel>>();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();
    String? token = await userRepository.getAuthToken();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.carService),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
    );
    print('${response.request!.url}');
    print('get fuel history ${response.statusCode}');
    print('get fuel history ${response.body}');

    myResponseModel.statusCode = response.statusCode;

    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body);

      try {
        final welcomeFromJson = decodedData.map((data) => FuelEntryModel.fromJson(data)).toList();
        var invoicesList = welcomeFromJson.cast<FuelEntryModel>();
        myResponseModel.responseData = invoicesList;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = null;
        myResponseModel.errorsList =GeneralHandler.handleErrorsFromApi(decodedData);
        return myResponseModel as FutureOr<MyResponseModel<List<FuelEntryModel>>>;

      }
    } else {

      myResponseModel.responseData = <FuelEntryModel>[];
      myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(json.decode(response.body));
    }
    return myResponseModel as FutureOr<MyResponseModel<List<FuelEntryModel>>>;


  }

  static Future<MyResponseModel<bool>> postNewCarSrvEntry({required FuelEntryModel fuelEntryModel}) async {
    var body = json.encode(fuelEntryModel.toJson());
    print(fuelEntryModel.createdAt);
    String? token = await userRepository.getAuthToken();
    print(token);
    http.Response response = await http.post(Uri.parse(EventsAPIs.url + EndPoints.carService),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: token.toString(),
          "ACCEPT-LANGUAGE": Constants.currentLocale,
          "appVersion": Constants.appVersion
        },
        body: body);
    print(response.request!.url);
    print('post new fuel ${response.statusCode}');
    print('post new fuel  ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<bool>();

    if (response.statusCode == 201 || response.statusCode == 204 || response.statusCode == 200 ) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }


  static Future<MyResponseModel<Meter>> setMeterValue({required String value , required String type , String? id}) async {

    Map data = {"value": value, "type": type , "id" :id};
    var body = json.encode(data);


    String? token = await userRepository.getAuthToken();
    http.Response response = await http.post(Uri.parse(EventsAPIs.url + EndPoints.meter),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: token.toString(),
          "ACCEPT-LANGUAGE": Constants.currentLocale,
          "appVersion": Constants.appVersion
        },
        body: body);
    print(response.request!.url);
    print('post new fuel ${response.statusCode}');
    print('post new fuel  ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<Meter>();

    if (response.statusCode == 201 || response.statusCode == 204 || response.statusCode == 200 ) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = Meter.fromJson(jsonDecode(response.body));
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<Meter>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = null;
      myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<Meter>>;
    }
  }




  static Future<MyResponseModel<List<ViolationModel>>> getViolations() async {
    UserRepository userRepository = UserRepository();
    MyResponseModel myResponseModel = MyResponseModel<List<ViolationModel>>();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();
    String? token = await userRepository.getAuthToken();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.violations),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
    );
    print('${response.request!.url}');
    print('get violations history ${response.statusCode}');
    print('get violations history ${response.body}');

    myResponseModel.statusCode = response.statusCode;

    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body);

      try {
        final welcomeFromJson = decodedData.map((data) => ViolationModel.fromJson(data)).toList();
        var invoicesList = welcomeFromJson.cast<ViolationModel>();
        myResponseModel.responseData = invoicesList;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = null;
        myResponseModel.errorsList =GeneralHandler.handleErrorsFromApi(decodedData);
        return myResponseModel as FutureOr<MyResponseModel<List<ViolationModel>>>;

      }
    } else {

      myResponseModel.responseData = <ViolationModel>[];
      myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(json.decode(response.body));
    }
    return myResponseModel as FutureOr<MyResponseModel<List<ViolationModel>>>;


  }

  static postCaptainLocation({String? lat, String? long, String? token}) async {
    Map data = {"lat": lat, "long": long};

    var body = json.encode(data);

    http.Response response = await http.post(Uri.parse(EventsAPIs.url + "setLocation"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": EventsAPIs.compatibility,
          HttpHeaders.authorizationHeader: '$token',
          "appVersion": Constants.appVersion

          // ,"ACCEPT-LANGUAGE":locale ?? Constants.currentLocale ?? 'ar'
        },
        body: body);

    print(response.request!.url);
    print('location ${response.statusCode}');
  }


  static Future<MyResponseModel<List<TripModel>>> getAllTrips() async {
    UserRepository userRepository = UserRepository();
    MyResponseModel myResponseModel = MyResponseModel<List<TripModel>>();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();
    String? token = await userRepository.getAuthToken();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.trips+"/create"),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
    );
    print('${response.request!.url}');
    print('get violations history ${response.statusCode}');
    print('get violations history ${response.body}');

    myResponseModel.statusCode = response.statusCode;

    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body);

      try {
        final welcomeFromJson = decodedData.map((data) => TripModel.fromJson(data)).toList();
        var invoicesList = welcomeFromJson.cast<TripModel>();
        myResponseModel.responseData = invoicesList;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = null;
        myResponseModel.errorsList =GeneralHandler.handleErrorsFromApi(decodedData);
        return myResponseModel as FutureOr<MyResponseModel<List<TripModel>>>;

      }
    } else {

      myResponseModel.responseData = <ViolationModel>[];
      myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(json.decode(response.body));
    }
    return myResponseModel as FutureOr<MyResponseModel<List<TripModel>>>;


  }

  static Future<MyResponseModel<TripModel>> getLastTrip() async {


    String? token = await userRepository.getAuthToken();
    http.Response response = await http.get(Uri.parse(EventsAPIs.url + EndPoints.trips),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: token.toString(),
          "ACCEPT-LANGUAGE": Constants.currentLocale,
          "appVersion": Constants.appVersion
        },
     );
    print(response.request!.url);
    print('get ongoing trip ${response.statusCode}');
    print('post new fuel  ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<TripModel>();

    if (response.statusCode == 201 || response.statusCode == 204 || response.statusCode == 200 ) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = TripModel.fromJson(jsonDecode(response.body));
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<TripModel>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = null;
      myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<TripModel>>;
    }
  }

  static Future<MyResponseModel<TripModel>> createTrip({required TripModel? tripModel}) async {


    var body = json.encode(tripModel?.toJson());

    String? token = await userRepository.getAuthToken();
    http.Response response = await http.post(Uri.parse(EventsAPIs.url + EndPoints.trips),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: token.toString(),
          "ACCEPT-LANGUAGE": Constants.currentLocale,
          "appVersion": Constants.appVersion
        },
        body: body);
    print(response.request!.url);
    print('create trip ${response.statusCode}');
    print('create trip ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<TripModel>();

    if (response.statusCode == 201 || response.statusCode == 204 || response.statusCode == 200 ) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = TripModel.fromJson(jsonDecode(response.body));
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<TripModel>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = null;
      myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<TripModel>>;
    }
  }

  static Future<MyResponseModel<TripModel>> setTripEnd({required TripModel? tripModel}) async {


    var body = json.encode(tripModel?.toJson());

    String? token = await userRepository.getAuthToken();
    http.Response response = await http.patch(Uri.parse(EventsAPIs.url + EndPoints.trips+"/${tripModel?.id}"),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: token.toString(),
          "ACCEPT-LANGUAGE": Constants.currentLocale,
          "appVersion": Constants.appVersion
        },
        body: body);
    print(response.request!.url);
    print('create trip ${response.statusCode}');
    print('create trip ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<TripModel>();

    if (response.statusCode == 201 || response.statusCode == 204 || response.statusCode == 200 ) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = TripModel.fromJson(jsonDecode(response.body));
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<TripModel>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = null;
      myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<TripModel>>;
    }
  }

  static Future<MyResponseModel<ClientBalanceModel>> getClientBalance({String? token, String? memberId}) async {
    UserRepository userRepository = UserRepository();
    String? locale = await userRepository.getLocale();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.memberBalance + "/$memberId"),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": EventsAPIs.compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "appVersion": Constants.appVersion
      },
    );
    print(response.request!.url);
    print('get client balance ${response.statusCode}');
    print('get client balance ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<ClientBalanceModel>();
    ClientBalanceModel clientBalanceModel = ClientBalanceModel();

    if (response.statusCode == 200) {
      try {
        var decodedData = json.decode(response.body);
        clientBalanceModel = ClientBalanceModel.fromJson(decodedData);
        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = clientBalanceModel;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = clientBalanceModel;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      }
    } else {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = clientBalanceModel;
      myResponseModel.errorsList = List<String>.empty(growable: false);
    }
    return myResponseModel as FutureOr<MyResponseModel<ClientBalanceModel>>;
  }
}
