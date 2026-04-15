import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/data_providers/models/userModel.dart';
import 'package:Fulgox/utilities/Constants.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading, error }

class AuthController extends GetxController {
  final UserRepository userRepository = UserRepository();
  
  var status = AuthStatus.uninitialized.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAppStatus();
  }

  Future<void> checkAppStatus() async {
    status.value = AuthStatus.loading;
    final bool hasToken = await userRepository.hasToken();

    if (hasToken) {
      String phone = await userRepository.getAuthPhone();
      String password = await userRepository.getAuthPassword();
      UserRepository.name = await userRepository.getAuthName();
      Constants.savedVersion = await userRepository.getSavedVersion();

      if (Constants.savedVersion == null) {
        Constants.savedVersion = Constants.appVersion;
      }

      bool isUserConnected = await NetworkUtilities.isConnected();
      if (!isUserConnected) {
        status.value = AuthStatus.error;
        errorMessage.value = 'TIMEOUT';
        return;
      }

      try {
        MyResponseModel response = await UserRepository.LoginAPI(
            username: phone,
            password: password
        );

        if (response.responseData != null && (response.statusCode == 200 || response.statusCode == 201)) {
          await userRepository.persistToken(token: response.responseData);
          SavedData.token = "Bearer " + response.responseData;

          bool checkSavedAccount = await UserModel.checkSavedAccounts();
          if (checkSavedAccount) {
            SavedData.accountsList = await UserModel.getSavedAccounts();
          } else {
            SavedData.accountsList = [
              UserModel(name: "", phone: phone, password: password, token: SavedData.token, selected: "1")
            ];
          }
          UserModel.saveAccount(SavedData.accountsList);
          status.value = AuthStatus.authenticated;
        } else {
          status.value = AuthStatus.unauthenticated;
        }
      } catch (e) {
        status.value = AuthStatus.error;
        errorMessage.value = e.toString();
      }
    } else {
      Constants.savedVersion = Constants.appVersion;
      status.value = AuthStatus.unauthenticated;
    }
  }

  Future<void> login(String token) async {
    status.value = AuthStatus.loading;
    await userRepository.persistToken(token: token);
    SavedData.token = "Bearer " + token;
    status.value = AuthStatus.authenticated;
  }

  Future<void> logout() async {
    status.value = AuthStatus.loading;
    await userRepository.deleteToken();
    SavedData.token = "";
    status.value = AuthStatus.unauthenticated;
  }
}
