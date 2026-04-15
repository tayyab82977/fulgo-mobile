import 'package:flutter/foundation.dart';
import 'package:Fulgox/data_providers/models/userModel.dart';

class ImagesProvider with ChangeNotifier{
  late List<UserModel> _savedAccountsList;

  List<UserModel> get savedAccountsList => _savedAccountsList;

  void updateImagesList(List<UserModel> imagesList) {
    _savedAccountsList = imagesList;
    notifyListeners();
  }

}
