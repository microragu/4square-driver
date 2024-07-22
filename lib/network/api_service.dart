

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:driver/model/common/common_response_model.dart';
import 'package:driver/model/driver/driver_model.dart';
import 'package:driver/model/login/login_request.dart';
import 'package:driver/model/login/login_response.dart';
import 'package:driver/model/notification/notification_model.dart';
import 'package:driver/model/order/order_response.dart';
import 'package:driver/utils/preference_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../model/service/service_response_model.dart';
import '../utils/validation_utils.dart';
import 'dio_client.dart';

class ApiService {

  final dioClient = DioClient();

  Future<LoginResponse> signIn(LoginRequest loginRequest) async {
    try {
      final response = await dioClient.post(
          ApiConstants.login, loginRequest.toJson());
      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else {
        ValidationUtils.showAppToast(
            'Failed to sign in. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to sign in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }

  Future<CommonResponseModel> statusUpdate(bool status) async {
    try {
      String? userId = await PreferenceUtils.getUserId();
      final response = await dioClient.get(
          ApiConstants.statusUpdate+status.toString()+"/"+userId!);
      if (response.statusCode == 200) {
        return CommonResponseModel.fromJson(response.data);
      } else {
        ValidationUtils.showAppToast(
            'Failed to sign in. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to sign in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }

  Future<LoginResponse> checkLiveStatus() async {
    try {
      String? userId = await PreferenceUtils.getUserId();
      final response = await dioClient.get(
          ApiConstants.checkLiveStatus+userId!);
      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else {
        ValidationUtils.showAppToast(
            'Failed to sign in. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to sign in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }

  Future<NotificationModel> checkOrderNotifications(String saleCode) async {
    try {
      String? userId = await PreferenceUtils.getUserId();
      final response = await dioClient.get(
          ApiConstants.getOrderNotification+saleCode+"/"+userId!);
      if (response.statusCode == 200) {
        return NotificationModel.fromJson(response.data);
      } else {
        ValidationUtils.showAppToast(
            'Failed to sign in. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to sign in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }

  Future<CommonResponseModel> updateFcmToken(String token) async {
    try {
      String? userId = await PreferenceUtils.getUserId();
      var data = {
        "fcmtoken":token,
        "driver_id":userId
      };
      final response = await dioClient.post(ApiConstants.updateFcmtoken,json.encode(data));
      if (response.statusCode == 200) {
        return CommonResponseModel.fromJson(response.data);
      } else {
        ValidationUtils.showAppToast('Failed to sign in. Status code: ${response.statusCode}');
        throw Exception('Failed to sign in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }



  Future<CommonResponseModel> orderStatus(String salCode,String status) async {
    try {
      String? userId = await PreferenceUtils.getUserId();
      final response = await dioClient.get(
          ApiConstants.changeOrderStatus+"$salCode/$status/$userId");
      if (response.statusCode == 200) {
        return CommonResponseModel.fromJson(response.data);
      } else {
        ValidationUtils.showAppToast(
            'Failed to sign in. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to sign in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }

  Future<CommonResponseModel> serviceStatus(String id,String status) async {
    try {
      String? userId = await PreferenceUtils.getUserId();
      final response = await dioClient.get(
          ApiConstants.changeServicestatus+"$id/$status");
      if (response.statusCode == 200) {
        return CommonResponseModel.fromJson(response.data);
      } else {
        ValidationUtils.showAppToast(
            'Failed to sign in. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to sign in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }

  Future<OrderResponse> listReports(String status,String type,String startDate,String endDate) async {
    try {
      String? userId = await PreferenceUtils.getUserId();
      final response = await dioClient.get(
          ApiConstants.listReport+"$userId/$status/$type/$startDate/$endDate");
      if (response.statusCode == 200) {
        return OrderResponse.fromJson(response.data);
      } else {
        ValidationUtils.showAppToast(
            'Failed to sign in. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to sign in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }

  Future<ServiceResponseModel> listServiceReports(String status,String type,String startDate,String endDate) async {
    try {
      String? userId = await PreferenceUtils.getUserId();
      final response = await dioClient.get(
          ApiConstants.listServiceReport+"$userId/$status/$type/$startDate/$endDate");
      if (response.statusCode == 200) {
        return ServiceResponseModel.fromJson(response.data);
      } else {
        ValidationUtils.showAppToast(
            'Failed to sign in. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to sign in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }

  Future<OrderResponse> listOrders(String status) async {
    try {
      String? userId = await PreferenceUtils.getUserId();
      final response = await dioClient.get(
          ApiConstants.order+"list/$userId/$status");
      if (response.statusCode == 200) {
        return OrderResponse.fromJson(response.data);
      } else {
        ValidationUtils.showAppToast(
            'Failed to sign in. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to sign in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }

  Future<ServiceResponseModel> listService() async {
    try {
      String? userId = await PreferenceUtils.getUserId();
      final response = await dioClient.get(
          ApiConstants.listOtherService+'$userId');
      if (response.statusCode == 200) {
        return ServiceResponseModel.fromJson(response.data);
      } else {
        ValidationUtils.showAppToast(
            'Failed to sign in. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to sign in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }

  Future<DriverModel> getProfile() async {
    try {
      String? userId = await PreferenceUtils.getUserId();
      final response = await dioClient.get(
          ApiConstants.getProfile+"$userId");
      if (response.statusCode == 200) {
        return DriverModel.fromJson(response.data);
      } else {
        ValidationUtils.showAppToast(
            'Failed to sign in. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to sign in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }

  Future<CommonResponseModel> uploadImage(File image) async {
    try {
      String? userId = await PreferenceUtils.getUserId();
      final dio = Dio();
      String fileName = image.path.split('/').last;
      print(fileName);
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(image.path, filename: fileName),
        "driver_id": "$userId",
      });

      try {
        Response response = await dio.post(ApiConstants.profileimage, data: formData);
        if (response.statusCode == 200) {
          return CommonResponseModel.fromJson(response.data);
        } else {
          throw Exception(
              'Failed to sign in. Status code: ${response.statusCode}');
        }
      } catch (e) {
        throw e;
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }

  Future<CommonResponseModel> orderRejectStatus(String saleCode,String status,String reason,String vendorId) async {
    try {
      String? userId = await PreferenceUtils.getUserId();
      final response = await dioClient.get(
          ApiConstants.orderReject+"$saleCode/$status/$reason/$userId/$vendorId");
      if (response.statusCode == 200) {
        return CommonResponseModel.fromJson(response.data);
      } else {
        ValidationUtils.showAppToast(
            'Failed to sign in. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to sign in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }

  Future<CommonResponseModel> locationUpdate(String latitude,String longitude) async {
    try {
      String? userId = await PreferenceUtils.getUserId();
      final response = await dioClient.get(
          ApiConstants.updateLocation+"$latitude/$longitude/$userId");
      if (response.statusCode == 200) {
        return CommonResponseModel.fromJson(response.data);
      } else {
        ValidationUtils.showAppToast(
            'Failed to sign in. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to sign in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ValidationUtils.showAppToast('Error during sign in: $e');
      print('Error during sign in: $e');
      throw e;
    }
  }


  final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

}