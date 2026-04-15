import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class NationalIdController extends GetxController {
  final UserRepository userRepository = UserRepository();
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var success = false.obs;
  var errorsList = <dynamic>[].obs;

  Future<void> setNationalId(String value) async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    success.value = false;

    try {
      MyResponseModel response = await EventsAPIs.EditProfile(national_id: value, onlyNational: true);

      if (response.statusCode == 200 || response.statusCode == 201) {
        success.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => setNationalId(value));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorsList.value = response.errorsList ?? [];
      }
    } catch (e) {
      errorMessage.value = e.toString();
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
      errorMessage.value = 'exception';
    }
  }
}
