import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/data_providers/models/tickets_model.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class TicketHistoryController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var errorList = <dynamic>[].obs;
  var ticketHistoryList = <TicketsHistoryModel>[].obs;

  Future<void> getTicketHistory({required String ticketId}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    errorList.clear();

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.getTicketsHistory(
        token: token,
        ticketId: ticketId
      );

      if (response.statusCode == 200) {
        if(response.responseData != null) {
           ticketHistoryList.value = response.responseData;
        }
      } else if (response.statusCode == 204) {
        ticketHistoryList.clear();
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => getTicketHistory(ticketId: ticketId));
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
