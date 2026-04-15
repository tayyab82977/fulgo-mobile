import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApiCaptian.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/data_providers/models/tripModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class AddTripController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var successAdd = false.obs; // For AddNewTrip
  var successUpdate = false.obs; // For UpdateTripEnd
  var errorMessage = ''.obs;
  var errorList = <dynamic>[].obs;
  var addedTrip = Rxn<TripModel>();
  var updatedTrip = Rxn<TripModel>();


  Future<void> addNewTrip({required TripModel tripModel}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    successAdd.value = false;
    errorList.clear();

    try {
      MyResponseModel response = await EventsApiCaptain.createTrip(tripModel: tripModel);

      if (response.statusCode == 200 || response.statusCode == 201) {
        addedTrip.value = response.responseData;
        successAdd.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => addNewTrip(tripModel: tripModel));
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

  Future<void> updateTripEnd({required TripModel tripModel}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    successUpdate.value = false;
    errorList.clear();

    try {
      MyResponseModel response = await EventsApiCaptain.setTripEnd(tripModel: tripModel);

      if (response.statusCode == 200 || response.statusCode == 201) {
        updatedTrip.value = response.responseData;
        successUpdate.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => updateTripEnd(tripModel: tripModel));
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
