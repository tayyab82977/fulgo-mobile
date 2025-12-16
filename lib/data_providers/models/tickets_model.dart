class TicketsModel {
  String? id;
  String? subject;
  String? shipment;
  String? ticketCategoryName;
  String? description;
  String? creator;
  String? reporter;
  String? categoryId;
  String? status;
  String? solver;
  String? follower;
  String? createdAt;
  String? updatedAt;

  TicketsModel(
      {this.id,
        this.subject,
        this.shipment,
        this.description,
        this.creator,
        this.reporter,
        this.categoryId,
        this.status,
        this.solver,
        this.follower,
        this.createdAt,
        this.updatedAt});

  TicketsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    subject = json['subject'];
    shipment = json['shipment'];
    description = json['description'];
    creator = json['creator'];
    reporter = json['reporter'];
    categoryId = json['category_id'];
    status = json['status'];
    solver = json['solver'];
    follower = json['follower'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['subject'] = this.subject;
    data['shipment'] = this.shipment;
    data['description'] = this.description;
    data['creator'] = this.creator;
    data['reporter'] = this.reporter;
    data['category_id'] = this.categoryId;
    data['status'] = this.status;
    data['solver'] = this.solver;
    data['follower'] = this.follower;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class TicketsHistoryModel {
  String? id;
  String? comment;
  String? statusId;
  String? actor;
  String? ticketId;
  String? createdAt;
  String? updatedAt;

  TicketsHistoryModel(
      {this.id,
        this.comment,
        this.statusId,
        this.actor,
        this.ticketId,
        this.createdAt,
        this.updatedAt});

  TicketsHistoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    comment = json['comment'];
    statusId = json['status_id'];
    actor = json['actor'];
    ticketId = json['ticket_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['comment'] = this.comment;
    data['status_id'] = this.statusId;
    data['actor'] = this.actor;
    data['ticket_id'] = this.ticketId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}