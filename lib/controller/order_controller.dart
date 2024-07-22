

import 'package:flutter/cupertino.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../model/order/order_response.dart';
import '../model/service/service_response_model.dart';
import '../network/api_service.dart';
import '../utils/loader.dart';
import '../utils/validation_utils.dart';

class OrderController extends ControllerMVC{

  ApiService apiService = ApiService();
  var orderModel = OrderResponse();
  var serviceResponseModel = ServiceResponseModel();
  var completedOrder = 0;
  var earning = 0.0;
  var serviceCompletedOrder = 0;
  var serviceEarning = 0.0;



  listServiceReports(String status,String type,String startDate,String endDate){
    earning = 0.0;
    Loader.show();
    apiService.listServiceReports(status,type,startDate,endDate).then((value) {
      Loader.hide();
      if(value.data!=null) {
        setState(() {
          serviceResponseModel = value;
          serviceCompletedOrder = serviceResponseModel.data!.length;
          serviceResponseModel.data!.forEach((element) {
            serviceEarning = serviceEarning + double.parse(element.deliveryfees!);
          });
        });
      }
      notifyListeners();
    }).catchError((e){
      Loader.hide();
      print(e);
      ValidationUtils.showAppToast("Something went wrong.");
    });
  }

  listAllReports(String status,String type,String startDate,String endDate){
    earning = 0.0;
    Loader.show();
    apiService.listReports(status,type,startDate,endDate).then((value) {
      Loader.hide();
      if(value.data!=null) {
        setState(() {
          orderModel = value;
          completedOrder = orderModel.data!.length;
          orderModel.data!.forEach((element) {
            earning = earning + double.parse(element.driverCharge!);
          });
        });
      }
      notifyListeners();
    }).catchError((e){
      Loader.hide();
      print(e);
      ValidationUtils.showAppToast("Something went wrong.");
    });
  }

  listAllOrders(String status){
    earning = 0.0;
    Loader.show();
    apiService.listOrders(status).then((value) {
      Loader.hide();
        if(value.data!=null) {
          setState(() {
            orderModel = value;
            completedOrder = orderModel.data!.length;
            orderModel.data!.forEach((element) {
              earning = earning + double.parse(element.driverCharge!);
            });
          });
        }
      notifyListeners();
    }).catchError((e){
      Loader.hide();
      print(e);
      ValidationUtils.showAppToast("Something went wrong.");
    });
  }

  changeOrderStatus(String saleCode,String status, BuildContext context) async {
    Loader.show();
    apiService.orderStatus(saleCode,status).then((value){
      Loader.hide();
      Navigator.pop(context);
    }).catchError((e){
      Loader.hide();
      print(e);
      ValidationUtils.showAppToast("Something went wrong.");
    });
  }



}