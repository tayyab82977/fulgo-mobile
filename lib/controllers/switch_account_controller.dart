import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class SwitchAccountController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var errorList = <dynamic>[].obs;
  var success = false.obs;


  Future<void> switchAccount({required String phone, required String password}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    success.value = false;
    errorList.clear();

    try {
      MyResponseModel response = await UserRepository.LoginAPI(username: phone, password: password);

      if (response.statusCode == 200 || response.statusCode == 201) {
        authController.login(response.responseData);
        await userRepository.persistPhone(username: phone);
        await userRepository.persistPassword(password: password);
        success.value = true;
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
}
