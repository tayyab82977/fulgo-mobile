import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApiCaptian.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/captainOrdersDataModel.dart';
import 'package:Fulgox/data_providers/models/newForCaptainOrders.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class CaptainOrdersController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var captainOrdersData = Rxn<NewForCapOrders>();
  var isEmpty = false.obs;

  Future<void> fetchCaptainOrders() async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    isEmpty.value = false;

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsApiCaptain.getCaptainOrders(token: token);

      if (response.statusCode == 200 && response.responseData != null) {
        captainOrdersData.value = response.responseData;
      } else if (response.statusCode == 204) {
        isEmpty.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh();
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

  Future<void> _handleTokenRefresh() async {
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
        authController.login(loginResponse.responseData);
        await fetchCaptainOrders();
      } else {
        errorMessage.value = 'invalidToken';
      }
    } catch (e) {
      errorMessage.value = 'exception';
    }
  }
}
