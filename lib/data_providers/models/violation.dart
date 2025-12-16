class ViolationModel {
  String? name;
  String? id;
  String? status;
  String? statusName;
  String? createdAt;
  String? paidDate;
  String? description;
  String? amount;
  String? type;
  String? groupName;
  String? paid_date;

  ViolationModel(
      {this.name,
        this.id,
        this.status,
        this.createdAt,
        this.paidDate,
        this.type,
        this.description});

  ViolationModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    status = json['status'];
    createdAt = json['created_at'];
    paidDate = json['paid_date'];
    description = json['description'];
    amount = json['amount'];
    type = json['type'];
    groupName = json['groupName'];
    statusName = json['statusName'];
    paid_date = json['paid_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['paid_date'] = this.paidDate;
    data['description'] = this.description;
    return data;
  }
}