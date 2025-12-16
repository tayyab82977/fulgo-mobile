import 'dart:convert';
import 'dart:io';


import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xturbox/data_providers/models/ErrorViewModel.dart';
import 'package:xturbox/data_providers/models/ResponseViewModel.dart';

import 'Constants.dart';
import 'LocalKeys.dart';

class NetworkUtilities {
  static Future<bool> isConnected() async {
    // try {
    //   final result = await InternetAddress.lookup('google.com');
    //   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    //     return true;
    //   }
    // } on SocketException catch (_) {
    //   return false;
    // }
    return true;
  }


  static Map<String, String?> getHeaders({Map<String, String>? customHeaders}) {
    Map<String, String?> headers = {
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };
    if (customHeaders != null) {
      for (int i = 0; i < customHeaders.length; i++) {
        headers.putIfAbsent(customHeaders.keys.toList()[i],
            () => customHeaders[customHeaders.keys.toList()[i]]);
      }
    }
    return headers;
  }

  static void networkLogger({url, headers, body, ResponseViewModel? response}) {
    debugPrint('---------------------------------------------------');
    debugPrint('URL => $url');
    debugPrint('headers => $headers');
    debugPrint('Body => $body');
    debugPrint('Response => ${response.toString()}');
    debugPrint('---------------------------------------------------');
  }

  static ResponseViewModel handleError(http.Response serverResponse) {
    print("Server response not ok =>");
    print(serverResponse.body);
    print("---------------------------------------------------------------------");
    ResponseViewModel responseViewModel;

    if (serverResponse.statusCode == 404 || serverResponse.statusCode == 500) {
      responseViewModel = ResponseViewModel(
        isSuccess: false,
        errorViewModel: ErrorViewModel(
          errorMessage: (LocalKeys.SERVER_UNREACHABLE),
          errorCode: serverResponse.statusCode,
        ),
        responseData: null,
      );
    }
    else if (serverResponse.statusCode == 422) {
      List<String> errors =[];
      try {
        (json.decode(serverResponse.body)['errors'] as Map<String, dynamic>)
            .forEach((key, value) {
          if (value is List<String>)
            errors.addAll(value);
          else if (value is List<dynamic>) {
            for (int i = 0; i < value.length; i++)
              errors.add(value[i].toString());
          } else if (value is String) errors.add(value);
        });
      } catch (exception) {
        print("Exception => $exception");
      }
      responseViewModel = ResponseViewModel(
        isSuccess: false,
        errorViewModel: ErrorViewModel(
          errorMessage: errors.length > 0
              ? errors.join(',')
              : (LocalKeys.SERVER_UNREACHABLE),
          errorCode: serverResponse.statusCode,
        ),
        responseData: null,
      );
    } else {
      debugPrint("Server Response not OK => ${serverResponse.body}");
      String? serverError = "";
      try {
        serverError = json.decode(serverResponse.body)['error'] ?? json.decode(serverResponse.body)['message'];
      } catch (exception) {
        serverError = serverResponse.body;
      }
      responseViewModel = ResponseViewModel(
        isSuccess: false,
        errorViewModel: ErrorViewModel(
          errorMessage: serverError,
          errorCode: serverResponse.statusCode,
        ),
        responseData: null,
      );
    }

    return responseViewModel;
  }
}
