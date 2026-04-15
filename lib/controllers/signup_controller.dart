import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class SignupController extends GetxController {
  final UserRepository userRepository = UserRepository();
  
  var isLoading = false.obs;
  var errors = <String>[].obs;
  var signupSuccess = false.obs;
  var errorType = ''.obs;

  Future<void> register({
    required String phone,
    required String password,
    required String name,
    required String firstName,
    required String lastName,
    required String nationalId,
    required String vatNumber,
    required String companyName,
  }) async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      errors.value = ['please check your internet connection and try again'];
      return;
    }

    isLoading.value = true;
    errors.clear();
    signupSuccess.value = false;
    errorType.value = '';

    try {
      final MyResponseModel myResponseModel = await UserRepository.registerFunction(
        password: password,
        phone: phone,
        name: name,
        firstName: firstName,
        lastName: lastName,
        nationalId: nationalId,
        vatNumber: vatNumber,
        companyName: companyName,
      );

      if (myResponseModel.responseData && myResponseModel.statusCode == 201) {
        await userRepository.persistPhone(username: phone);
        await userRepository.persistPassword(password: password);
        await userRepository.persistName(name: name);

        isLoading.value = false;
        signupSuccess.value = true;
      } else if (myResponseModel.statusCode == 403) {
        isLoading.value = false;
        errorType.value = "errors";
      } else if (myResponseModel.statusCode == 505) {
        isLoading.value = false;
        errorType.value = "needUpdate";
      } else {
        isLoading.value = false;
        errors.value = List<String>.from(myResponseModel.errorsList ?? []);
        errorType.value = 'error';
      }
    } catch (e) {
      print('Registration error: $e');
      isLoading.value = false;
      errors.value = ['An error occurred. Please try again.'];
      errorType.value = 'exception';
    }
  }

  void reset() {
    isLoading.value = false;
    errors.clear();
    signupSuccess.value = false;
    errorType.value = '';
  }
}
