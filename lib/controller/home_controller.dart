

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/model/login/login_response.dart';
import 'package:driver/model/main/main_model.dart';
import 'package:driver/model/notification/admin_notification_model.dart';
import 'package:driver/utils/loader.dart';
import 'package:driver/utils/preference_utils.dart';
import 'package:driver/utils/validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../model/chat/chat_request.dart';
import '../model/chat/chat_response.dart';
import '../model/common/common_response_model.dart';
import '../model/service/service_response_model.dart';
import '../network/api_service.dart';
import '../page/dashboard/order/order_page.dart';
import 'order_controller.dart';

class HomeController extends ControllerMVC{

  final OrderController orderController = OrderController();
  ApiService apiService = ApiService();
  var commonResponseModel = CommonResponseModel();
  var _serviceResponseModel = ServiceResponseModel();
  ServiceResponseModel get serviceResponseModel => _serviceResponseModel;
  var profileModel = LoginResponse();
  var driverStatus = false;
  var chatResponse = ChatResponse();
  var adminNotificationModel = AdminNotificationModel();
  var mainPageResponse = MainPageModel();
  var chatRequest = ChatRequest();
  var orderPage = OrderPage();

  checkLiveStatus(BuildContext context){
    Loader.show();
    apiService.checkLiveStatus().then((value){
      Loader.hide();
      if(value.success!){
        setState(() {
          profileModel = value;
          PreferenceUtils.saveZoneId(profileModel.data!.zoneId!);
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
      if(value.success! == false){
        ValidationUtils.showAppToast("Contact your admin");
      }
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
        orderController.updateStatus("newState");
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
    if(_serviceResponseModel.data!=null){
      setState(() {
        _serviceResponseModel.data!.clear();
      });
    }
    apiService.listService().then((value){
      Loader.hide();
      if(value.success!){
        setState(() {
          _serviceResponseModel = value;
        });
        notifyListeners();
      }else{

        //ValidationUtils.showAppToast("Something wrong");
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
      if(status == "Delivered") {
        Navigator.pop(context);
      }
    }).catchError((e){
      Loader.hide();
      print(e);
      ValidationUtils.showAppToast("Something went wrong.");
    });
  }

  acceptService(BuildContext context,String id, String status,String reason) async {
    Loader.show();
    apiService.acceptService(id,status,reason).then((value){
      Loader.hide();
      listService(context);
      if(status == "Rejected"){
        Navigator.pop(context);
      }
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

  listOrderChat(String orderId, String type, String sender){
    Loader.show();
    apiService.listOrderChat(orderId,type,sender).then((value){
      Loader.hide();
      if(value.success!){
        setState(() {
          chatResponse = value;
        });
      }else{
        ValidationUtils.showAppToast("Something wrong");
      }
    }).catchError((e){
      print(e);
      Loader.hide();
    });
  }

  addOrderChat(ChatRequest chatRequest){
    Loader.show();
    apiService.addOrderChat(chatRequest).then((value){
      Loader.hide();
      if(value.success!){
        listOrderChat(chatRequest.orderId!,chatRequest.type!,chatRequest.sender!);
      }else{
        ValidationUtils.showAppToast("Something wrong");
      }
    }).catchError((e){
      print(e);
      Loader.hide();
    });
  }

  listMainPage(){
    Loader.show();
    apiService.listMainPage().then((value){
      Loader.hide();
      if(value.success!){
        setState(() {
          mainPageResponse = value;
        });
      }else{
        ValidationUtils.showAppToast("Something wrong");
      }
    }).catchError((e){
      print(e);
      Loader.hide();
    });
  }

  listNotifications(){
    Loader.show();
    apiService.listNotifications().then((value){
      Loader.hide();
      if(value.success!){
        setState(() {
          adminNotificationModel = value;
        });
      }else{
        ValidationUtils.showAppToast("Something wrong");
      }
    }).catchError((e){
      print(e);
      Loader.hide();
    });
  }


}