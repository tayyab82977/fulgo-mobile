import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class PhoneConfirmController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var codeSendingSuccess = false.obs;
  var success = false.obs;

  Future<void> askForSMS({
    String? phone,
    String? name,
    String? password,
    String? firstName,
    String? lastName,
    String? companyName,
    String? vatNumber,
    String? nationalId,
  }) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    codeSendingSuccess.value = false;

    try {
      int responseCode = await EventsAPIs.askForSMS(
          name: name,
          nationalId: nationalId,
          password: password,
          lastName: lastName,
          firstName: firstName,
          companyName: companyName,
          vatNumber: vatNumber,
          phone: phone);
      
      if (responseCode == 201) {
        codeSendingSuccess.value = true;
      } else {
        errorMessage.value = 'codeSendingError';
      }
    } catch (e) {
      errorMessage.value = 'exception';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> codeConfirmation({required String phone, required String code}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    success.value = false;

    try {
      MyResponseModel response = await EventsAPIs.CodeConfirmation(phone: phone, code: code);

      if (response.responseData == true) {
        // Automatically login after confirmation logic from Bloc
        await _performLoginAfterConfirmation(phone);
      } else if (response.statusCode == 403) {
        errorMessage.value = 'error2';
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
      }
    } catch (e) {
      errorMessage.value = 'exception';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _performLoginAfterConfirmation(String phone) async {
      // In BLoC it fetched password from persisted storage?? 
      // "String password = await userRepository.getAuthPassword();"
      // But we just registered/confirmed, so we might have the password stored or need to get it from somewhere.
      // The BLoC assumes it is stored.
      String password = await userRepository.getAuthPassword();

      final MyResponseModel tokenResponse = await UserRepository.LoginAPI(
          username: phone,
          password: password,
      );

      if (tokenResponse.responseData != null && 
          (tokenResponse.statusCode == 201 || tokenResponse.statusCode == 200)) {
            await userRepository.persistToken(token: tokenResponse.responseData);
            await userRepository.persistPhone(username: phone);
            await userRepository.persistPassword(password: password);
            authController.login(tokenResponse.responseData);
            success.value = true;
      } else {
         errorMessage.value = 'failedToLogin';
      }
  }

  void reset() {
    isLoading.value = false;
    errorMessage.value = '';
    codeSendingSuccess.value = false;
    success.value = false;
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
