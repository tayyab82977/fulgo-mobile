import 'package:get/get.dart';
import 'package:Fulgox/UserRepo.dart';
import 'package:Fulgox/controllers/auth_controller.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/data_providers/models/AddressModel.dart';
import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/geoCodingDataModel.dart';
import 'package:Fulgox/data_providers/models/savedData.dart';
import 'package:Fulgox/data_providers/models/userModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class EditProfileController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var success = false.obs;
  var errorsList = <dynamic>[].obs;

  Future<void> putProfileRequest(
      {String? name,
      String? email,
      String? phone2,
      bool? changeUsername,
      String? password,
      String? id,
      String? national_id,
      String? firstName,
      String? lastName,
      String? companyName,
      String? vatNumber,
      String? cer}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    success.value = false;

    try {
      MyResponseModel response = await EventsAPIs.EditProfile(
          name: name,
          email: email,
          phone2: phone2,
          changeUserName: changeUsername,
          password: password,
          id: id,
          national_id: national_id,
          firstName: firstName,
          lastName: lastName,
          companyName: companyName,
          vatNumber: vatNumber,
          cer: cer);

      if (response.responseData == true) {
        await userRepository.persistPassword(password: password!);
        SavedData.accountsList
            .where(
                (element) => element.phone == SavedData.profileDataModel!.phone)
            .first
            .password = password;
        UserModel.saveAccount(SavedData.accountsList);
        success.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => putProfileRequest(
            name: name,
            email: email,
            phone2: phone2,
            changeUsername: changeUsername,
            password: password,
            id: id,
            national_id: national_id,
            firstName: firstName,
            lastName: lastName,
            companyName: companyName,
            vatNumber: vatNumber,
            cer: cer));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorsList.value = response.errorsList ?? [];
      }
    } catch (e) {
      errorMessage.value = 'exception';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBank(
      {required String bankName,
      required String name,
      required String iban}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    success.value = false;

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.AddBankData(
          token: token, bankName: bankName, name: name, iban: iban);

      if (response.responseData == true) {
        success.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(
            () => addBank(bankName: bankName, name: name, iban: iban));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorsList.value = response.errorsList ?? [];
      }
    } catch (e) {
      errorMessage.value = 'exception';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addNationalAddress(dynamic nationalAddressModel) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    success.value = false;

    try {
      MyResponseModel response = await EventsAPIs.addNationalAddress(
          nationalAddressModel: nationalAddressModel);

      if (response.responseData == true) {
        success.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(
            () => addNationalAddress(nationalAddressModel));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorsList.value = response.errorsList ?? [];
      }
    } catch (e) {
      errorMessage.value = 'exception';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAddress(List<Addresses> addressList) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    success.value = false;

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response =
          await EventsAPIs.AddAddresses(token: token, list: addressList);

      if (response.responseData == true) {
        success.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(() => addAddress(addressList));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorsList.value = response.errorsList ?? [];
      }
    } catch (e) {
      errorMessage.value = 'exception';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editBank(
      {required String bankName,
      required String name,
      required String iban}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';
    success.value = false;

    try {
      String? token = await userRepository.getAuthToken();
      MyResponseModel response = await EventsAPIs.editBank(
          token: token, bankName: bankName, name: name, iban: iban);

      if (response.responseData == true) {
        success.value = true;
      } else if (response.statusCode == 403) {
        await _handleTokenRefresh(
            () => editBank(bankName: bankName, name: name, iban: iban));
      } else if (response.statusCode == 505) {
        errorMessage.value = 'needUpdate';
      } else {
        errorMessage.value = 'error';
        errorsList.value = response.errorsList ?? [];
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
          (loginResponse.statusCode == 201 ||
              loginResponse.statusCode == 200)) {
        await userRepository.persistToken(token: loginResponse.responseData);
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
