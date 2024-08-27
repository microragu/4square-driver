

import 'dart:ui';

import 'package:driver/constants/api_constants.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/flutter_flow/flutter_flow_theme.dart';
import 'package:driver/page/dashboard/service/service_details_page.dart';
import 'package:driver/page/reject/service_reject_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../constants/app_style.dart';
import '../../../controller/home_controller.dart';
import '../../../model/firebase/firebase_order_response.dart';
import '../../../navigation/page_navigation.dart';
import '../../../utils/time_utils.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends StateMVC<ServicePage> {

  late HomeController _con;

  _ServicePageState() : super(HomeController()) {
    _con = controller as HomeController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      var firebaseOrderResponse = FirebaseOrderResponse();
      firebaseOrderResponse = FirebaseOrderResponse();
      firebaseOrderResponse.vendorId = message.data['vendor_id'];
      firebaseOrderResponse.type = message.data['type'];
      firebaseOrderResponse.orderid = message.data['orderid'];
      if(firebaseOrderResponse.type == "on_service") {
        _con.listService(context);
      }
    });
    _con.listService(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  _con.serviceResponseModel.data!=null ?  Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _con.serviceResponseModel.data!.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context,index){
                    var serviceBean = _con.serviceResponseModel.data![index];
                    return InkWell(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailsPage(serviceBean),
                          ),
                        ).then((value){
                          _con.listService(context);
                        });
                      },
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white, // Background color
                                borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                border: Border.all(
                                  color: Colors.grey.shade300, // Light gray border color
                                  width: 2.0, // Border width
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              "#Service ID: ${serviceBean.serviceCode!}",
                                              style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.black),
                                            ),
                                            Text(
                                              TimeUtils.convertUTC(serviceBean.fromtime!),
                                              style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.grey.shade500),
                                            ),
                                          ],
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                        ),
                                        Text(
                                          ApiConstants.currency+serviceBean.deliveryfees!,
                                          style: AppStyle.font18BoldWhite.override(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: Colors.grey.shade500,
                                    ),
                                    serviceBean.deliveryStatus == "Delivered" ?
                                    Container()
                                        :Column(
                                      children: [
                                        Text(
                                          "From",
                                          style: AppStyle.font14MediumBlack87.override(fontSize: 10,color: Colors.grey.shade500),
                                        ),
                                        SizedBox(height: 2,),
                                        Text(
                                          serviceBean.fromlocation!,maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppStyle.font18BoldWhite.override(fontSize: 12),
                                        ),
                                        SizedBox(height: 5,),
                                        Text(
                                          "To",
                                          style: AppStyle.font14MediumBlack87.override(fontSize: 10,color: Colors.grey.shade500),
                                        ),
                                        SizedBox(height: 2,),
                                        Text(
                                          serviceBean.tolocation!,maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppStyle.font18BoldWhite.override(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: Colors.grey.shade500,
                                    ),

                                    serviceBean.isAccepted == "0" ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          child: Container(
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Colors.green, // Background color
                                              borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Accept",
                                                style: AppStyle.font14MediumBlack87.override(fontSize: 12,color: Colors.white),
                                              ),
                                            ),
                                            width: 120,
                                          ),
                                          onTap: (){
                                            _con.acceptService(context,serviceBean.id!,"Accepted","");
                                          },
                                        ),
                                        InkWell(
                                          onTap: (){
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ServiceRejectPage(serviceBean.id!),
                                              ),
                                            ).then((value){
                                                _con.listService(context);
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color: Colors.red, // Background color
                                              borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Reject",
                                                style: AppStyle.font14MediumBlack87.override(fontSize: 12,color: Colors.white),
                                              ),
                                            ),
                                            width: 120,
                                          ),
                                        ),
                                      ],
                                    ):Container(),
                                    serviceBean.isAccepted == "1" ? Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.green, // Background color
                                            borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                          ),
                                          child: Text(
                                            serviceBean.deliveryStatus!,
                                            style: AppStyle.font14MediumBlack87.override(fontSize: 12,color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ):Container(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ),
      ):Center(child: Text("No service found",style: AppStyle.font14MediumBlack87.override(fontSize: 16,),)),
    );
  }


}
