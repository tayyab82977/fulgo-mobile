import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:xturbox/UserRepo.dart';
import 'package:xturbox/data_providers/models/ProfileDataModel.dart';
import 'package:xturbox/data_providers/models/MyResponseModel.dart';
import 'package:xturbox/data_providers/models/OrdersDataModel.dart';
import 'package:xturbox/data_providers/models/captainOrdersDataModel.dart';
import 'package:xturbox/data_providers/models/clientPaymentsDataModel.dart';
import 'package:xturbox/data_providers/models/geoCodingDataModel.dart';
import 'package:xturbox/data_providers/models/invoices_lists_model.dart';
import 'package:xturbox/data_providers/models/invoices_model.dart';
import 'package:xturbox/data_providers/models/memberBalanceModel.dart';
import 'package:xturbox/data_providers/models/postOrderData.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/data_providers/models/shipments_lists_model.dart';
import 'package:xturbox/data_providers/models/tickets_model.dart';
import 'package:xturbox/data_providers/models/trackingDataModel.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/GeneralHandling.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xturbox/utilities/URLs.dart';
import 'package:xturbox/utilities/endPoints.dart';

import '../models/NationalAddreesModel.dart';

class EventsAPIs {

  // static const String url = URL.LIVE_SERVER;
  static const String url = URL.Anas_SERVER;
  // static  String url ;

  static const compatibility = "2";

  UserRepository userRepository = UserRepository();

  static Future<MyResponseModel<ResourcesData>> getResourcesData({String? token}) async {
    ResourcesData resourcesData = ResourcesData();
    MyResponseModel myResponseModel = MyResponseModel<ResourcesData>();
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    http.Response response = await http
        .get(Uri.parse(EventsAPIs.url + EndPoints.resources), headers: {
      HttpHeaders.authorizationHeader: token!,
      "compatibility": compatibility,
      "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale
    });

    print(response.request!.url);
    print('Resources ${response.statusCode}');
    print('Resources ${response.body}');

    if (response.statusCode == 200) {
      try {
        myResponseModel.statusCode = response.statusCode;
        final decodedData = jsonDecode(response.body);
        resourcesData = ResourcesData.fromJson(decodedData);
      } catch (e) {
        print(e);
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = resourcesData;
        myResponseModel.errorsList = List<String>.empty(growable: false);
        return myResponseModel as FutureOr<MyResponseModel<ResourcesData>>;
      }
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = resourcesData;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<ResourcesData>>;
    } else {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = resourcesData;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<ResourcesData>>;
    }
  }

  // ignore: non_constant_identifier_names
  static Future<MyResponseModel<bool>> EditProfile({
      String? name,
      String? id,
      String? password,
      String? email,
      String? national_id,
      String? phone2,
      String? firstName,
      String? lastName,
      String? companyName,
      String? vatNumber,
      String? cer,
      bool onlyNational = false,
      bool? changeUserName}) async {

    Map data = {};
    if(onlyNational){

      data = {
        "national_id":national_id,
      };

    }else {

      data = {
        "name": name,
        "password": password,
        "passConf": password,
        "email": email,
        "phone2": phone2,
        "first_name": firstName,
        "second_name": lastName,
        "national_id":national_id,
        "company":companyName,
        "vat":vatNumber,
        "cr":cer,
        "idType": 1,
        "idNumber": "ise90sl"
      };

    }

    if (!(changeUserName ?? true)) {
      data.remove('name');
    }

    var body = json.encode(data);
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? token = await userRepository.getAuthToken();
    String? fcm = await userRepository.getFcmToken();
    MyResponseModel myResponseModel = MyResponseModel<bool>();

    http.Response response =
        await http.put(Uri.parse(EventsAPIs.url + EndPoints.profile+"/0"),
            headers: {
              "Content-Type": "application/json",
              HttpHeaders.authorizationHeader: "$token",
              "compatibility": compatibility,
              // "ACCEPT-LANGUAGE":locale ?? Constants.currentLocale ?? 'ar'
              "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
              "fbId": fcm.toString(), "appVersion": Constants.appVersion
            },
            body: body);
    print(response.request!.url);
    print('edit process ${response.statusCode}');
    print('edit process body ${response.body}');

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);
      try {
        SavedData.profileDataModel.national_id = decodedData['national_id'] ;
        myResponseModel.responseData = true;
        myResponseModel.statusCode = response.statusCode ;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = false;
        myResponseModel.errorsList = List<String>.empty(growable: false);
        print('dashboard Error \n $e');
      }

      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var decodedData ;
      try{
        decodedData = jsonDecode(response.body);

      }catch(e){

      }
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);

      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }

  // ignore: non_constant_identifier_names
  static Future<MyResponseModel<bool>> AddBankData({String? token, String? name, String? bankName, String? iban}) async {
    Map data = {
      "bankHolder": name,
      "bank": bankName,
      "iban": iban,
    };

    var body = json.encode(data);
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response =
        await http.patch(Uri.parse(EventsAPIs.url + EndPoints.profile+"/0"),
            headers: {
              "Content-Type": "application/json",
              HttpHeaders.authorizationHeader: "$token",
              "compatibility": compatibility,
              "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
              "fbId": fcm.toString(),
              "appVersion": Constants.appVersion
            },
            body: body);
    print(response.request!.url);
    print('add bank ${response.statusCode}');
    print('add bank body ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();

    if (response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
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
      myResponseModel.responseData = false;
      myResponseModel.errorsList = errorList;
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }
  static Future<MyResponseModel<bool>> addNationalAddress({required NationalAddressModel nationalAddressModel}) async {

    var body = json.encode(nationalAddressModel.toJson());
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();
    String? token = await userRepository.getAuthToken();

    http.Response response =
        await http.post(Uri.parse(EventsAPIs.url + EndPoints.addNationalAddress),
            headers: {
              "Content-Type": "application/json",
              HttpHeaders.authorizationHeader: "$token",
              "compatibility": compatibility,
              "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
              "fbId": fcm.toString(),
              "appVersion": Constants.appVersion
            },
            body: body);
    print(response.request!.url);
    print('add national address ${response.statusCode}');
    print('add national address ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();

    if (response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
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
      myResponseModel.responseData = false;
      myResponseModel.errorsList = errorList;
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }

  // ignore: non_constant_identifier_names
  static Future<MyResponseModel<bool>> AddAddresses(
      {String? token, required List<Addresses> list}) async {
    List encondeToJson(List<Addresses> list) {
      List jsonList = [];
      list.map((item) => jsonList.add(item.toJson())).toList();
      return jsonList;
    }

    Map data = {
      "addresses": encondeToJson(list),
    };

    var body = json.encode(data);
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response =
        await http.post(Uri.parse(EventsAPIs.url + EndPoints.profile),
            headers: {
              "Content-Type": "application/json",
              HttpHeaders.authorizationHeader: "$token",
              "compatibility": compatibility,
              "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
              "fbId": fcm.toString(),
              "appVersion": Constants.appVersion
            },
            body: body);
    print(response.request!.url);
    print('add ADDRESS ${response.statusCode}');
    print('add ADDRESS body ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();

    if (response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var decodedData ;
      decodedData = jsonDecode(response.body);
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(decodedData);

      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }

  // ignore: non_constant_identifier_names
  static Future<MyResponseModel<bool>> CancelClientOrder(
      {String? token, String? id}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.delete(
        Uri.parse(EventsAPIs.url + EndPoints.myShipments + "/$id"),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: '$token',
          "compatibility": compatibility,
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        });
    print(response.request!.url);
    print('cancel client order ${response.statusCode}');
    print('cancel client order ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<bool>();

    if (response.statusCode == 200) {
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

  // ignore: non_constant_identifier_names
  static Future<MyResponseModel<bool>> PostNewOrder({String? token, required PostOrderDataModel postOrder,}) async {
    List encondeToJson(List<Packages> list) {
      List jsonList = [];
      list.map((item) => jsonList.add(item.toJson())).toList();
      return jsonList;
    }

    Map data = {
      "senderName": postOrder.senderName,
      "senderPhone": postOrder.senderPhone,
      "pickupTime": postOrder.pickupTime,
      "pickupAddress": postOrder.pickupAddress,
      "pickupNeighborhood": postOrder.pickupNeighborhood,
      "receiverName": postOrder.receiverName,
      "receiverPhone": postOrder.receiverPhone,
      "deliverTime": postOrder.deliverTime,
      "deliverAddress": postOrder.deliverAddress,
      "deliverNeighborhood": postOrder.deliverNeighborhood,
      "pickupMap": postOrder.pickupMap,
      "deliverMap": postOrder.deliverMap,
      "rc": postOrder.rc,
      "latePayment": postOrder.deductFromCod,
      "pickupCity":postOrder.pickupCity,
      "deliverCity":postOrder.deliverCity,
      "payment_method":postOrder.payment_method,
      "packages": encondeToJson(postOrder.packages!)
    };
    print("from api time ${postOrder.pickupTime}" );

    var body = json.encode(data);
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response =
        await http.post(Uri.parse(EventsAPIs.url + EndPoints.myShipments),
            headers: {
              "Content-Type": "application/json",
              HttpHeaders.authorizationHeader: "$token",
              "compatibility": compatibility,
              "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
              "fbId": fcm.toString(),
              "appVersion": Constants.appVersion
            },
            body: body);
    print(response.request!.url);
    print('post new order ${response.statusCode}');
    print('post new order ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<bool>();

    if (response.statusCode == 201) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);

      // signUpModel.checkSignUp = true ;
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
  static Future<MyResponseModel<bool>> postNewTicket({
    String? token, required String shipment ,  required String subject , required String description , required String cat}) async {

    Map data = {
      "member": SavedData.profileDataModel.id,
      "shipment": shipment,
      "subject": subject,
      "description": description,
      "category_id": cat,
    };
    var body = json.encode(data);
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response =
        await http.post(Uri.parse(EventsAPIs.url + EndPoints.tickets),
            headers: {
              "Content-Type": "application/json",
              HttpHeaders.authorizationHeader: "$token",
              "compatibility": compatibility,
              "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
              "fbId": fcm.toString(),
              "appVersion": Constants.appVersion
            },
            body: body);
    print(response.request!.url);
    print('post new ticket ${response.statusCode}');
    print('post new ticket ${response.body}');

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

  // ignore: non_constant_identifier_names
  static Future<MyResponseModel<bool>> ClientEditOrderCall({String? token, required OrdersDataModelMix postOrder, String? shipmentId,}) async {
    // OrdersDataModelMix.
    var body = json.encode(postOrder.toJson());
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.put(
        Uri.parse(EventsAPIs.url + EndPoints.myShipments + "/" + postOrder.id!),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: "$token",
          "compatibility": compatibility,
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
        body: body);
    print(response.request!.url);
    print('edit order ${response.statusCode}');
    print('edit order ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<bool>();

    if (response.statusCode == 201 || response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var errorList;
      try {
        var decodedData = jsonDecode(response.body);
        var errorListBad = decodedData['error'];
        errorList = ['$errorListBad'];
      } catch (e) {
        try {
          var decodedData = jsonDecode(response.body);
          var errorListBad = decodedData['error'];
          errorList = ['$errorListBad'];
        } catch (e) {
          errorList = List<String>.empty(growable: false);
        }
      }

      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList = errorList;
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }
  static Future<MyResponseModel<bool>> reverseShipment({String? token, required OrdersDataModelMix postOrder, String? shipmentId,}) async {
    // OrdersDataModelMix.
    var body = json.encode(postOrder.toJson());
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.patch(
        Uri.parse(EventsAPIs.url + EndPoints.myShipments + "/" + postOrder.id!),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: "$token",
          "compatibility": compatibility,
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "fbId": fcm.toString(),
          "appVersion": Constants.appVersion
        },
        body: body);
    print(response.request!.url);
    print('edit order ${response.statusCode}');
    print('edit order ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<bool>();

    if (response.statusCode == 201 || response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var errorList;
      try {
        var decodedData = jsonDecode(response.body);
        var errorListBad = decodedData['error'];
        errorList = ['$errorListBad'];
      } catch (e) {
        try {
          var decodedData = jsonDecode(response.body);
          var errorListBad = decodedData['error'];
          errorList = ['$errorListBad'];
        } catch (e) {
          errorList = List<String>.empty(growable: false);
        }
      }

      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList = errorList;
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }



  static Future<MyResponseModel<bool>> clientZeroCod(
      {String? token, String? id}) async {
    UserRepository userRepository = UserRepository();
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    Response response = await http.patch(
      Uri.parse(EventsAPIs.url + EndPoints.ab + "/$id/cod"),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "appVersion": Constants.appVersion,
        "fbId": fcm.toString()
      },
    );
    print('zero cod call ${response.statusCode}');
    print('zero cod call ${response.body}');
    myResponseModel.statusCode = response.statusCode;
    if (response.statusCode == 200 || response.statusCode == 204) {
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

  static Future<MyResponseModel<bool>> clientZeroRC(
      {String? token, String? id}) async {
    UserRepository userRepository = UserRepository();
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    Response response = await http.patch(
      Uri.parse(EventsAPIs.url + EndPoints.ab + "/$id/rc"),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "appVersion": Constants.appVersion,
        "fbId": fcm.toString()
      },
    );
    print('zero rc call ${response.statusCode}');
    print('zero rc call ${response.body}');
    myResponseModel.statusCode = response.statusCode;
    if (response.statusCode == 200 || response.statusCode == 204) {
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

  static Future<int> askForSMS(
      {String? phone,
      String? name,
      String? password,
      String? firstName,
      String? nationalId,
      String? lastName,
      String? companyName,
      String? vatNumber,
      }) async {
    print("form ask for sms $nationalId");
    Map data = {
      "name": name,
      "first_name": firstName,
      "second_name": lastName,
      "password": password,
      "passConf": password,
      "phone": phone,
      "nationa44l_id": nationalId,
      "vat": vatNumber,
      "company": companyName,
    };
    var body = json.encode(data);
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response responseViewModel = await http.post(
      Uri.parse(EventsAPIs.url + EndPoints.confirmations),
      headers: {
        "Content-Type": "application/json",
        "compatibility": compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
      body: body,
    );
    print(responseViewModel.request!.url);
    print('ask for sms ${responseViewModel.statusCode}');
    print('ask for sms ${responseViewModel.body}');
    return responseViewModel.statusCode;
  }

  // ignore: non_constant_identifier_names
  static Future<MyResponseModel<bool>> CodeConfirmation(
      {String? phone, String? code}) async {
    MyResponseModel myResponseModel = MyResponseModel<bool>();
    Map data = {
      "phone": phone,
    };
    var body = json.encode(data);
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();

    http.Response responseViewModel = await http.patch(
        Uri.parse(EventsAPIs.url + EndPoints.confirmations + "/$code"),
        headers: {
          "Content-Type": "application/json",
          "compatibility": compatibility,
          "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
          "appVersion": Constants.appVersion
        },
        body: body);
    print(responseViewModel.request!.url);
    print('confirm mobile ${responseViewModel.statusCode}');
    print('confirm mobile ${responseViewModel.body}');
    myResponseModel.statusCode = responseViewModel.statusCode;
    if (responseViewModel.statusCode == 201 ||
        responseViewModel.statusCode == 200) {
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      myResponseModel.responseData = false;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }

  // ignore: non_constant_identifier_names
  static Future<MyResponseModel<ProfileDataModel>> FetchDashBoardData({String? token}) async {
    UserRepository userRepository = UserRepository();
    MyResponseModel myResponseModel = MyResponseModel<ProfileDataModel>();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response responseViewModel = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.profile),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
    );
    print('${responseViewModel.request!.url}');
    print('dashboard call ${responseViewModel.statusCode}');
    print('dashboard call ${responseViewModel.body}');

    myResponseModel.statusCode = responseViewModel.statusCode;

    if (responseViewModel.statusCode == 200) {
      var decodedData = json.decode(responseViewModel.body);
      userRepository.persistUser(userData: decodedData);

      ProfileDataModel dashboardDataModel = ProfileDataModel();
      // dashboardDataModel   = DashboardDataModel.fromJson(decodedData);

      try {
        dashboardDataModel = ProfileDataModel.fromJson(decodedData);
        myResponseModel.responseData = dashboardDataModel;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = null;
        myResponseModel.errorsList = List<String>.empty(growable: false);
        print('dashboard Error \n $e');
      }
      return myResponseModel as FutureOr<MyResponseModel<ProfileDataModel>>;
    } else {
      myResponseModel.responseData = null;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<ProfileDataModel>>;
    }
  }


  static Future<List<dynamic>> getSuggestedAddress({String? pattern}) async {
    UserRepository userRepository = UserRepository();
    MyResponseModel myResponseModel = MyResponseModel<List<InvoicesModel>>();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();
    String? token = await userRepository.getAuthToken();

    Map data = {
      "phone": pattern,
    };
    var body = json.encode(data);

    http.Response response = await http.post(
      Uri.parse(EventsAPIs.url + EndPoints.getPreviousAddresses+"/${SavedData.profileDataModel.id}"),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
      body: body
    );
    print('${response.request!.url}');
    print('get address suggestions ${response.statusCode}');
    print('get address suggestions ${response.body}');

    myResponseModel.statusCode = response.statusCode;

    if (response.statusCode == 200) {
      print("Test");
      var decodedData ;
      // return decodedData as FutureOr<Map>;

      // try {
        decodedData = json.decode(response.body);
        return decodedData as List<dynamic>;

      // } catch (e) {
      //   return null as Future<Iterable<Map>>;
      //
      // }
    } else {

      myResponseModel.responseData = <InvoicesModel>[];
      myResponseModel.errorsList = List<String>.empty(growable: false);
    }
    return [] ;
  }




  static Future<MyResponseModel<InvoicesListsModel>> getInvoices({String? token}) async {
    UserRepository userRepository = UserRepository();
    MyResponseModel myResponseModel = MyResponseModel<InvoicesListsModel>();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.myInvoices),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
    );
    print('${response.request!.url}');
    print('invoices call ${response.statusCode}');
    print('invoices call ${response.body}');

    myResponseModel.statusCode = response.statusCode;
    InvoicesListsModel invoicesListsModel = InvoicesListsModel();
    if (response.statusCode == 200) {
      try {
        var decodedData = json.decode(response.body);
        invoicesListsModel = InvoicesListsModel.fromJson(decodedData);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = invoicesListsModel;
        myResponseModel.errorsList = ['Error'];
        print('invoices Error \n $e');
        return myResponseModel as FutureOr<MyResponseModel<InvoicesListsModel>>;
      }
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = invoicesListsModel;
      myResponseModel.errorsList = List<String>.empty(growable: false);
    } else {
      myResponseModel.responseData = invoicesListsModel;
      myResponseModel.errorsList = List<String>.empty(growable: false);
    }
    return myResponseModel as FutureOr<MyResponseModel<InvoicesListsModel>>;


  }

  static Future<MyResponseModel<ClientBalanceModel>> getPaymentMethods() async {
    UserRepository userRepository = UserRepository();
    MyResponseModel myResponseModel = MyResponseModel<ClientBalanceModel>();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();
    String? token = await userRepository.getAuthToken();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.memberBalance+"/"+SavedData.profileDataModel.id.toString()),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
    );
    print('${response.request!.url}');
    print('getPaymentMethods ${response.statusCode}');
    print('getPaymentMethods ${response.body}');

    myResponseModel.statusCode = response.statusCode;
    ClientBalanceModel clientBalanceModel = ClientBalanceModel();
    if (response.statusCode == 200) {
      try {
        var decodedData = json.decode(response.body);
        clientBalanceModel = ClientBalanceModel.fromJson(decodedData);
        myResponseModel.responseData = clientBalanceModel;
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = clientBalanceModel;
        myResponseModel.errorsList = ['Error'];
        print('invoices Error \n $e');
        return myResponseModel as FutureOr<MyResponseModel<ClientBalanceModel>>;
      }
    } else {
      myResponseModel.responseData = null;
      myResponseModel.errorsList = List<String>.empty(growable: false);
    }
    return myResponseModel as FutureOr<MyResponseModel<ClientBalanceModel>>;


  }


  static Future<MyResponseModel<List<TicketsModel>>> getTickets({String? token}) async {
    UserRepository userRepository = UserRepository();
    MyResponseModel myResponseModel = MyResponseModel<List<TicketsModel>>();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.tickets),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
    );
    print('${response.request!.url}');
    print('get tickets ${response.statusCode}');
    print('get tickets ${response.body}');

    myResponseModel.statusCode = response.statusCode;

    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body);

      try {
        final welcomeFromJson = decodedData.map((data) => TicketsModel.fromJson(data)).toList();
        var invoicesList = welcomeFromJson.cast<TicketsModel>();
        myResponseModel.responseData = invoicesList;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = null;
        myResponseModel.errorsList =GeneralHandler.handleErrorsFromApi(decodedData);
        print('invoices Error \n $e');
        return myResponseModel as FutureOr<MyResponseModel<List<TicketsModel>>>;

      }
    } else {

      myResponseModel.responseData = <TicketsModel>[];
      myResponseModel.errorsList = List<String>.empty(growable: false);
    }
    return myResponseModel as FutureOr<MyResponseModel<List<TicketsModel>>>;


  }
  static Future<MyResponseModel<List<TicketsHistoryModel>>> getTicketsHistory({String? token ,required String ticketId}) async {
    UserRepository userRepository = UserRepository();
    MyResponseModel myResponseModel = MyResponseModel<List<TicketsHistoryModel>>();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.tickets+"/$ticketId"),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
    );
    print('${response.request!.url}');
    print('get tickets history ${response.statusCode}');
    print('get tickets history ${response.body}');

    myResponseModel.statusCode = response.statusCode;

    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body);

      try {
        final welcomeFromJson = decodedData.map((data) => TicketsHistoryModel.fromJson(data)).toList();
        var invoicesList = welcomeFromJson.cast<TicketsHistoryModel>();
        myResponseModel.responseData = invoicesList;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = null;
        myResponseModel.errorsList =GeneralHandler.handleErrorsFromApi(decodedData);
        print('invoices Error \n $e');
        return myResponseModel as FutureOr<MyResponseModel<List<TicketsHistoryModel>>>;

      }
    } else {

      myResponseModel.responseData = <TicketsHistoryModel>[];
      myResponseModel.errorsList = List<String>.empty(growable: false);
    }
    return myResponseModel as FutureOr<MyResponseModel<List<TicketsHistoryModel>>>;


  }

  // ignore: non_constant_identifier_names
  static Future<MyResponseModel<ShipmentsListsModel>> GetMyOrders({String? token}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.myShipments),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
    );
    print(response.request!.url);
    print('orders call ${response.statusCode}');
    print('orders call ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<ShipmentsListsModel>();
    ShipmentsListsModel shipmentsListsModel = ShipmentsListsModel();
    if (response.statusCode == 200) {
      try {
        var decodedData = json.decode(response.body);
        shipmentsListsModel = ShipmentsListsModel.fromJson(decodedData);
        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = shipmentsListsModel;
        myResponseModel.errorsList = List<String>.empty(growable: false);
        return myResponseModel as FutureOr<MyResponseModel<ShipmentsListsModel>>;
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = shipmentsListsModel;
        myResponseModel.errorsList = List<String>.empty(growable: false);
        return myResponseModel as FutureOr<MyResponseModel<ShipmentsListsModel>>;
      }
    } else if (response.statusCode == 204) {
      myResponseModel.statusCode = response.statusCode;
      // List<OrdersDataModelMix> fakeList = List<OrdersDataModelMix>.empty(growable: false);
      myResponseModel.errorsList = List<String>.empty(growable: false);
      // myResponseModel.responseData = fakeList;
      return myResponseModel as FutureOr<MyResponseModel<ShipmentsListsModel>>;
    } else {
      var errorList;
      try {
        var decodedData = jsonDecode(response.body);
        var errorListBad = decodedData['error'];
        errorList = errorListBad.cast<String>();
      } catch (e) {
        errorList = List<String>.empty(growable: false);
      }

      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = null;
      myResponseModel.errorsList = errorList;

      return myResponseModel as FutureOr<MyResponseModel<ShipmentsListsModel>>;
    }
  }


  static Future<MyResponseModel<List<OrdersDataModelMix>>> getOfdOrders({String? token}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.getOfdShipments),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
    );
    print(response.request!.url);
    print('getOfdOrders call ${response.statusCode}');
    print('getOfdOrders call ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<List<OrdersDataModelMix>>();
    ShipmentsListsModel shipmentsListsModel = ShipmentsListsModel();
    if (response.statusCode == 200) {
      try {
        var decodedData = json.decode(response.body);
        final welcomeFromJson = decodedData.map((data) => OrdersDataModelMix.fromJson(data)).toList();
        var myOrdersList = welcomeFromJson.cast<OrdersDataModelMix>();
        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = myOrdersList;
        myResponseModel.errorsList = List<String>.empty(growable: false);
        return myResponseModel as FutureOr<MyResponseModel<List<OrdersDataModelMix>>>;
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = <OrdersDataModelMix>[];
        myResponseModel.errorsList = List<String>.empty(growable: false);
        return myResponseModel as FutureOr<MyResponseModel<List<OrdersDataModelMix>>>;
      }
    } else if (response.statusCode == 204) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = <OrdersDataModelMix>[];
      myResponseModel.errorsList = List<String>.empty(growable: false);
      // myResponseModel.responseData = fakeList;
      return myResponseModel as FutureOr<MyResponseModel<List<OrdersDataModelMix>>>;
    } else {
      var errorList;
      try {
        var decodedData = jsonDecode(response.body);
        var errorListBad = decodedData['error'];
        errorList = errorListBad.cast<String>();
      } catch (e) {
        errorList = List<String>.empty(growable: false);
      }

      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = <OrdersDataModelMix>[];
      myResponseModel.errorsList = errorList;

      return myResponseModel as FutureOr<MyResponseModel<List<OrdersDataModelMix>>>;
    }
  }

  static Future<MyResponseModel<OrdersDataModelMix>> getShipmentDetails(
      {String? token, String? id}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.myShipments + "/$id"),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
    );
    print(response.request!.url);
    print('GetShipmentDetails call ${response.statusCode}');
    print('GetShipmentDetails call ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<OrdersDataModelMix>();

    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body);
      try {
        OrdersDataModelMix ordersDataModelMix =
            OrdersDataModelMix.fromJson(decodedData);
        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = ordersDataModelMix;
        myResponseModel.errorsList = List<String>.empty(growable: false);
        return myResponseModel as FutureOr<MyResponseModel<OrdersDataModelMix>>;
      } catch (e) {
        print('Getting client order error');
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = null;
        myResponseModel.errorsList = List<String>.empty(growable: false);
        return myResponseModel as FutureOr<MyResponseModel<OrdersDataModelMix>>;
      }
    } else if (response.statusCode == 204) {
      myResponseModel.statusCode = response.statusCode;
      List<OrdersDataModelMix> fakeList =
          List<OrdersDataModelMix>.empty(growable: false);
      myResponseModel.errorsList = List<String>.empty(growable: false);
      myResponseModel.responseData = fakeList;
      return myResponseModel as FutureOr<MyResponseModel<OrdersDataModelMix>>;
    } else {
      var errorList;
      try {
        var decodedData = jsonDecode(response.body);
        var errorListBad = decodedData['error'];
        errorList = errorListBad.cast<String>();
      } catch (e) {
        errorList = List<String>.empty(growable: false);
      }

      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = null;
      myResponseModel.errorsList = errorList;

      return myResponseModel as FutureOr<MyResponseModel<OrdersDataModelMix>>;
    }
  }

  // ignore: non_constant_identifier_names
  static Future<MyResponseModel<List<ClientPaymentsDataModel>>> GetMyPayments(
      {String? token}) async {
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response = await http.get(
      Uri.parse(EventsAPIs.url + EndPoints.myPayments),
      headers: {
        "Content-Type": "application/json",
        HttpHeaders.authorizationHeader: '$token',
        "compatibility": compatibility,
        "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
        "fbId": fcm.toString(),
        "appVersion": Constants.appVersion
      },
    );
    print(response.request!.url);
    print('myPayments ${response.statusCode}');
    print('myPayments ${response.body}');

    MyResponseModel myResponseModel =
        MyResponseModel<List<ClientPaymentsDataModel>>();

    if (response.statusCode == 200) {
      var decodedData = json.decode(response.body);
      try {
        final welcomeFromJson = decodedData.map((data) => ClientPaymentsDataModel.fromJson(data)).toList();
        var myOrdersList = welcomeFromJson.cast<ClientPaymentsDataModel>();
        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = myOrdersList;
        myResponseModel.errorsList = List<String>.empty(growable: false);
        return myResponseModel
            as FutureOr<MyResponseModel<List<ClientPaymentsDataModel>>>;
      } catch (e) {
        print('Getting client payments error');
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = null;
        myResponseModel.errorsList = List<String>.empty(growable: false);
        return myResponseModel
            as FutureOr<MyResponseModel<List<ClientPaymentsDataModel>>>;
      }
    } else if (response.statusCode == 204) {
      List<ClientPaymentsDataModel> myPaymentsList =
          List<ClientPaymentsDataModel>.empty(growable: false);
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = myPaymentsList;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel
          as FutureOr<MyResponseModel<List<ClientPaymentsDataModel>>>;
    } else {
      var errorList;
      try {
        var decodedData = jsonDecode(response.body);
        var errorListBad = decodedData['error'];
        errorList = errorListBad.cast<String>();
      } catch (e) {
        errorList = List<String>.empty(growable: false);
      }

      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData =
          List<ClientPaymentsDataModel>.empty(growable: false);
      myResponseModel.errorsList = errorList;

      return myResponseModel
          as FutureOr<MyResponseModel<List<ClientPaymentsDataModel>>>;
    }
  }

  static Future<MyResponseModel<bool>> getCode({
    String? phone,
  }) async {
    // OrdersDataModelMix.

    UserRepository userRepository = UserRepository();

    Map data = {
      "phone": phone,
    };
    var body = json.encode(data);

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response =
        await http.get(Uri.parse(EventsAPIs.url + EndPoints.confirmations+"/$phone"),
            headers: {
              "Content-Type": "application/json",
              "compatibility": compatibility,
              "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
              "fbId": fcm.toString(),
              "appVersion": Constants.appVersion
            },
        );
    print(response.request!.url);
    print('get phone code ${response.statusCode}');
    print('get phone code ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<bool>();

    if (response.statusCode == 201 || response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var errorList;
      try {
        var decodedData = jsonDecode(response.body);
        var errorListBad = decodedData['error'];
        errorList = ['$errorListBad'];
      } catch (e) {
        try {
          var decodedData = jsonDecode(response.body);
          var errorListBad = decodedData['error'];
          errorList = ['$errorListBad'];
        } catch (e) {
          errorList = List<String>.empty(growable: false);
        }
      }

      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList = errorList;
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }

  static Future<MyResponseModel<bool>> changePassword({
    String? phone,
    String? password,
    String? code,
  }) async {
    // OrdersDataModelMix.

    UserRepository userRepository = UserRepository();

    Map data = {"phone": phone, "password": password, "passConf": password};
    var body = json.encode(data);

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response =
        await http.put(Uri.parse(EventsAPIs.url + EndPoints.confirmations + "/$code"),
            headers: {
              "Content-Type": "application/json",
              "compatibility": compatibility,
              "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
              "fbId": fcm.toString(),
              "appVersion": Constants.appVersion
            },
            body: body);
    print(response.request!.url);
    print('get phone code ${response.statusCode}');
    print('get phone code ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<bool>();

    if (response.statusCode == 201 || response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var errorList;
      try {
        var decodedData = jsonDecode(response.body);
        var errorListBad = decodedData['error'];
        errorList = ['$errorListBad'];
      } catch (e) {
        try {
          var decodedData = jsonDecode(response.body);
          var errorListBad = decodedData['error'];
          errorList = ['$errorListBad'];
        } catch (e) {
          errorList = List<String>.empty(growable: false);
        }
      }

      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList = errorList;
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }

  static Future<MyResponseModel<bool>> editBank(
      {String? token, String? name, String? bankName, String? iban}) async {
    Map data = {
      "bankHolder": name,
      "bank": bankName,
      "iban": iban,
    };

    var body = json.encode(data);
    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response =
        await http.post(Uri.parse(EventsAPIs.url + EndPoints.csBankChange),
            headers: {
              "Content-Type": "application/json",
              HttpHeaders.authorizationHeader: "$token",
              "compatibility": compatibility,
              "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
              "fbId": fcm.toString(),
              "appVersion": Constants.appVersion
            },
            body: body);
    print(response.request!.url);
    print('add bank ${response.statusCode}');
    print('add bank body ${response.body}');
    MyResponseModel myResponseModel = MyResponseModel<bool>();

    if (response.statusCode == 200 || response.statusCode == 201) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var errorList;
      try {
        var decodedData = jsonDecode(response.body);
        var errorListBad = decodedData['error'];
        errorList = ['$errorListBad'];
      } catch (e) {
        try {
          var decodedData = jsonDecode(response.body);
          var errorListBad = decodedData['error'];
          errorList = ['$errorListBad'];
        } catch (e) {
          errorList = List<String>.empty(growable: false);
        }
      }

      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList = errorList;
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }

  static Future<MyResponseModel<bool>> callCstSupport({
    String? token,
    String? msg,
  }) async {
    // OrdersDataModelMix.

    UserRepository userRepository = UserRepository();

    Map data = {
      "comment": msg,
    };
    var body = json.encode(data);

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    http.Response response =
        await http.post(Uri.parse(EventsAPIs.url + EndPoints.csCallMe),
            headers: {
              "Content-Type": "application/json",
              HttpHeaders.authorizationHeader: '$token',
              "compatibility": compatibility,
              "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
              "fbId": fcm.toString(),
              "appVersion": Constants.appVersion
            },
            body: body);
    print(response.request!.url);
    print('CallCstSupport ${response.statusCode}');
    print('CallCstSupport ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<bool>();

    if (response.statusCode == 201 || response.statusCode == 200) {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var errorList;
      try {
        var decodedData = jsonDecode(response.body);
        var errorListBad = decodedData['error'];
        errorList = ['$errorListBad'];
      } catch (e) {
        try {
          var decodedData = jsonDecode(response.body);
          var errorListBad = decodedData['error'];
          errorList = ['$errorListBad'];
        } catch (e) {
          errorList = List<String>.empty(growable: false);
        }
      }

      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = false;
      myResponseModel.errorsList = errorList;
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }

  static Future<MyResponseModel<TrackingList>> getTracking({String? id}) async {
    // OrdersDataModelMix.

    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();
    http.Response response = await http
        .get(Uri.parse(EventsAPIs.url + EndPoints.myTracks + "/$id"), headers: {
      "Content-Type": "application/json",
      "compatibility": compatibility,
      "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale,
      "fbId": fcm.toString(),
      "appVersion": Constants.appVersion
    });
    print(response.request!.url);
    print('GetTracking ${response.statusCode}');
    print('GetTracking ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<TrackingList>();
    TrackingList trackingList = TrackingList();
    var decodedData;
    myResponseModel.statusCode = response.statusCode;

    if (response.statusCode != 204) {
      decodedData = json.decode(response.body);
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        // final list = decodedData.map((data) => TrackingDataModel.fromJson(data)).toList();
        // var trackingList = list.cast<TrackingDataModel>();
        trackingList = TrackingList.fromJson(decodedData);
        myResponseModel.statusCode = response.statusCode;
        myResponseModel.responseData = trackingList;
        myResponseModel.errorsList = List<String>.empty(growable: false);
        return myResponseModel as FutureOr<MyResponseModel<TrackingList>>;
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = null;
        myResponseModel.errorsList = List<String>.empty(growable: false);
        return myResponseModel
            as FutureOr<MyResponseModel<TrackingList>>;
      }
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel
          as FutureOr<MyResponseModel<TrackingList>>;
    }
  }

  static Future<MyResponseModel<bool>> addOrderB2c({required List<OrdersDataModelMix> pickupList}) async {
    List encondeToJson(List<OrdersDataModelMix> list) {
      List jsonList = [];
      list.map((item) => jsonList.add(item.toJson())).toList();
      return jsonList;
    }
    print(pickupList.first.pickupTime);
    Map data = {
      "shipments": encondeToJson(pickupList),
    };

    UserRepository userRepository = UserRepository();

    String? locale = await userRepository.getLocale();
    String? fcm = await userRepository.getFcmToken();

    var body = json.encode(data);
    String? token = await userRepository.getAuthToken();


    http.Response response = await http.post(
        Uri.parse(EventsAPIs.url + EndPoints.addOrderB2c ),
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

    MyResponseModel myResponseModel = MyResponseModel<bool>();

    if (response.statusCode == 201 ||
        response.statusCode == 200) {


      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = true;
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
      myResponseModel.responseData = false;
      myResponseModel.errorsList = errorList;
    }
    return myResponseModel as FutureOr<MyResponseModel<bool>>;

  }

  // ignore: non_constant_identifier_names
  static Future<MyResponseModel<GeoCodingDataModel>> getGeoCoding({String? lat, String? long, String? token, String? lang}) async {
    GeoCodingDataModel geoCondingDataModel = GeoCodingDataModel();
    MyResponseModel myResponseModel = MyResponseModel<GeoCodingDataModel>();

    // String locale = await userRepository.getLocale();
    http.Response response = await http.get(
        Uri.parse(
            "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&language=$lang&key=AIzaSyC1-lZ66R1rfXxC3eNKtkNTUXQciEw3YK0"),
        headers: {
          "compatibility": compatibility,
        });

    print(response.request!.url);
    print('getGeoCoding ${response.statusCode}');
    print('getGeoCoding ${response.body}');

    if (response.statusCode == 200) {
      try {
        final decodedData = jsonDecode(response.body);
        geoCondingDataModel = GeoCodingDataModel.fromJson(decodedData);
      } catch (e) {
        myResponseModel.statusCode = 400;
        myResponseModel.responseData = geoCondingDataModel;
        myResponseModel.errorsList = List<String>.empty(growable: false);
      }
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = geoCondingDataModel;
      myResponseModel.errorsList = List<String>.empty(growable: false);
    } else {
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = geoCondingDataModel;
      myResponseModel.errorsList = List<String>.empty(growable: false);
    }

    return myResponseModel as FutureOr<MyResponseModel<GeoCodingDataModel>>;
  }

  static createDynamicLink(String id) async {
    Map data = {
      "dynamicLinkInfo": {
        "domainUriPrefix": "https://xturbox.page.link",
        "link": "https://xturbox.com/tracking/?tracking_number=$id",
        "androidInfo": {"androidPackageName": "com.xturbox.xturbox"},
        "iosInfo": {"iosBundleId": "com.xturbo.xturbox"}
      }
    };

    var body = json.encode(data);

    http.Response response = await http.post(
        Uri.parse(
            "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=AIzaSyC1-lZ66R1rfXxC3eNKtkNTUXQciEw3YK0"),
        headers: {
          "Content-Type": "application/json",
        },
        body: body);

    print("create Dynamic link status code ${response.statusCode}");
    print("create Dynamic link response ${response.body}");
  }

  static Future<MyResponseModel<bool>> transferRequest({required String value}) async {

    Map data = {"amount": value};
    var body = json.encode(data);

    UserRepository userRepository = UserRepository();
    String? token = await userRepository.getAuthToken();
    http.Response response = await http.post(Uri.parse(EventsAPIs.url + EndPoints.transferRequest),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: token.toString(),
          "ACCEPT-LANGUAGE": Constants.currentLocale,
          "appVersion": Constants.appVersion
        },
        body: body);
    print(response.request!.url);
    print('transferToWallet ${response.statusCode}');
    print('transferToWallet  ${response.body}');

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
      myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    }
  }
  static Future<MyResponseModel<List<dynamic>>> transferConfirm({required String value,required String code}) async {

    Map data = {"amount": value, "code": code};
    var body = json.encode(data);
    await Future.delayed(Duration(seconds: 4));
    UserRepository userRepository = UserRepository();
    String? token = await userRepository.getAuthToken();
    http.Response response = await http.post(Uri.parse(EventsAPIs.url + EndPoints.transferConfirm),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: token.toString(),
          "ACCEPT-LANGUAGE": Constants.currentLocale,
          "appVersion": Constants.appVersion
        },
        body: body);
    print(response.request!.url);
    print('transferToWallet ${response.statusCode}');
    print('transferToWallet  ${response.body}');

    MyResponseModel myResponseModel = MyResponseModel<List<dynamic>>();

    if (response.statusCode == 201 || response.statusCode == 204 || response.statusCode == 200 ) {
      myResponseModel.statusCode = response.statusCode;
      List<double> list = [] ;
      var decodedData = jsonDecode(response.body);
      try{
        var doubleBalance = double.parse(decodedData['balance'].toString()) ;
        var doubleWallet = double.parse(decodedData['wallet'].toString()) ;
        list.insert(0, doubleBalance);
        list.insert(1, doubleWallet);
        myResponseModel.responseData = list;

      }catch(e){
        print(e);
        myResponseModel.responseData = [];
        print("catch balance wallet");
      }



      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<List<dynamic>>>;
    } else {
      var decodedData;
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.statusCode = response.statusCode;
      myResponseModel.responseData = [];
      myResponseModel.errorsList = GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<List<dynamic>>>;
    }
  }

}


