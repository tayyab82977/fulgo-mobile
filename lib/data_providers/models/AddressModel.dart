class AddressModel {
  String? id;
  String? title;
  String? description;
  String? comment;
  String? city;
  String? map;
  String? deleted;

  AddressModel({
    this.id,
    this.title,
    this.description,
    this.comment,
    this.city,
    this.map,
    this.deleted,
  });

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    comment = json['comment'];
    city = json['neighborhood']; 
    map = json['map'];
    deleted = json['deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['comment'] = this.comment;
    data['neighborhood'] = this.city;
    data['map'] = this.map;
    data['deleted'] = this.deleted;
    return data;
  }
}
