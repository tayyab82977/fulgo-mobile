import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/apis/EventsApiCaptian.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/OrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/pickUpDataModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class MyPickupController extends GetxController {
  final UserRepository userRepository = UserRepository();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var myPickupData = Rxn<PickUpDataModel>();
  var bulkStoreOutSuccess = false.obs;
  var errorsList = <String>[].obs;

  Future<void> getMyPickups() async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response =
          await EventsApiCaptain.getMyPickups(token: token);

      if (response.statusCode == 200 || response.statusCode == 204) {
        myPickupData.value = response.responseData;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => getMyPickups());
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = response.errorsList?.isNotEmpty == true
            ? response.errorsList!.first
            : 'error';
      }
    } catch (e) {
      errorMessage.value = 'general';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bulkStoreOut(List<OrdersDataModelMix> list) async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    bulkStoreOutSuccess.value = false;

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response =
          await EventsApiCaptain.bulktoreOutShipment(token: token, list: list);

      if (response.statusCode == 200 || response.statusCode == 204) {
        bulkStoreOutSuccess.value = true;
        // Refresh pickups after store out
        await getMyPickups();
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => bulkStoreOut(list));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = response.errorsList?.isNotEmpty == true
            ? response.errorsList!.first
            : 'error';
        errorsList.assignAll(response.errorsList ?? []);
      }
    } catch (e) {
      errorMessage.value = 'general';
    } finally {
      isLoading.value = false;
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
          (loginResponse.statusCode == 201 ||
              loginResponse.statusCode == 200)) {
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
