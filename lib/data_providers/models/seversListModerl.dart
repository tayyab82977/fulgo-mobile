import 'dart:convert';

import 'package:equatable/equatable.dart';

class ServerListModel extends Equatable {

  String? serverName ;
  String? serverValue ;

  ServerListModel({this.serverName , this.serverValue});
  @override
  List<Object?> get props => [serverValue, serverName ];

  ServerListModel.fromJson(Map<String, dynamic> json) {
    serverName = json['serverName'];
    serverValue = json['serverValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['serverName'] = this.serverName;
    data['serverValue'] = this.serverValue;
    return data;
  }

 static Map<String, dynamic> toMap(ServerListModel serverListModel) {
    var map = <String, dynamic>{
      "serverName": serverListModel.serverName,
      "serverValue": serverListModel.serverValue,
    };
    return map ;
  }

  static String encode(List<ServerListModel> musics) => json.encode(
    musics
        .map<Map<String, dynamic>>((music) => ServerListModel.toMap(music))
        .toList(),
  );

  static List<ServerListModel> decode(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<ServerListModel>((item) => ServerListModel.fromJson(item))
          .toList();
}








