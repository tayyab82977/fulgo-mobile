import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class ResetPasswordController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var codeSent = false.obs;
  var passwordChanged = false.obs;
  var passwordSemiChanged = false.obs;
  var errorMessage = ''.obs;
  var errorList = <dynamic>[].obs;

  Future<void> getCode({required String phone}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    errorList.clear();
    codeSent.value = false;

    try {
      MyResponseModel response = await EventsAPIs.getCode(phone: phone);
      if (response.responseData == true) {
        codeSent.value = true;
      } else {
        errorMessage.value = 'codeNotSent';
        errorList.value = response.errorsList ?? [];
      }
    } catch (e) {
      errorMessage.value = 'exception';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeMyPassword({
    required String phone,
    required String password,
    required String code,
  }) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    passwordChanged.value = false;
    passwordSemiChanged.value = false;
    errorList.clear();

    try {
      MyResponseModel response = await EventsAPIs.changePassword(
        phone: phone,
        password: password,
        code: code,
      );

      if (response.responseData == true) {
        await userRepository.persistPhone(username: phone);
        await userRepository.persistPassword(password: password);

        final MyResponseModel loginResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
        );

        if (loginResponse.responseData != null && 
           (loginResponse.statusCode == 201 || loginResponse.statusCode == 200)) {
           
           await userRepository.persistToken(token: loginResponse.responseData);
           SavedData.token = "Bearer " + loginResponse.responseData.toString();
           authController.login(loginResponse.responseData);
           
           passwordChanged.value = true;
        } else {
             // Semi-changed state
             passwordSemiChanged.value = true; 
        }
      } else {
        errorMessage.value = 'noChangePass';
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
}
