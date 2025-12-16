import 'ErrorViewModel.dart';

class MyResponseModel<T> {
  T? responseData;

  List<String>? errorsList;

  int? statusCode;

  MyResponseModel({this.responseData, this.errorsList, this.statusCode});

  @override
  String toString() {
    return 'ResponseViewModel{responseData: $responseData, statusCode: ${statusCode.toString()}, errorsList: $errorsList}';
  }

}