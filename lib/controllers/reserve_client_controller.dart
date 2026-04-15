import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApiCaptian.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/captainOrdersDataModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class ReserveClientController extends GetxController {
  final UserRepository _userRepository = UserRepository();

  var loadingId = ''.obs;
  var reserveSuccess = false.obs;
  var cancelSuccess = false.obs;
  var recordPickupIssueSuccess = false.obs;
  var errorMessage = ''.obs;
  var errorsList = <String>[].obs;

  Future<void> reserveClient(String? id) async {
    loadingId.value = id ?? '';
    errorMessage.value = '';
    reserveSuccess.value = false;

    try {
      String? token = await _userRepository.getAuthToken();
      MyResponseModel response = await EventsApiCaptain.reserveClient(
          token: token, id: id
      );

      if (response.responseData == true) {
        reserveSuccess.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => reserveClient(id));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorsList.assignAll(response.errorsList ?? []);
      }
    } catch (e) {
      errorMessage.value = 'general';
    } finally {
      loadingId.value = '';
    }
  }

  Future<void> captainCancelClient(String? id) async {
    loadingId.value = id ?? '';
    errorMessage.value = '';
    cancelSuccess.value = false;

    try {
      String? token = await _userRepository.getAuthToken();
      MyResponseModel response = await EventsApiCaptain.captainCancelClient(
          token: token, id: id
      );

      if (response.responseData == true) {
        cancelSuccess.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => captainCancelClient(id));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorsList.assignAll(response.errorsList ?? []);
      }
    } catch (e) {
      errorMessage.value = 'general';
    } finally {
      loadingId.value = '';
    }
  }

  Future<void> recordPickupIssue(List<OrdersDataModelMix> orderList, String? reasonId) async {
    String? firstId = orderList.isNotEmpty ? orderList.first.member : '';
    loadingId.value = firstId ?? '';
    errorMessage.value = '';
    recordPickupIssueSuccess.value = false;

    try {
      MyResponseModel response = await EventsApiCaptain.pickupIssue(
          acceptedList: orderList,
          reasonId: reasonId
      );

      if (response.responseData == true) {
        recordPickupIssueSuccess.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => recordPickupIssue(orderList, reasonId));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorsList.assignAll(response.errorsList ?? []);
      }
    } catch (e) {
      errorMessage.value = 'general';
    } finally {
      loadingId.value = '';
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
    String phone = await _userRepository.getAuthPhone();
    String password = await _userRepository.getAuthPassword();

    try {
      final MyResponseModel loginResponse = await UserRepository.LoginAPI(
        username: phone,
        password: password,
      );

      if (loginResponse.responseData != null && 
          (loginResponse.statusCode == 201 || loginResponse.statusCode == 200)) {
        
        await _userRepository.persistToken(token: loginResponse.responseData);
        await retryAction();
      } else {
        errorMessage.value = 'invalidToken';
      }
    } catch (e) {
      errorMessage.value = 'general';
    }
  }
}
