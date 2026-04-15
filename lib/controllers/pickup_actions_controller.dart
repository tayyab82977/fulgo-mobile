import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/apis/EventsApiCaptian.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/callLogModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class PickupActionsController extends GetxController {
  final UserRepository userRepository = UserRepository();
  
  var loadingId = ''.obs;
  var errorMessage = ''.obs;
  var errorsList = <String>[].obs;
  var actionSuccess = false.obs;
  var receipt = Rxn<dynamic>();
  var msgSentSuccess = false.obs;
  var noCallNoCancel = false.obs;

  Future<void> deliverShipment({
    required String id,
    required String amount,
    required String paymentMethodId,
    required String code,
    required String receipt,
  }) async {
    await _performAction(id, () => EventsApiCaptain.captainDeliverShipment(
      token: null,
      id: id,
      amount: amount,
      paymentMethodId: paymentMethodId,
      code: code,
      receipt: receipt,
    ));
  }

  Future<void> storeOutShipment(String id) async {
    await _performAction(id, () => EventsApiCaptain.captainStoreOutShipment(token: null, id: id));
  }

  Future<void> reActiveShipment(OrdersDataModelMix shipment) async {
    await _performAction(shipment.id!, () => EventsApiCaptain.captainReActiveShipment(token: null, id: shipment.id));
  }

  Future<void> dispatchIssueShipment(String id) async {
    await _performAction(id, () => EventsApiCaptain.captainDispatchShipment(token: null, id: id));
  }

  Future<void> cancelShipment(OrdersDataModelMix shipment, String? cancelId) async {
    List<CallLogModel> logHistory = [];
    await _performAction(shipment.id!, () => EventsApiCaptain.captainCancelShipment(
      token: null,
      id: shipment.id,
      cancelId: cancelId,
      logHistory: logHistory,
    ));
  }

  Future<void> rejectShipment(String id, String reason) async {
    await _performAction(id, () => EventsApiCaptain.captainRejectShipment(token: null, id: id, reason: reason));
  }

  Future<void> rescheduleShipment(String id, String reason) async {
    await _performAction(id, () => EventsApiCaptain.captainRescheduleShipment(token: null, id: id, reason: reason));
  }

  Future<void> lostShipment(String id) async {
    await _performAction(id, () => EventsApiCaptain.captainLostShipment(token: null, id: id));
  }

  Future<void> damagedShipment(String id) async {
    await _performAction(id, () => EventsApiCaptain.captainDamagedShipment(token: null, id: id));
  }

  Future<void> postponeShipment(OrdersDataModelMix shipment, String reason, String date) async {
    List<CallLogModel> logHistory = [];
    await _performAction(shipment.id!, () => EventsApiCaptain.captainPostponeShipment(
      token: null,
      id: shipment.id,
      reason: reason,
      date: date,
      logHistory: logHistory,
    ));
  }

  Future<void> getReceipt(String storeId, String method) async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    loadingId.value = storeId;
    errorMessage.value = '';

    try {
      MyResponseModel response = await EventsApiCaptain.getReceipt(storeId: storeId, paymentMethod: method);
      if (response.statusCode == 200 || response.statusCode == 201) {
        receipt.value = response.responseData;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => getReceipt(storeId, method));
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

  Future<void> sendConfirmationMsg(String receiverId, String receiverPhone, String msgType) async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    loadingId.value = receiverId;
    errorMessage.value = '';
    msgSentSuccess.value = false;

    try {
      MyResponseModel response = await EventsApiCaptain.setMsgType(
        receiverId: receiverId,
        receiverPhone: receiverPhone,
        msgType: msgType,
      );
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        msgSentSuccess.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => sendConfirmationMsg(receiverId, receiverPhone, msgType));
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

  Future<void> _performAction(String id, Future<MyResponseModel> Function() apiCall) async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    loadingId.value = id;
    errorMessage.value = '';
    actionSuccess.value = false;
    noCallNoCancel.value = false;

    try {
      MyResponseModel response = await apiCall();
      if (response.responseData == true) {
        actionSuccess.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => _performAction(id, apiCall));
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
      errorMessage.value = 'general';
    }
  }
}
