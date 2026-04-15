import 'package:Fulgox/data_providers/models/ProfileDataModel.dart';
import 'package:Fulgox/data_providers/models/resourcstDataModel.dart';
import 'package:Fulgox/data_providers/models/userModel.dart';

class SavedData {

  static ProfileDataModel profileDataModel = ProfileDataModel();
  static ResourcesData resourcesData = ResourcesData();
  static String token = '';
  static String workingPhone = '';
  static List<UserModel> accountsList = [];


}