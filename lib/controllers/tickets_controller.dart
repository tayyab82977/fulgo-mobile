import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/data_providers/models/tickets_model.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class TicketsController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var successPost = false.obs;
  var errorMessage = ''.obs;
  var errorList = <dynamic>[].obs;
  var ticketsList = <TicketsModel>[].obs;

  Future<void> getTickets() async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    errorList.clear();

    try {
      String token = await userRepository.getAuthToken() ?? SavedData.token;
      MyResponseModel response = await EventsAPIs.getTickets(token: token);

      if (response.statusCode == 200 && response.responseData != null) {
        ticketsList.value = response.responseData;
      } else if (response.statusCode == 204) {
        ticketsList.clear();
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => getTickets());
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

  Future<void> postTicket({
    required String subject,
    required String description,
    required String cat,
    required String shipmentId,
  }) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    successPost.value = false;
    errorList.clear();

    try {
      String token = await userRepository.getAuthToken() ?? SavedData.token;
      MyResponseModel response = await EventsAPIs.postNewTicket(
          shipment: shipmentId,
          subject: subject,
          description: description,
          cat: cat,
          token: token
      );

      if (response.responseData == true) {
        successPost.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => postTicket(
            subject: subject, description: description, cat: cat, shipmentId: shipmentId));
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
