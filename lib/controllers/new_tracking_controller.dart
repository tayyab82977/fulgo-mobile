import 'package:get/get.dart';
import 'package:Fulgox/data_providers/apis/EventsApi.dart';
import 'package:Fulgox/data_providers/models/MyResponseModel.dart';
import 'package:Fulgox/utilities/NetworkUtilities.dart';

class NewTrackingController extends GetxController {

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var trackingList = Rxn<dynamic>();

  Future<void> getNewTracking({required String id}) async {
    if (!await _checkConnectivity()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      MyResponseModel response = await EventsAPIs.getTracking(id: id);

      if (response.statusCode == 200) {
        trackingList.value = response.responseData;
      } else if (response.statusCode == 204) {
        errorMessage.value = 'inValidShipment';
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

  Future<bool> _checkConnectivity() async {
    bool isUserConnected = await NetworkUtilities.isConnected();
    if (!isUserConnected) {
      errorMessage.value = 'TIMEOUT';
      return false;
    }
    return true;
  }
}
