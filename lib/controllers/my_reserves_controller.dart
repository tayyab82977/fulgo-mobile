import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/apis/EventsApiCaptian.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/captainOrdersDataModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class MyReservesController extends GetxController {
  final UserRepository userRepository = UserRepository();
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var reservesList = <OrdersDataModelMix>[].obs;

  Future<void> fetchMyReserves() async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsApiCaptain.getCaptainReserves(token: token);

      if (response.statusCode == 200 || response.statusCode == 204) {
        reservesList.assignAll(response.responseData ?? []);
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => fetchMyReserves());
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
      }
    } catch (e) {
      errorMessage.value = 'general';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleTokenRefresh(Function retryAction) async {
    String phone = await userRepository.getAuthPhone();
    String password = await userRepository.getAuthPassword();

    try {
      final MyResponseModel loginResponse = await UserRepository.LoginAPI(
        username: phone,
        password: password,
      );

      if (loginResponse.responseData != null && 
          (loginResponse.statusCode == 201 || loginResponse.statusCode == 200)) {
        
        await userRepository.persistToken(token: loginResponse.responseData);
        await retryAction();
      } else {
        errorMessage.value = 'invalidToken';
      }
    } catch (e) {
      errorMessage.value = 'general';
    }
  }
}
