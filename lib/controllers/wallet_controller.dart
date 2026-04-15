import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class WalletController extends GetxController {
  final UserRepository userRepository = UserRepository();
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var requestSuccess = false.obs;
  var transferSuccess = false.obs;
  var balanceWallet = Rxn<List<dynamic>>();
  var errorsList = <dynamic>[].obs;

  Future<void> transferRequest(String value) async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    requestSuccess.value = false;

    try {
      MyResponseModel response = await EventsAPIs.transferRequest(value: value);

      if (response.statusCode == 200 || response.statusCode == 201) {
        requestSuccess.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => transferRequest(value));
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

  Future<void> transferConfirm(String code, String value) async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    transferSuccess.value = false;

    try {
      MyResponseModel response = await EventsAPIs.transferConfirm(code: code, value: value);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (SavedData.profileDataModel != null) {
          SavedData.profileDataModel!.amount = response.responseData?[0] ?? SavedData.profileDataModel!.amount;
          SavedData.profileDataModel!.wallet = response.responseData?[1] ?? SavedData.profileDataModel!.wallet;
        }
        balanceWallet.value = response.responseData;
        transferSuccess.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => transferConfirm(code, value));
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
