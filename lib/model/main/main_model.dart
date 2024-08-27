class MainPageModel {
  bool? success;
  Data? data;
  String? message;

  MainPageModel({this.success, this.data, this.message});

  MainPageModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  int? todaycount;
  int? currentcount;
  int? todayotherservicecount;
  int? overallotherservicecount;
  String? inHandAmount;
  String? sos;

  Data(
      {this.todaycount,
        this.currentcount,
        this.todayotherservicecount,
        this.overallotherservicecount,this.sos,this.inHandAmount});

  Data.fromJson(Map<String, dynamic> json) {
    todaycount = json['todaycount'] == null ? 0 :  json['todaycount'];
    currentcount = json['currentcount']== null ? 0 :  json['currentcount'];
    todayotherservicecount = json['todayotherservicecount']== null ? 0 :  json['todayotherservicecount'];
    overallotherservicecount = json['overallotherservicecount']== null ? 0 :  json['overallotherservicecount'];
    sos = json['sos']== null ? "" :  json['sos'];
    inHandAmount = json['inhand']== null ? "0" :  json['inhand'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['todaycount'] = this.todaycount;
    data['currentcount'] = this.currentcount;
    data['todayotherservicecount'] = this.todayotherservicecount;
    data['overallotherservicecount'] = this.overallotherservicecount;
    return data;
  }
}
