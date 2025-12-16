class TrackingList{

  List<TrackingDataModel>? newTracks;
  List<TrackingDataModel>? processing;
  List<TrackingDataModel>? done;
  List<TrackingDataModel>? lost;

  TrackingList({this.newTracks, this.processing, this.done,this.lost});

  TrackingList.fromJson(Map<String, dynamic> json){
    if (json['newTracks'] != null){
      newTracks = [];
      json['newTracks'].forEach((i){
        newTracks!.add(TrackingDataModel.fromJson(i));
      });
    }
    if (json['processing'] != null){
      processing = [];
      json['processing'].forEach((i){
        processing!.add(TrackingDataModel.fromJson(i));
      });
    }

    if (json['done'] != null){
      done = [];
      json['done'].forEach((i){
        done!.add(TrackingDataModel.fromJson(i));
      });
    }

    if (json['lost'] != null){
      lost = [];
      json['lost'].forEach((i){
        lost!.add(TrackingDataModel.fromJson(i));
      });
    }

  }

}





class TrackingDataModel {
  String? stamp;
  String? giver;
  String? taker;
  String? type;
  String? status;
  String? comment;
  String? followup;
  String? reason ;
  String? typeName ;
  String? shipment ;

  TrackingDataModel(
      {this.stamp,
        this.giver,
        this.taker,
        this.followup,
        this.type,
        this.status,
        this.reason,
        this.shipment,
        this.comment});

  TrackingDataModel.fromJson(Map<String, dynamic> json) {
    stamp = json['stamp'];
    giver = json['giver'];
    taker = json['taker'];
    type = json['type'];
    followup = json['followup'];
    status = json['status'];
    reason = json['reason'];
    comment = json['comment'];
    typeName = json['typeName'];
    shipment = json['shipment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stamp'] = this.stamp;
    data['giver'] = this.giver;
    data['taker'] = this.taker;
    data['type'] = this.type;
    data['followup'] = this.followup;
    data['status'] = this.status;
    data['reason'] = this.reason;
    data['comment'] = this.comment;
    return data;
  }
}