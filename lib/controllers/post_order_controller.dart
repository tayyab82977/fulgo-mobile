import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/postOrderData.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class PostOrderController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var success = false.obs;
  var editSuccess = false.obs;
  var popLoading = false.obs;
  var errorMessage = ''.obs;
  var errorList = <dynamic>[].obs;

  Future<void> postNewOrder({required PostOrderDataModel postOrder}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    success.value = false;
    errorList.clear();

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.PostNewOrder(
        token: token,
        postOrder: postOrder,
      );

      if (response.responseData == true) {
        success.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => postNewOrder(postOrder: postOrder));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorList.value = response.errorsList ?? [];
      }
    } catch (e) {
      errorMessage.value = 'general';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addB2cOrder({required List<OrdersDataModelMix> ordersList}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    success.value = false;
    errorList.clear();

    try {
      MyResponseModel response = await EventsAPIs.addOrderB2c(pickupList: ordersList);

      if (response.responseData == true) {
        success.value = true;
      } else if (response.statusCode == 403) {
        popLoading.value = true; // Simulating yield PopLoading() from bloc
        await _handleTokenRefresh(() => addB2cOrder(ordersList: ordersList));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorList.value = response.errorsList ?? [];
      }
    } catch (e) {
      errorMessage.value = 'general';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editOrder({required OrdersDataModelMix ordersDataModelMix}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    editSuccess.value = false;
    errorList.clear();

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.ClientEditOrderCall(
        token: token,
        postOrder: ordersDataModelMix,
      );

      if (response.responseData == true) {
        editSuccess.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => editOrder(ordersDataModelMix: ordersDataModelMix));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorList.value = response.errorsList ?? [];
      }
    } catch (e) {
      errorMessage.value = 'general';
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
      errorMessage.value = 'general';
    }
  }
}
