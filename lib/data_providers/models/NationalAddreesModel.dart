class NationalAddressModel {
  NationalAddressModel({
    this.city,
    this.zone,
    this.street,
    this.building,
    this.postalCode,
    this.additionalNumber,
    this.unit,
    this.shortAddress,

  });
  String? city;
  String? zone;
  String? street;
  String? building;
  String? postalCode;
  String? additionalNumber;
  String? unit;
  String? shortAddress;


  NationalAddressModel.fromJson(Map<String, dynamic> json){
    city = json['city'].toString();
    zone = json['zone'];
    street = json['building'];
    postalCode = json['postalCode'];
    additionalNumber = json['additionalNumber'];
    unit = json['unit'];
    shortAddress = json['shortAddress'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['city'] = city;
    _data['neighborhood'] = zone;
    _data['street'] = street;
    _data['building'] = building;
    _data['postal_code'] = postalCode;
    _data['additional_code'] = additionalNumber;
    _data['unit'] = unit;
    _data['short_address'] = shortAddress;
    return _data;
  }
}