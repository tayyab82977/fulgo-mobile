import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class ResourcesController extends GetxController {
  final UserRepository userRepository = UserRepository();
  
  var isLoading = false.obs;
  var resourcesData = Rxn<ResourcesData>();
  var errorMessage = ''.obs;

  Future<void> fetchResources() async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.getResourcesData(token: token);

      if (response.statusCode == 200) {
        resourcesData.value = response.responseData;
        SavedData.resourcesData = response.responseData;
        isLoading.value = false;
      } else if (response.statusCode == 403) {
        // Handle token refresh logic similar to Bloc
        await _handleTokenRefresh();
      } else {
        errorMessage.value = 'error';
        isLoading.value = false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
    }
  }

  Future<void> _handleTokenRefresh() async {
    String phone = await userRepository.getAuthPhone();
    String password = await userRepository.getAuthPassword();

    try {
      final MyResponseModel loginResponse = await UserRepository.LoginAPI(
        username: phone,
        password: password,
      );

      if ((loginResponse.responseData != null && 
          (loginResponse.statusCode == 201 || loginResponse.statusCode == 200))) {
        
        await userRepository.persistToken(token: loginResponse.responseData);
        String? newToken = loginResponse.responseData;
        
        MyResponseModel retryResponse = await EventsAPIs.getResourcesData(token: newToken);
        if (retryResponse.statusCode == 200) {
          resourcesData.value = retryResponse.responseData;
          SavedData.resourcesData = retryResponse.responseData;
        } else {
          errorMessage.value = 'invalidToken';
        }
      } else {
        errorMessage.value = 'invalidToken';
      }
    } catch (e) {
      errorMessage.value = 'exception';
    } finally {
      isLoading.value = false;
    }
  }
}
