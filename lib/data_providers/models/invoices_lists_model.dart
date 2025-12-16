import 'package:xturbox/data_providers/models/invoices_model.dart';

class InvoicesListsModel{

  List<InvoicesModel>? invoices;
  List<InvoicesModel>? refundInvoice;
  String? total;

  InvoicesListsModel({this.invoices, this.refundInvoice, this.total});

  InvoicesListsModel.fromJson(Map<String, dynamic> json){
    if (json['invoices'] != null){
      invoices = [];
      json['invoices'].forEach((i){
        invoices!.add(InvoicesModel.fromJson(i));
      });
    }
    if (json['refundInvoice'] != null){
      refundInvoice = [];
      json['refundInvoice'].forEach((i){
        refundInvoice!.add(InvoicesModel.fromJson(i));
      });
    }
    total = json['total'].toString();
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.invoices != null) {
      data['invoices'] = this.invoices!.map((i) => i.toJson()).toList();
    }
    if (this.refundInvoice != null) {
      data['refundInvoice'] = this.refundInvoice!.map((i) => i.toJson()).toList();
    }
    data['total'] = this.total;
    return data;
  }

}