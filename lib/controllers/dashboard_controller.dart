import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/data_providers/models/userModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class DashboardController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var noNationalId = false.obs;
  var errorMessage = ''.obs;
  var profileData = Rxn<ProfileDataModel>();

  @override
  void onInit() {
    super.onInit();
    getProfileData();
  }

  Future<void> getProfileData() async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    noNationalId.value = false;

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.FetchDashBoardData(
        token: token,
      );

      if (response.statusCode == 200) {
        SavedData.profileDataModel = response.responseData;
        if (response.responseData.permission == '1' ||
            response.responseData.permission == '11') {
          userRepository.persistName(name: response.responseData.name);
          UserRepository.name = response.responseData.name;

          if (response.responseData.national_id == null) {
            noNationalId.value = true;
            isLoading.value = false;
            return;
          }

          var account = SavedData.accountsList
              .firstWhereOrNull((element) => element.phone == response.responseData.phone);
          
          if(account != null){
             account.name = response.responseData.name;
          }

          UserModel.saveAccount(SavedData.accountsList);
          profileData.value = response.responseData;
        } else {
          errorMessage.value = 'invalidToken';
        }
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => getProfileData());
      } else {
        errorMessage.value = 'error';
      }
    } catch (e) {
      errorMessage.value = 'exception: $e';
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
