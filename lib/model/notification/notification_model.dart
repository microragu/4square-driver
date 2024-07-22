

class NotificationModel {
  bool? success;
  List<Data>? data;
  String? message;

  NotificationModel({this.success, this.data, this.message});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  String? saleId;
  String? saleCode;
  String? shopName;

  Data({this.saleId, this.saleCode, this.shopName});

  Data.fromJson(Map<String, dynamic> json) {
    saleId = json['sale_id'];
    saleCode = json['sale_code'];
    shopName = json['shop_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sale_id'] = this.saleId;
    data['sale_code'] = this.saleCode;
    data['shop_name'] = this.shopName;
    return data;
  }
}
