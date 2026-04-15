import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class ClientCancelOrderController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var cancelSuccess = false.obs;
  var reverseSuccess = false.obs;
  var zeroActionSuccess = false.obs;
  var editSuccess = false.obs;
  var shipmentDetailPop = false.obs; // Mimicking 'ShipmentDetailPop' state
  var errorMessage = ''.obs;
  var errorList = <dynamic>[].obs;
  
  // For GetShipmentDetails
  var shipmentDetails = Rxn<OrdersDataModelMix>();


  Future<void> cancelMyOrder({required String id}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    cancelSuccess.value = false;
    errorList.clear();

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.CancelClientOrder(token: token, id: id);

      if (response.responseData == true) {
        cancelSuccess.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => cancelMyOrder(id: id));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorList.value = response.errorsList ?? [];
      }
    } catch (e) {
      errorMessage.value = 'exception';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reverseMyOrder({required OrdersDataModelMix ordersDataModelMix, String? shipmentId}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    reverseSuccess.value = false;
    errorList.clear();

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.reverseShipment(token: token, postOrder: ordersDataModelMix, shipmentId: shipmentId);

      if (response.responseData == true) {
        reverseSuccess.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => reverseMyOrder(ordersDataModelMix: ordersDataModelMix, shipmentId: shipmentId));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorList.value = response.errorsList ?? [];
      }
    } catch (e) {
      errorMessage.value = 'exception';
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
      MyResponseModel response = await EventsAPIs.ClientEditOrderCall(token: token, postOrder: ordersDataModelMix);

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
      errorMessage.value = 'exception';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getShipmentDetails({required String id}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    errorList.clear();
    shipmentDetailPop.value = false;

    try {
        String? token = await userRepository.getAuthToken();
        MyResponseModel response = await EventsAPIs.getShipmentDetails(token: token, id: id);
        
        if(response.statusCode == 200 || response.statusCode == 204){
            shipmentDetails.value = response.responseData;
        } else if (response.statusCode == 403) {
             // In BLoC for GetShipmentDetails in ClientCancelOrderBloc, it yields ShipmentDetailPop on token refresh?!
             // "yield ShipmentDetailPop(); yield* _handleGetShipmentDetails(event);"
             // This seems like it wants to pop the dialog/screen because of auth issue or just a side effect?
             // I'll set the flag.
             shipmentDetailPop.value = true;
             await _handleTokenRefresh(() => getShipmentDetails(id: id));
        } else if (response.statusCode == 505) {
            errorMessage.value = 'needUpdate';
        } else {
            errorMessage.value = 'error';
            errorList.value = response.errorsList ?? [];
        }

    } catch(e) {
        errorMessage.value = 'exception';
    } finally {
        isLoading.value = false;
    }
  }

  Future<void> zeroCod({String? shipmentId}) async {
       if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    zeroActionSuccess.value = false; // Using zeroActionSuccess for "ShipmentZeroActionSuccess"
    shipmentDetailPop.value = false;

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.clientZeroCod(token: token, id: shipmentId);

      if (response.statusCode == 200 || response.statusCode == 204) {
        zeroActionSuccess.value = true;
      } else if (response.statusCode == 403) {
        shipmentDetailPop.value = true;
        await _handleTokenRefresh(() => zeroCod(shipmentId: shipmentId));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorList.value = response.errorsList ?? [];
      }
    } catch (e) {
      errorMessage.value = 'exception';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> zeroRc({String? shipmentId}) async {
       if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    zeroActionSuccess.value = false;
    shipmentDetailPop.value = false;

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.clientZeroRC(token: token, id: shipmentId);

      if (response.statusCode == 200 || response.statusCode == 204) {
        zeroActionSuccess.value = true;
      } else if (response.statusCode == 403) {
        shipmentDetailPop.value = true;
        await _handleTokenRefresh(() => zeroRc(shipmentId: shipmentId));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorList.value = response.errorsList ?? [];
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
