import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/data_providers/models/userModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class LoginController extends GetxController {
  final UserRepository userRepository = UserRepository();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var loginSuccess = false.obs;

  Future<void> login({required String phone, required String password}) async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (isUserConnected == false) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    loginSuccess.value = false;

    try {
      final MyResponseModel myResponseModel = await UserRepository.LoginAPI(
        username: phone,
        password: password,
      );

      if (myResponseModel.responseData != null &&
          (myResponseModel.statusCode == 201 ||
              myResponseModel.statusCode == 200)) {
        // Still interacting with AuthenticationBloc as it's not migrated yet

        await userRepository.persistPhone(username: phone);
        await userRepository.persistPassword(password: password);

        SavedData.token = "Bearer " + myResponseModel.responseData;
        bool checkSavedAccount = await UserModel.checkSavedAccounts();
        if (checkSavedAccount) {
          SavedData.accountsList = await UserModel.getSavedAccounts();
        }

        UserModel newAccount = UserModel(
            phone: phone,
            password: password,
            token: SavedData.token,
            name: "",
            selected: "1");

        if (!SavedData.accountsList.contains(newAccount)) {
          SavedData.accountsList.add(newAccount);
        }
        UserModel.saveAccount(SavedData.accountsList);

        isLoading.value = false;
        loginSuccess.value = true;
      } else if (myResponseModel.statusCode == 403) {
        isLoading.value = false;
        errorMessage.value = "error2";
      } else {
        isLoading.value = false;
        errorMessage.value = 'please check your email and password';
      }
    } catch (e) {
      print('Login error: $e');
      isLoading.value = false;
      errorMessage.value = 'An error occurred. Please try again.';
    }
  }

  void reset() {
    isLoading.value = false;
    errorMessage.value = '';
    loginSuccess.value = false;
  }
}
