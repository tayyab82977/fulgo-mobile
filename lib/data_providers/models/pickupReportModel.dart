class PickupReportModel {
  int? success;
  int? fail;
  List<Errors>? errors;

  PickupReportModel({this.success, this.fail, this.errors});

  PickupReportModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    fail = json['fail'];
    if (json['errors'] != null) {
      errors =  List<Errors>.empty(growable: true);
      json['errors'].forEach((v) {
        errors!.add(new Errors.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['fail'] = this.fail;
    if (this.errors != null) {
      data['errors'] = this.errors!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Errors {
  String? id;
  List<String>? error;

  Errors({this.id, this.error});

  Errors.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    error = json['error'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['error'] = this.error;
    return data;
  }
}