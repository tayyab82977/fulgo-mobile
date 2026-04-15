import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/PaymentsAndProfile.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class ClientPaymentsController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var errorList = <dynamic>[].obs;
  var paymentsAndProfile = Rxn<PaymentsAndProfile>();

  Future<void> getClientPayments() async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    errorList.clear();

    try {
      PaymentsAndProfile currentData = PaymentsAndProfile();
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.GetMyPayments(token: token);

      if (response.statusCode == 200 || response.statusCode == 204) {
        currentData.clientPaymentsDataList = response.responseData;
        
        // Fetch dashboard data as well, as done in Bloc
        MyResponseModel profileResponse = await EventsAPIs.FetchDashBoardData(token: token);
         if (profileResponse.statusCode == 200) {
            if (profileResponse.responseData.permission == '1' || profileResponse.responseData.permission == '11') {
              userRepository.persistName(name: profileResponse.responseData.name);
              UserRepository.name = profileResponse.responseData.name;
              currentData.dashboardDataModel = profileResponse.responseData;
              paymentsAndProfile.value = currentData;
            } else {
               errorMessage.value = 'error';
            }
         } else {
            errorMessage.value = 'error';
         }

      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => getClientPayments());
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
