import 'package:flutter/foundation.dart';

class ErrorViewModel{

  String? errorMessage ;

  @override
  String toString() {
    return 'ErrorViewModel{errorMessage: $errorMessage, errorCode: $errorCode}';
  }

  int errorCode ;

  ErrorViewModel({required this.errorCode , required this.errorMessage});



}