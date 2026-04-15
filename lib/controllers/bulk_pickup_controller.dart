import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/apis/EventsApiCaptian.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/pickupReportModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

import 'package:Fulgox/data_providers/models/memberBalanceModel.dart';

class BulkPickupController extends GetxController {
  final UserRepository userRepository = UserRepository();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var errorsList = <String>[].obs;
  var actionSuccess = false.obs;
  var msgSentSuccess = false.obs;
  var receipt = Rxn<String>();
  var calculations = Rxn<List<String>>();
  var newShipment = Rxn<OrdersDataModelMix>();
  var pickupReport = Rxn<PickupReportModel>();
  var returnShipmentsSuccess = false.obs;
  var clientBalance = Rxn<ClientBalanceModel>();

  Future<void> bulkPickupThisList({
    required String memberId,
    required String amount,
    required String receipt,
    required List<OrdersDataModelMix>? list,
    required List<Credit>? creditList,
    required String paymentMethodId,
    required String? msgCodee,
  }) async {
    await _performAction(() async {
      String? token = await userRepository.getAuthToken();
      return await EventsApiCaptain.captainPickup(
        memberId: memberId,
        amount: amount,
        receipt: receipt,
        pickupList: list!,
        creditList: creditList,
        paymentMethodId: paymentMethodId,
        token: token,
        msgCode: msgCodee,
      );
    }, onSuccess: (response) {
      pickupReport.value = response.responseData;
      actionSuccess.value = true;
    });
  }

  Future<void> returnThisList({
    required String memberId,
    required String amount,
    required String receipt,
    required List<OrdersDataModelMix>? list,
    required String? paymentMethodId,
    required String? code,
  }) async {
    await _performAction(() async {
      String? token = await userRepository.getAuthToken();
      return await EventsApiCaptain.returnShipmentsToClient(
        memberId: memberId,
        amount: amount,
        receipt: receipt,
        pickupList: list ?? [],
        methodId: paymentMethodId ?? "",
        token: token,
        code: code ?? "",
      );
    }, onSuccess: (response) {
      returnShipmentsSuccess.value = true;
    });
  }

  Future<void> getShipmentData(String shipmentId, String type) async {
    await _performAction(() async {
      String? token = await userRepository.getAuthToken();
      if (type == "bulkPickup") {
        return await EventsApiCaptain.getShipmentByIdBulkPickup(
          token: token,
          id: shipmentId,
        );
      } else {
        return await EventsApiCaptain.getShipmentByIdReturnToClient(
          token: token,
          id: shipmentId,
        );
      }
    }, onSuccess: (response) {
      newShipment.value = response.responseData;
    });
  }

  Future<void> getReceipt(String storeId, String method) async {
    await _performAction(() async {
      return await EventsApiCaptain.getReceipt(
        storeId: storeId,
        paymentMethod: method,
      );
    }, onSuccess: (response) {
      receipt.value = response.responseData;
    });
  }

  Future<void> getClientCredit(String id, List<OrdersDataModelMix>? acceptedList, bool returnToClient) async {
    await _performAction(() async {
      String? token = await userRepository.getAuthToken();
      
      if (returnToClient) {
        return await EventsApiCaptain.getReturnCharges(
          acceptedList: acceptedList ?? [],
          token: token,
          memberId: id,
        );
      } else {
        return await EventsApiCaptain.getClientCredit(
          acceptedList: acceptedList ?? [],
          token: token,
          memberId: id,
        );
      }
    }, onSuccess: (response) {
      calculations.value = List<String>.from(response.responseData);
    });
  }

  Future<void> sendConfirmationMsg(String receiverId, String receiverPhone, String msgType) async {
    await _performAction(() async {
      return await EventsApiCaptain.setMsgType(
        receiverId: receiverId,
        receiverPhone: receiverPhone,
        msgType: msgType,
      );
    }, onSuccess: (response) {
      msgSentSuccess.value = true;
    });
  }

  Future<void> getClientBalances(String memberId) async {
    await _performAction(() async {
      String? token = await userRepository.getAuthToken();
      return await EventsApiCaptain.getClientBalance(
        token: token,
        memberId: memberId,
      );
    }, onSuccess: (response) {
      clientBalance.value = response.responseData;
    });
  }

  Future<void> _performAction(Future<MyResponseModel> Function() apiCall, {Function(MyResponseModel)? onSuccess}) async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      MyResponseModel response = await apiCall();
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        if (onSuccess != null) {
          onSuccess(response);
        }
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => _performAction(apiCall, onSuccess: onSuccess));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = response.errorsList?.isNotEmpty == true ? response.errorsList!.first : 'error';
        errorsList.assignAll(response.errorsList ?? []);
      }
    } catch (e) {
      errorMessage.value = 'general';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleTokenRefresh(Future<void> Function() retryAction) async {
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
