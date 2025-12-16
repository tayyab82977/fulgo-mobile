


import 'package:flutter_downloader/flutter_downloader.dart';

class InvoicesModel {
  String? id;
  String? name;
  String? client;
  String? creator;
  var totalAmount;
  var totalVat;
  String? fromDate;
  DownloadTaskStatus? statusDownload = DownloadTaskStatus.undefined;

  String? toDate;
  String? status;
  String? type;
  String? receipt;

  InvoicesModel(
      {this.id,
        this.name,
        this.client,
        this.creator,
        this.totalAmount,
        this.totalVat,
        this.fromDate,
        this.toDate,
        this.status,
        this.type,
        this.receipt});

  InvoicesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'];
    client = json['client'];
    creator = json['creator'];
    totalAmount = json['total_amount'];
    totalVat = json['total_vat'];
    fromDate = json['from_date'];
    toDate = json['to_date'];
    status = json['status'];
    type = json['type'];
    receipt = json['receipt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['client'] = this.client;
    data['creator'] = this.creator;
    data['total_amount'] = this.totalAmount;
    data['total_vat'] = this.totalVat;
    data['from_date'] = this.fromDate;
    data['to_date'] = this.toDate;
    data['status'] = this.status;
    data['type'] = this.type;
    data['receipt'] = this.receipt;
    return data;
  }
}