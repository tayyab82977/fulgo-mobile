import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xturbox/data_providers/models/savedData.dart';

class UserModel extends Equatable {
  String phone ;
  String name ;
  String password ;
  String token ;
  String selected ;

  UserModel({required this.phone , required this.password , required this.token , required this.selected,required this.name});


  Map<String, dynamic> toJson() {

    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone'] = this.phone;
    data['password'] = this.password;
    data['token'] = this.token;
    data['selected'] = this.selected;

    return data ;

  }

  factory UserModel.fromJson(Map<String, dynamic> jsonData) {
    return UserModel(
      name: jsonData['name'],
      phone: jsonData['phone'],
      password: jsonData['password'],
      token: jsonData['token'],
      selected: jsonData['selected'],
    );
  }

  static Map<String, dynamic> toMap(UserModel userModel) => {
    'name': userModel.name,
    'phone': userModel.phone,
    'password': userModel.password,
    'token': userModel.token,
    'selected': userModel.selected,
  };

  static String encode(List<UserModel> userModel) => json.encode(
    userModel
        .map<Map<String, dynamic>>((music) => UserModel.toMap(music))
        .toList(),
  );

  static List<UserModel> decode(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<UserModel>((item) =>  UserModel.fromJson(item))
          .toList();



 static saveAccount(List<UserModel> accountsList)async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = UserModel.encode(accountsList);
    print("Saving accountssss");
    await prefs.setString('accountsList', encodedData);
  }


  static deleteAccount(UserModel account) async{
    SavedData.accountsList.remove(account);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = UserModel.encode(SavedData.accountsList);
    await prefs.setString('accountsList', encodedData);
  }

  static Future<List<UserModel>> getSavedAccounts()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String list =  await prefs.getString('accountsList') ?? "";
    return decode(list);
  }

  static Future<bool> checkSavedAccounts()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? check =  await prefs.getString('accountsList') ;
    if(check == null)
      return false ;
    return true ;
  }

  @override

  List<Object?> get props => [phone,password,token,selected,name];

}