

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/model/login/login_response.dart';
import 'package:driver/utils/loader.dart';
import 'package:driver/utils/preference_utils.dart';
import 'package:driver/utils/validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../model/common/common_response_model.dart';
import '../model/service/service_response_model.dart';
import '../network/api_service.dart';

class HomeController extends ControllerMVC{

  ApiService apiService = ApiService();
  var commonResponseModel = CommonResponseModel();
  var serviceResponseModel = ServiceResponseModel();
  var profileModel = LoginResponse();
  var driverStatus = false;

  checkLiveStatus(BuildContext context){
    Loader.show();
    apiService.checkLiveStatus().then((value){
      Loader.hide();
      if(value.success!){
        setState(() {
          profileModel = value;
          driverStatus = profileModel.data!.liveStatus!;
        });
      }
      notifyListeners();
    }).catchError((e){
      Loader.hide();
      print(e);
      ValidationUtils.showAppToast("Something went wrong.");
    });
  }

  statusUpdate(BuildContext context,bool status){
    Loader.show();
    apiService.statusUpdate(status).then((value){
      Loader.hide();
      checkLiveStatus(context);
    }).catchError((e){
      Loader.hide();
      print(e);
      ValidationUtils.showAppToast("Something went wrong.");
    });
  }

  updateFcmToken(BuildContext context,String token){
    apiService.updateFcmToken(token).then((value) {
      commonResponseModel = value;
      notifyListeners();
    }).catchError((e) {
      ValidationUtils.showAppToast("Something went wrong.");
      print(e);
    });
  }

  changeOrderStatus(String saleCode,String status, BuildContext context) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    if(status == "on_going"){
      String? userId = await PreferenceUtils.getUserId();
      await _firestore.collection('driverTrack').doc(saleCode).set({
        'driverId': userId!,
        'latitude': 37.4219983,
        'longitude': -122.084,
        'order_status': status,
      });
    }
    Loader.show();
    apiService.orderStatus(saleCode,status).then((value){
      Loader.hide();
      if(value.success!) {
        Navigator.pop(context);
      }else{
        Navigator.pop(context);
        ValidationUtils.showAppToast("Sorry you can't take this order.");
      }
    }).catchError((e){
      Loader.hide();
      print(e);
      ValidationUtils.showAppToast("Something went wrong.");
    });
  }

  listService(BuildContext context){
    Loader.show();
    apiService.listService().then((value){
      Loader.hide();
      if(value.success!){
        setState(() {
          serviceResponseModel = value;
        });
        notifyListeners();
      }else{
        ValidationUtils.showAppToast("Something wrong");
      }
    }).catchError((e){
      print(e);
      Loader.hide();
    });
    notifyListeners();
  }

  changeServiceStatus(String id,String status, BuildContext context) async {
    Loader.show();
    apiService.serviceStatus(id,status).then((value){
      Loader.hide();
      Navigator.pop(context);
    }).catchError((e){
      Loader.hide();
      print(e);
      ValidationUtils.showAppToast("Something went wrong.");
    });
  }


  orderRejectStatus(BuildContext context, String saleCode,String status,String reason,String vendorId) async {
    Loader.show();
    apiService.orderRejectStatus(saleCode,status,reason,vendorId).then((value){
      Loader.hide();
      Navigator.pop(context);
      Navigator.pop(context);
    }).catchError((e){
      Loader.hide();
      print(e);
      ValidationUtils.showAppToast("Something went wrong.");
    });
  }

  locationUpdate(BuildContext context,String latitude,String longitude){
    apiService.locationUpdate(latitude,longitude).then((value){

    }).catchError((e){
      print(e);
      ValidationUtils.showAppToast("Something went wrong.");
    });
  }


}