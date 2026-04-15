import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/apis/EventsApiCaptian.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class CheckInController extends GetxController {
  final UserRepository userRepository = UserRepository();
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var checkInSuccess = false.obs;
  var checkOutSuccess = false.obs;
  var profileLoaded = false.obs;

  Future<void> setStatusActive() async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsApiCaptain.checkIn(token: token, signature: '2');
      
      if (response.responseData == true) {
        checkInSuccess.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => setStatusActive());
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setStatusInactive() async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsApiCaptain.checkIn(token: token, signature: '1');
      
      if (response.responseData == true) {
        checkOutSuccess.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => setStatusInactive());
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCaptainProfile() async {
    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.FetchDashBoardData(token: token);

      if (response.statusCode == 200) {
        if (response.responseData.permission == '4') {
          userRepository.persistName(name: response.responseData.name);
          SavedData.profileDataModel = response.responseData;
          UserRepository.name = response.responseData.name;
          profileLoaded.value = true;
        }
      }
    } catch (e) {
      print(e);
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
      errorMessage.value = 'exception';
    }
  }
}
