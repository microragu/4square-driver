

import 'dart:ui';

import 'package:driver/constants/api_constants.dart';
import 'package:driver/controller/order_controller.dart';
import 'package:driver/flutter_flow/flutter_flow_theme.dart';
import 'package:driver/navigation/page_navigation.dart';
import 'package:driver/utils/time_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../constants/app_style.dart';
import '../../../controller/home_controller.dart';
import '../../../model/firebase/firebase_order_response.dart';
import 'order_details_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends StateMVC<OrderPage> with WidgetsBindingObserver {

  late OrderController _con;

  _OrderPageState() : super(OrderController()) {
    _con = controller as OrderController;
  }

  String _selectedItem = 'All';
  String shopFocusId = "0";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      FirebaseOrderResponse   firebaseOrderResponse = FirebaseOrderResponse();
      firebaseOrderResponse.vendorId = message.data['vendor_id'];
      firebaseOrderResponse.type = message.data['type'];
      firebaseOrderResponse.orderid = message.data['orderid'];
      if(firebaseOrderResponse.type == "on_ready") {
        _con.listAllOrders("0",shopFocusId);
      }
    });
    _con.listAllOrders("0",shopFocusId);
    _con.getShopFocus(context);
  }



  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _con.shopFocusModel.data!=null ? Container(
                height: 40,
                child: ListView.builder(
                  itemCount: _con.shopFocusModel.data!.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    var shopBean =  _con.shopFocusModel.data![index];
                    bool isSelected = index == _selectedIndex;
                    return  !shopBean.title!.toLowerCase().contains("service") ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                          shopFocusId = shopBean.shopFocusId!;
                          if(_selectedItem == "All") {
                            _con.listAllOrders("0",shopFocusId);
                          }else if(_selectedItem == "On Preparing"){
                            _con.listAllOrders("on_going",shopFocusId);
                          }else if(_selectedItem == "On Ready"){
                            _con.listAllOrders("on_ready",shopFocusId);
                          }else if(_selectedItem == "On Finish"){
                            _con.listAllOrders("on_finish",shopFocusId);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 100,
                          padding: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.red : Colors.green, // Highlight selected item
                            borderRadius: BorderRadius.circular(10.0), // Rounded corners
                          ),
                          child: Center(
                            child: Text(
                              shopBean.title!,
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ):Container();
                  },
                ),
              ):Container(),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white, // Light gray background color
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  border: Border.all(color: Colors.grey.shade300), // Border color
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedItem,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedItem = newValue!;
                        if(newValue == "All") {
                          _con.listAllOrders("0",shopFocusId);
                        }else if(newValue == "On Preparing"){
                          _con.listAllOrders("on_going",shopFocusId);
                        }else if(newValue == "On Ready"){
                          _con.listAllOrders("on_ready",shopFocusId);
                        }else if(newValue == "On Finish"){
                          _con.listAllOrders("on_finish",shopFocusId);
                        }
                      });
                    },
                    items: <String>[
                      'All',
                      'On Preparing',
                      'On Ready',
                      "On Finish"
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(value),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              _con.orderModel.data!=null ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: _con.orderModel.data!.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context,index){
                    var orderBean = _con.orderModel.data![index];
                    var fromAddress = orderBean.vendor!.displayName!+", "+orderBean.vendor!.address!;
                    var toAddress = orderBean.address!.addressSelect!;
                    return InkWell(
                      onTap: (){

                      },
                      child: InkWell(
                        onTap: (){
                        //  PageNavigation.gotoOrderDetailsPage(context,orderBean);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsPage(orderBean),
                            ),
                          ).then((value){
                             setState(() {
                             _con.listAllOrders("0",shopFocusId);
                            });
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "#${orderBean.saleCode!}",
                                                style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.black),
                                              ),
                                              Text(
                                                TimeUtils.getTimeStampToDate(int.parse(orderBean.paymentTimestamp!)),
                                                style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.grey.shade500),
                                              ),
                                              orderBean.adminforceassigned=="1"  ? Text(
                                                "Order assigned by admin",
                                                style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.green),
                                              ):Container(),
                                            ],
                                          ),

                                          Column(
                                            children: [
                                              // Container(
                                              //     padding: EdgeInsets.all(4.0),
                                              //     decoration: BoxDecoration(
                                              //       color: Colors.green, // Background color
                                              //       borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                              //     ),
                                              //     child: Text(
                                              //       "OTP:${orderBean.otp}",
                                              //       style: AppStyle.font14MediumBlack87.override(fontSize: 10,color: Colors.white),
                                              //     )
                                              // ),
                                              Text(
                                                ApiConstants.currency+orderBean.paymentDetails!.grandTotal.toString(),
                                                style: AppStyle.font18BoldWhite.override(fontSize: 16),
                                              ),
                                              Container(
                                                  padding: EdgeInsets.all(4.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green, // Background color
                                                    borderRadius: BorderRadius.circular(0.0), // Rounded corners
                                                  ),
                                                  child: Text(
                                                    orderBean.orderType!.toUpperCase(),
                                                    style: AppStyle.font14MediumBlack87.override(fontSize: 8,color: Colors.white),
                                                  )
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.grey.shade500,
                                      ),
                                      orderBean.deliveryState == "on_finish" ?
                                      Container():Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "From",
                                            style: AppStyle.font14MediumBlack87.override(fontSize: 10,color: Colors.grey.shade500),
                                          ),
                                          SizedBox(height: 2,),
                                          Text(
                                            fromAddress,
                                            maxLines: 1,
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
                                            toAddress,maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppStyle.font18BoldWhite.override(fontSize: 12),
                                          ),

                                        ],
                                      ),
                                      Divider(
                                        color: Colors.grey.shade500,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Total Item: "+orderBean.productDetails!.length.toString(),
                                                style: AppStyle.font18BoldWhite.override(fontSize: 12),
                                              ),
                                              SizedBox(height: 2,),
                                              Text(
                                                "Mode: "+orderBean.paymentType!.toUpperCase(),
                                                style: AppStyle.font18BoldWhite.override(fontSize: 12,color: Colors.deepOrangeAccent),
                                              ),
                                            ],
                                          ),

                                          Container(
                                            padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              color:orderBean.deliveryState == null ? Color(0XFF1C539A):
                                              orderBean.deliveryState== "on_track" || orderBean.deliveryState== "on_ready" ? Color(0XFFEDDF3F):
                                              orderBean.deliveryState== "on_picked" ? Color(0XFFF56C18):
                                              orderBean.deliveryState== "on_reached" ? Color(0XFF574fa0): // Background color
                                              orderBean.deliveryState== "on_finish" ? Color(0XFF154922):
                                              Color(0XFFEDDF3F), // Background color
                                              borderRadius: BorderRadius.circular(10.0), // Rounded corners
                                            ),
                                            child: orderBean.deliveryState== "on_going" ? Text(
                                              "Preparing",
                                              style: AppStyle.font14MediumBlack87.override(fontSize: 12,color: Colors.white),
                                            ): orderBean.deliveryState== "on_ready" ? Text(
                                              "Ready",
                                              style: AppStyle.font14MediumBlack87.override(fontSize: 12,color: Colors.white),
                                            ):orderBean.deliveryState== "on_picked" ? Text(
                                              "Shipped",
                                              style: AppStyle.font14MediumBlack87.override(fontSize: 12,color: Colors.white),
                                            ):orderBean.deliveryState== "on_reached" ? Text(
                                              "Reached",
                                              style: AppStyle.font14MediumBlack87.override(fontSize: 12,color: Colors.white),
                                            ):Text(
                                              "Finish",
                                              style: AppStyle.font14MediumBlack87.override(fontSize: 12,color: Colors.white),
                                            )
                                          )
                                        ],
                                      ),
                                      orderBean.deliveryState== "on_ready" ?Text(
                                        "Please navigation to store on time",
                                        style: AppStyle.font14MediumBlack87.override(fontSize: 12,color: Colors.red),
                                      ):Container(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }):Container(),
            ],
          ),
        ),
      )
    );
  }
}
