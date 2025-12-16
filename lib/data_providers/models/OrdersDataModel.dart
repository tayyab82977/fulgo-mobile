import 'package:equatable/equatable.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class OrdersDataModelMix extends Equatable {
  String? id;
  String? staff;
  String? barcode;
  String? stamp;
  String? member;
  String? memberName;
  String? memberPhone;
  String? senderName;
  String? senderPhone;
  String? pickupTime;
  String? pickupAddress;
  String? pickupNeighborhood;
  String? pickupMap;
  String? receiverName;
  String? receiverPhone;
  String? deliverTime;
  String? deliverAddress;
  String? deliverNeighborhood;
  String? deliverMap;
  String? status;
  String? cancellation;
  String? direction;
  String? packaging;
  String? fragile;
  String? followup;
  String? weight;
  var length;
  var width;
  var height;
  String? cost;
  String? comment;
  bool? accepted;
  String? cod;
  String? por;
  String? extra;
  String? rc;
  String? reject;
  var price;
  String? taskId;
  int? progress;
  DownloadTaskStatus? statusDownload = DownloadTaskStatus.undefined;
  String? deductFromCod;
  String? orderType;
  String? pickupCity;
  String? deliverCity;
  String? pickupCityId;
  String? deliverCityId;
  String? quantity;
  String? t_deliverCity;
  String? t_pickupCity;
  bool selected = false;
  bool inValidPhones = false;
  String? noOfCartoons;
  String? trackType;
  String? pickupStoreId ;
  String? payment_method ;
  String? note ;
  String? pickupCityName ;
  String? deliverCityName ;
  String? taker ;

  OrdersDataModelMix({
    this.id,
    this.staff,
    this.barcode,
    this.stamp,
    this.member,
    this.senderName,
    this.senderPhone,
    this.pickupTime,
    this.pickupAddress,
    this.pickupNeighborhood,
    this.pickupMap,
    this.receiverName,
    this.receiverPhone,
    this.deliverTime,
    this.deliverAddress,
    this.deliverNeighborhood,
    this.deliverMap,
    this.status,
    this.cancellation,
    this.direction,
    this.packaging,
    this.fragile,
    this.followup,
    this.weight,
    this.length,
    this.width,
    this.height,
    this.cost,
    this.taker,
    this.comment,
    this.accepted,
    this.cod,
    this.memberPhone,
    this.por,
    this.extra,
    this.rc,
    this.memberName,
    this.reject,
    this.price,
    this.progress,
    this.statusDownload,
    this.taskId,
    this.orderType,
    this.deductFromCod,
    this.pickupCity,
    this.deliverCity,
    this.deliverCityId,
    this.pickupCityId,
    this.quantity,
    this.t_deliverCity,
    this.trackType,
    this.t_pickupCity,
    this.pickupStoreId,
    this.payment_method,
    this.selected = false,
    this.inValidPhones = false,
    this.noOfCartoons,
  });

  OrdersDataModelMix.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    staff = json['staff'];
    barcode = json['barcode'];
    stamp = json['stamp'];
    member = json['member'];
    senderName = json['senderName'];
    senderPhone = json['senderPhone'];
    pickupTime = json['pickupTime'];
    pickupAddress = json['pickupAddress'];
    pickupNeighborhood = json['pickupNeighborhood'];
    pickupMap = json['pickupMap'];
    receiverName = json['receiverName'];
    receiverPhone = json['receiverPhone'];
    deliverTime = json['deliverTime'];
    taker = json['taker'];
    deliverAddress = json['deliverAddress'];
    deliverNeighborhood = json['deliverNeighborhood'];
    deliverMap = json['deliverMap'];
    trackType = json['trackType'];
    status = json['status'];
    cancellation = json['cancellation'];
    direction = json['direction'];
    packaging = json['packaging'];
    fragile = json['fragile'] ? "1" : "0";
    followup = json['followup'] ?? "";
    weight = json['weight'];
    length = json['length'];
    width = json['width'];
    height = json['height'];
    price = json['prices'];
    pickupStoreId = json['pickupStoreId'];
    cost = json['cost'];
    comment = json['comment'];
    memberName = json['memberName'];
    memberPhone = json['memberPhone'];
    cod = json['cod'];
    extra = json['extra'];
    rc = json['rc'];
    reject = json['reject'];
    deductFromCod = json['latePayment'];
    orderType = json['orderType'];
    pickupCity = json['pickupCity'];
    deliverCity = json['deliverCity'];
    deliverCityId = json['deliverCityId'];
    pickupCityId = json['pickupCityId'];
    pickupCityName = json['pickupCityName'];
    deliverCityName = json['deliverCityName'];
    quantity = json['quantity'];
    payment_method = json['payment_method'];
    // t_deliverCity = json['t_deliverCity'];
    // t_pickupCity = json['t_pickupCity'];
    noOfCartoons = json['carton'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['staff'] = this.staff;
    data['barcode'] = this.barcode;
    data['stamp'] = this.stamp;
    data['member'] = this.member;
    data['senderName'] = this.senderName;
    data['senderPhone'] = this.senderPhone;
    data['pickupTime'] = this.pickupTime;
    data['pickupAddress'] = this.pickupAddress;
    data['pickupNeighborhood'] = this.pickupNeighborhood;
    data['pickupMap'] = this.pickupMap;
    data['receiverName'] = this.receiverName;
    data['receiverPhone'] = this.receiverPhone;
    data['deliverTime'] = this.deliverTime;
    data['deliverAddress'] = this.deliverAddress;
    data['deliverNeighborhood'] = this.deliverNeighborhood;
    data['deliverMap'] = this.deliverMap;
    data['prices'] = this.price;
    data['status'] = this.status;
    data['pickupStoreId'] = this.pickupStoreId;
    data['cancellation'] = this.cancellation;
    data['direction'] = this.direction;
    data['packaging'] = this.packaging;
    data['fragile'] = this.fragile;
    data['followup'] = this.followup;
    data['weight'] = this.weight;
    data['length'] = this.length;
    data['width'] = this.width;
    data['height'] = this.height;
    data['cost'] = this.cost;
    data['trackType'] = this.trackType;
    data['comment'] = this.comment;
    data['memberPhone'] = this.memberPhone;
    data['cod'] = this.cod;
    data['extra'] = this.extra;
    data['rc'] = this.rc;
    data['reject'] = this.reject;
    data['latePayment'] = this.deductFromCod;
    data['orderType'] = this.orderType;
    data['pickupCityId'] = this.pickupCityId;
    data['deliverCityId'] = this.deliverCityId;
    data['quantity'] = this.quantity;
    data['deliverCity'] = this.deliverCity;
    data['pickupCity'] = this.pickupCity;
    data['pickupCityId'] = this.pickupCityId;
    data['deliverCityId'] = this.deliverCityId;
    data['t_deliverCity'] = this.deliverCityId;
    data['t_pickupCity'] = this.pickupCityId;
    data['payment_method'] = this.payment_method;
    data['note'] = this.note;
    data['carton'] = this.noOfCartoons;
    return data;
  }

  @override
  List<Object?> get props => [
        id,
        staff,
        barcode,
        stamp,
        member,
        memberName,
        memberPhone,
        senderName,
        senderPhone,
        pickupTime,
        pickupAddress,
        pickupNeighborhood,
        pickupMap,
        receiverName,
        receiverPhone,
        deliverTime,
        deliverAddress,
        deliverNeighborhood,
        deliverMap,
        status,
        cancellation,
        direction,
        packaging,
        fragile,
        followup,
        weight,
        length,
        width,
        height,
        cost,
        comment,
        accepted,
        cod,
        extra,
        rc,
        reject,
        price,
        taskId,
        progress,
        DownloadTaskStatus.undefined,
        deductFromCod,
        orderType,
        pickupCity,
        deliverCity,
        pickupCityId,
        deliverCityId,
        quantity,
        t_deliverCity,
        t_pickupCity,
        selected,
        noOfCartoons,
        payment_method,
        note,
      ];
}
