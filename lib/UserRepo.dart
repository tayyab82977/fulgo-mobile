import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/data_providers/models/seversListModerl.dart';
import 'package:Fulgox/data_providers/models/signUpData.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/GeneralHandling.dart';
import 'package:Fulgox/utilities/endPoints.dart';

import 'data_providers/models/MyResponseModel.dart';

class UserRepository {
  static const compatibility = EventsAPIs.compatibility;

  static String? name;

  late SharedPreferences preferences;

  static Future<MyResponseModel<bool>> registerFunction(
      {required String name,
      required String password,
      required String phone,
      required String firstName,
      required String lastName,
      required String nationalId,
      required String companyName,
      required String vatNumber}) async {
    String? locale = await userRepository.getLocale();
    Map data = {
      "name": name,
      "first_name": firstName,
      "second_name": lastName,
      "password": password,
      "passConf": password,
      "phone": phone,
      "national_id": nationalId,
      "vat": vatNumber,
      "company": companyName,
    };
    var body = json.encode(data);

    http.Response response =
        await http.post(Uri.parse(EventsAPIs.url + "register"),
            headers: {
              "Content-Type": "application/json",
              "compatibility": compatibility,
              "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale
            },
            body: body);
    print(response.request!.url);
    print('signUp process ${response.body}');
    print('signUp process ${response.statusCode}');

    MyResponseModel myResponseModel = MyResponseModel<bool>();

    myResponseModel.statusCode = response.statusCode;

    if (response.statusCode == 201 || response.statusCode == 200) {
      myResponseModel.errorsList = List<String>.empty(growable: false);
      myResponseModel.responseData = true;
      return myResponseModel as FutureOr<MyResponseModel<bool>>;
    } else {
      var decodedData = jsonDecode(response.body);
      myResponseModel.responseData = false;
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);

      return myResponseModel as FutureOr<MyResponseModel<bool>>;
      //
    }
  }

  static Future<MyResponseModel<String>> LoginAPI({
    required String? username,
    required String? password,
  }) async {
    MyResponseModel myResponseModel = MyResponseModel<String>();

    Map data = {'phone': username, 'password': password};
    print('username for login ${username}');
    print('password for login ${password}');
    var body = json.encode(data);
    String? locale = await userRepository.getLocale();

    http.Response response =
        await http.post(Uri.parse(EventsAPIs.url + "login"),
            headers: {
              "Content-Type": "application/json",
              "compatibility": compatibility,
              "ACCEPT-LANGUAGE": locale ?? Constants.currentLocale
            },
            body: body);
    print(response.request!.url);
    print('log in response ${response.statusCode}');
    print('log in response ${response.body}');
    myResponseModel.statusCode = response.statusCode;
    var decodedData;
    if (response.statusCode == 201 || response.statusCode == 200 || response.statusCode == 505) {
      myResponseModel.statusCode = 200; // Force 200
      print('log in username $username');
      print('log in password $password');
      print('log in response ${response.body}');

      decodedData = jsonDecode(response.body);
      // String? permissionCheck = decodedData['permission'];
      // if(permissionCheck != 1 && permissionCheck != 4){
      //   myResponseModel.statusCode = 400 ;
      // }
      String? adminToken = decodedData['token'];
      myResponseModel.responseData = adminToken;
      myResponseModel.errorsList = List<String>.empty(growable: false);
      return myResponseModel as FutureOr<MyResponseModel<String>>;
    } else {
      try {
        decodedData = jsonDecode(response.body);
      } catch (e) {}
      myResponseModel.responseData = '';
      myResponseModel.errorsList =
          GeneralHandler.handleErrorsFromApi(decodedData);
      return myResponseModel as FutureOr<MyResponseModel<String>>;
    }
  }

  Future<void> deleteToken() async {
    preferences = await SharedPreferences.getInstance();
    preferences.clear();
    preferences.remove('token');
    preferences.remove('username');
    preferences.remove('password');
    preferences.remove('name');
    preferences.remove('phone');
    preferences.remove('serverName');
    preferences.remove('update');
    preferences.remove('savedVersion');
    preferences.remove('workingMobile');
    preferences.remove('accountsList');
    SavedData.accountsList.clear();
    SavedData.token = "";

    return;
  }

  Future<void> persistToken({required String token}) async {
    preferences = await SharedPreferences.getInstance();
    String bToken = "bearer " + token;
    preferences.setString('token', bToken);

    /// write to keystore/keychain
    return;
  }

  Future<void> persistLocale({required String locale}) async {
    preferences = await SharedPreferences.getInstance();
    preferences.setString('locale', locale);

    /// write to keystore/keychain
    return;
  }

  Future<void> persistUser({required Map<String, dynamic> userData}) async {
    preferences = await SharedPreferences.getInstance();
    final ProfileDataModel user = ProfileDataModel.fromJson(userData);
    preferences.setString('userData', jsonEncode(user));

    /// write to keystore/keychain
    return;
  }

  Future<void> persistEmail({required String email}) async {
    preferences = await SharedPreferences.getInstance();
    preferences.setString('email', email);

    /// write to keystore/keychain
    return;
  }

  Future<void> persistServerName({required String serverName}) async {
    preferences = await SharedPreferences.getInstance();
    preferences.setString('serverName', serverName);

    /// write to keystore/keychain
    return;
  }

  Future<void> persistNotificationToken({required String fcmToken}) async {
    preferences = await SharedPreferences.getInstance();
    preferences.setString('fcmToken', fcmToken);

    /// write to keystore/keychain
    return;
  }

  Future<void> persistName({required String name}) async {
    preferences = await SharedPreferences.getInstance();
    preferences.setString('name', name);

    /// write to keystore/keychain
    return;
  }

  Future<void> persistPhone({required String username}) async {
    preferences = await SharedPreferences.getInstance();
    print('I am now persisting the username');
    preferences.setString('phone', username);

    /// write to keystore/keychain
    return;
  }

  Future<void> persistPassword({required String password}) async {
    preferences = await SharedPreferences.getInstance();
    preferences.setString('password', password);

    /// write to keystore/keychain
    return;
  }

  Future<void> persistSavedVersion({required String savedVersion}) async {
    preferences = await SharedPreferences.getInstance();
    preferences.setString('savedVersion', savedVersion);

    /// write to keystore/keychain
    return;
  }

  Future<bool> hasToken() async {
    preferences = await SharedPreferences.getInstance();
    String? autoToken = preferences.getString('token');
    name = await getAuthName();

    print('the name test $name');

    /// read from keystore/keychain
    if (autoToken == null) {
      return false;
    } else
      return true;
  }

  Future<bool> hasUsername() async {
    preferences = await SharedPreferences.getInstance();
    String? autoToken = preferences.getString('username');

    /// read from keystore/keychain
    if (autoToken == null) {
      return false;
    } else
      return true;
  }

  Future<bool> checkNewUpdate() async {
    preferences = await SharedPreferences.getInstance();
    String? autoToken = preferences.getString('update');

    /// read from keystore/keychain
    print("saved new update value $autoToken");
    if (autoToken == "false") {
      return true;
    } else
      return false;
  }

  Future<String?> getAuthToken() async {
    preferences = await SharedPreferences.getInstance();
    String? authToken;
    authToken = preferences.getString('token') ?? null;
    return authToken;
  }

  Future<String?> getSavedVersion() async {
    preferences = await SharedPreferences.getInstance();
    String? savedVersion;
    savedVersion = preferences.getString('savedVersion') ?? null;
    print("the saved savedVersion $savedVersion");
    return savedVersion;
  }

  Future<String?> getFcmToken() async {
    preferences = await SharedPreferences.getInstance();
    String? fcmToken;
    fcmToken = preferences.getString('fcmToken');
    return fcmToken;
  }

  Future<String?> getLocale() async {
    preferences = await SharedPreferences.getInstance();
    String? authToken;
    authToken = preferences.getString('locale') ?? null;
    return authToken;
  }

  Future<Null> getUserData({ProfileDataModel? dashboardDataModel}) async {
    preferences = await SharedPreferences.getInstance();
    Map<String, dynamic>? userMap;
    final String? userStr = preferences.getString('userData');
    if (userStr != null) {
      userMap = jsonDecode(userStr) as Map<String, dynamic>?;
    }
    if (userMap != null) {
      final ProfileDataModel userData = ProfileDataModel.fromJson(userMap);
      dashboardDataModel = userData;
    }
  }

  Future<String> getAuthPhone() async {
    preferences = await SharedPreferences.getInstance();
    String phone;
    phone = preferences.getString('phone') ?? '';
    return phone;
  }

  Future<String> getAuthName() async {
    preferences = await SharedPreferences.getInstance();
    String username;
    username = preferences.getString('name') ?? '';
    return username;
  }

  Future<String> getServerName() async {
    preferences = await SharedPreferences.getInstance();
    String serverName;
    serverName = preferences.getString('serverName') ?? '';
    return serverName;
  }

  Future<String> getAuthPassword() async {
    preferences = await SharedPreferences.getInstance();
    String password;
    password = preferences.getString('password') ?? '';
    return password;
  }

  Future<void> save(String value) async {
    preferences = await SharedPreferences.getInstance();
    preferences.setString('list', value);
  }

  Future<String> getWorkingMobile() async {
    preferences = await SharedPreferences.getInstance();
    String mobile;
    mobile = preferences.getString('workingMobile') ?? '';
    if (mobile.length > 9) {
      String noCountryCodeMobile = mobile.substring(4);
      return noCountryCodeMobile;
    }
    return mobile;
  }

  Future<void> persistWorkingMobile({required String mobile}) async {
    preferences = await SharedPreferences.getInstance();
    preferences.setString('workingMobile', mobile);
    return;
  }

  Future<bool> workingMobileSaved() async {
    preferences = await SharedPreferences.getInstance();
    String? mobile = preferences.getString('workingMobile');
    if (mobile == null || mobile == "") {
      return false;
    } else
      return true;
  }
}
