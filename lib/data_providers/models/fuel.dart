import 'package:xturbox/data_providers/models/resourcstDataModel.dart';

class FuelEntryModel {
  FuelEntryModel({
     this.id,
     this.amount,
     this.vehicle,
     this.courier,
     this.reference,
     this.grade,
     this.createdAt,
     this.updatedAt,
     this.status,
     this.station,
     this.workshop,
     this.sparePartList,
  });
   String? id;
   String? amount;
   String? vehicle;
   String? courier;
   String? reference;
   String? grade;
   String? createdAt;
   String? updatedAt;
   String? status;
   String? station;
   String? workshop;
   List<Cancellation>? sparePartList ;

  FuelEntryModel.fromJson(Map<String, dynamic> json){
    id = json['id'].toString();
    amount = json['amount'];
    vehicle = json['vehicle'];
    courier = json['courier'];
    reference = json['reference'];
    grade = json['grade'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
    station = json['station'];
    workshop = json['workshop'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['amount'] = amount;
    _data['vehicle'] = vehicle;
    _data['courier'] = courier;
    _data['reference'] = reference;
    _data['station'] = station;
    _data['grade'] = grade;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['status'] = status;
    _data['workshop'] = workshop;
    List jsonList = [];
    sparePartList?.map((e) => jsonList.add(e.toJson())).toList();
    _data['spareParts'] = jsonList ;
    return _data;
  }
}