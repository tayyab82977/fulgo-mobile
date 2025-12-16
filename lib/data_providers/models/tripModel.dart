class TripModel {
  String? id;
  String? origin;
  String? destination;
  String? courier;
  String? start;
  String? end;
  String? diff;
  String? km;
  String? createdAt;
  String? updatedAt;

  TripModel(
      {this.id,
        this.origin,
        this.destination,
        this.courier,
        this.start,
        this.end,
        this.diff,
        this.km,
        this.createdAt,
        this.updatedAt});

  TripModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    origin = json['origin'].toString();
    destination = json['destination'].toString();
    courier = json['courier'].toString();
    start = json['start'].toString();
    end = json['end'].toString();
    diff = json['diff'].toString();
    km = json['km'].toString();
    createdAt = json['created_at'].toString();
    updatedAt = json['updated_at'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['origin'] = this.origin;
    data['destination'] = this.destination;
    data['courier'] = this.courier;
    data['start'] = this.start;
    data['end'] = this.end;
    data['diff'] = this.diff;
    data['km'] = this.km;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}