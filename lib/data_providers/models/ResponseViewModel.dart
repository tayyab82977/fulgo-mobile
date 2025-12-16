
import 'ErrorViewModel.dart';

class ResponseViewModel<T> {
  T? responseData ;
  ErrorViewModel? errorViewModel ;
  bool? isSuccess ;
  ResponseViewModel({this.responseData , this.errorViewModel , this.isSuccess});

  @override
  String toString() {
    return 'ResponseViewModel{responseData: $responseData, errorViewModel: ${errorViewModel.toString()}, isSuccess: $isSuccess}';
  }
}