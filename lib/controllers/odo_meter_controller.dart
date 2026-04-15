import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApiCaptian.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class OdoMeterController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var success = false.obs;
  var errorMessage = ''.obs;
  var errorList = <dynamic>[].obs;
  var meterResponse = Rxn<dynamic>();

  Future<void> setOdoMeterValue({required String type, required String value, String? id}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    success.value = false;
    errorList.clear();

    try {
      MyResponseModel response = await EventsApiCaptain.setMeterValue(type: type, value: value, id: id);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (SavedData.profileDataModel.meterYesterday?.end.toString() == "0") {
          SavedData.profileDataModel.meterYesterday = response.responseData;
        } else {
          SavedData.profileDataModel.meter = response.responseData;
        }
        meterResponse.value = response.responseData;
        success.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => setOdoMeterValue(type: type, value: value, id: id));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorList.value = response.errorsList ?? [];
      }
    } catch (e) {
      errorMessage.value = 'exception';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _checkConnectivity() async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return false;
    }
    return true;
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
        SavedData.token = "Bearer " + loginResponse.responseData;
        authController.login(loginResponse.responseData);
        await retryAction();
      } else {
        errorMessage.value = 'invalidToken';
      }
    } catch (e) {
      errorMessage.value = 'exception';
    }
  }
}
