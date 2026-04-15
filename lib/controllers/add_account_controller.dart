import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/data_providers/models/userModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class AddAccountController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var success = false.obs;
  var errorsList = <dynamic>[].obs;

  Future<void> addAccount(String phone, String password) async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    success.value = false;

    try {
      MyResponseModel response = await UserRepository.LoginAPI(username: phone, password: password);

      if (response.statusCode == 200 || response.statusCode == 201) {
        authController.login(response.responseData);
        SavedData.accountsList.add(UserModel(phone: phone, password: password, token: SavedData.token, name: "", selected: "1"));
        await userRepository.persistPhone(username: phone);
        await userRepository.persistPassword(password: password);

        UserModel.saveAccount(SavedData.accountsList);
        success.value = true;
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
}
