import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class AddressController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var addressList = <Addresses>[].obs;
  var deleteSuccess = false.obs;
  var errorsList = <dynamic>[].obs;

  Future<void> getAddress() async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.FetchDashBoardData(token: token);

      if (response.statusCode == 200) {
        if (response.responseData.permission == '1' || response.responseData.permission == '11') {
          userRepository.persistName(name: response.responseData.name);
          UserRepository.name = response.responseData.name;
          SavedData.profileDataModel = response.responseData;
          addressList.value = response.responseData.addresses ?? [];
        }
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => getAddress());
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

  Future<void> deleteAddress(List<Addresses> list) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    deleteSuccess.value = false;

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.AddAddresses(
        token: token,
        list: list
      );

      if (response.responseData == true) {
        deleteSuccess.value = true;
        await getAddress(); // Refresh list after deletion
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => deleteAddress(list));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
        errorsList.value = response.errorsList ?? [];
      } else {
        errorMessage.value = 'error';
        errorsList.value = response.errorsList ?? [];
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
