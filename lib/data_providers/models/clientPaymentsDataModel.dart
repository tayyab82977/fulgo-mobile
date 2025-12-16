class ClientPaymentsDataModel {
  String? id;
  String? reference;
  String? receipt;
  String? stamp;
  String? status;
  String? amount;
  String? description;
  String? type;
  String? comment;

  ClientPaymentsDataModel(
      {this.id,
        this.reference,
        this.receipt,
        this.stamp,
        this.status,
        this.amount,
        this.description,
        this.type,
        this.comment});

  ClientPaymentsDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    reference = json['reference'];
    receipt = json['receipt'];
    stamp = json['stamp'];
    status = json['status'];
    amount = json['amount'];
    description = json['description'];
    type = json['type'];
    comment = json['comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['reference'] = this.reference;
    data['receipt'] = this.receipt;
    data['stamp'] = this.stamp;
    data['status'] = this.status;
    data['amount'] = this.amount;
    data['description'] = this.description;
    data['type'] = this.type;
    data['comment'] = this.comment;
    return data;
  }
}