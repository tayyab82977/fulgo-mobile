import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/data_providers/models/userModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class ProfileController extends GetxController {
  final UserRepository userRepository = UserRepository();
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var profileData = Rxn<ProfileDataModel>();
  var showNoNationalId = false.obs;
  var lastFailedEvent = Rxn<dynamic>();

  Future<void> fetchProfileData() async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    showNoNationalId.value = false;

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.FetchDashBoardData(token: token);

      if (response.statusCode == 200) {
        _handleSuccess(response.responseData);
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh();
      } else {
        errorMessage.value = 'error';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _handleSuccess(ProfileDataModel data) {
    profileData.value = data;
    SavedData.profileDataModel = data;
    
    if (data.permission == '1' || data.permission == '11') {
      userRepository.persistName(name: data.name!);
      UserRepository.name = data.name;

      if (data.national_id == null) {
        showNoNationalId.value = true;
        return;
      }

      var account = SavedData.accountsList.firstWhereOrNull((element) => element.phone == data.phone);
      if (account != null) {
        account.name = data.name!;
        UserModel.saveAccount(SavedData.accountsList);
      }
    } else {
      errorMessage.value = 'invalidToken';
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
        String? newToken = loginResponse.responseData;
        
        MyResponseModel retryResponse = await EventsAPIs.FetchDashBoardData(token: newToken);
        if (retryResponse.statusCode == 200) {
          _handleSuccess(retryResponse.responseData);
        } else {
          errorMessage.value = 'invalidToken';
        }
      } else {
        errorMessage.value = 'invalidToken';
      }
    } catch (e) {
      errorMessage.value = 'exception';
    }
  }
}
