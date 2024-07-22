

import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:driver/constants/app_style.dart';
import 'package:driver/flutter_flow/flutter_flow_theme.dart';
import 'package:driver/model/notification/notification_model.dart';
import 'package:driver/page/dashboard/home/home_page.dart';
import 'package:driver/page/dashboard/order/order_page.dart';
import 'package:driver/page/dashboard/profile/profile_page.dart';
import 'package:driver/page/dashboard/report/report_page.dart';
import 'package:driver/page/dashboard/service/service_page.dart';
import 'package:driver/page/reject/order_reject_page.dart';
import 'package:driver/utils/tracking_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../constants/app_colors.dart';
import '../../controller/home_controller.dart';
import '../../model/firebase/firebase_order_response.dart';
import '../../network/api_service.dart';
import '../../utils/loader.dart';
import '../../utils/preference_utils.dart';
import '../../utils/validation_utils.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  _DashBoardPageState createState() => _DashBoardPageState();
}

class _DashBoardPageState extends StateMVC<DashBoardPage> {

  late HomeController _con;

  _DashBoardPageState() : super(HomeController()) {
    _con = controller as HomeController;
  }

  var firebaseOrderResponse = FirebaseOrderResponse();
  int _selectedIndex = 1;
  String title = "Profile";
  var icon = Icon(Icons.person,color: Colors.white,);
  late final FirebaseMessaging _firebaseMessaging;
  static List<Widget> _widgetOptions = <Widget>[
    ProfilePage(),
    ReportPage(),
    OrderPage(),
    ServicePage()
  ];
  String _selectedItem = 'Select Reasons';


  static List<String> _widetTitle = <String>[
    "Profile",
    "Orders Report",
    "Orders",
    "Service"
  ];

  static List<Icon> _widetIcons = <Icon>[
    Icon(Icons.person,color: Colors.white,),
    Icon(Icons.dashboard,color: Colors.white,),
    Icon(Icons.document_scanner,color: Colors.white,),
    Icon(Icons.ac_unit,color: Colors.white,),
    Icon(Icons.design_services_outlined,color: Colors.white,),
  ];

  int _remainingTime = 30;
  Timer? _timer;
  static late StreamSubscription<Position> _positionStreamSubscription;
  ApiService apiService = ApiService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      title = _widetTitle[index];
      icon = _widetIcons[index];
    });
  }

  void startLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      PreferenceUtils.saveLatitude(position.latitude.toString());
      PreferenceUtils.saveLongitude(position.longitude.toString());
      _con.locationUpdate(context, position.latitude.toString(), position.longitude.toString());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseMessaging = FirebaseMessaging.instance;
    _con.checkLiveStatus(context);
    startLocationTracking();
    getFCMToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //print(message.data.toString());
      //PreferenceUtils.saveNotificationData(message.data);
      firebaseOrderResponse = FirebaseOrderResponse();
      firebaseOrderResponse.vendorId = message.data['vendor_id'];
      firebaseOrderResponse.type = message.data['type'];
      firebaseOrderResponse.orderid = message.data['orderid'];

      playOrderSound();
      if(firebaseOrderResponse.type == "on_track") {
        checkOrderNotifications(context, firebaseOrderResponse.orderid!);
      }else {
        // /startTimer();
        if(firebaseOrderResponse.type == "on_service"){
          _showServiceDialog(context, _remainingTime);
        }else{
          _showOnReadyCustomDialog(context, _remainingTime);
        }
      }
    });

    PreferenceUtils.getNotificationData().then((value){
         if(value!=null) {
           Map<String, dynamic>? data = value;
           firebaseOrderResponse = FirebaseOrderResponse();
           firebaseOrderResponse.vendorId = data['vendor_id'];
           firebaseOrderResponse.type = data['type'];
           firebaseOrderResponse.orderid = data['orderid'];
           // playOrderSound();
           if(firebaseOrderResponse.type == "on_track") {
             checkOrderNotifications(context, firebaseOrderResponse.orderid!);
           }

         }else{
           print("no data found");
         }
       });

  }

  checkOrderNotifications(BuildContext context,String saleCode){
    Loader.show();
    apiService.checkOrderNotifications(saleCode).then((value){
      Loader.hide();
      if(value.data!=null){
        PreferenceUtils.clearNotificationData();
          //startTimer();
          if (firebaseOrderResponse.type == "on_track") {
            _showCustomDialog(context, _remainingTime,value);
          } else if (firebaseOrderResponse.type == "on_service") {
            _showServiceDialog(context, _remainingTime);
          } else {
            _showOnReadyCustomDialog(context, _remainingTime);
          }         // data = null;
      }
    }).catchError((e){
      Loader.hide();
      print(e);
      ValidationUtils.showAppToast("Something went wrong.");
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;

  playBikeStartSound() async {
    await _audioPlayer.play(AssetSource("sound/bike.mp3"));
    setState(() {
      isPlaying = true;
    });
  }

  playOrderSound() async {
    await _audioPlayer.play(AssetSource("sound/order.wav"));
    setState(() {
      isPlaying = true;
    });
  }
  void getFCMToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    _con.updateFcmToken(context, token!);
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        try {
            _timer?.cancel();
        }catch(e){
          print(e.toString());
        }
      }
    });
  }




  void _showServiceDialog(BuildContext context, int remainingTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "New Service Request",
                        style: AppStyle.font14MediumBlack87.override(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),

                  Image.asset("assets/images/received.png",height: 80,width: 80,),
                  SizedBox(height: 10,),
                  Text(
                    "Service ID:#${firebaseOrderResponse.orderid}",
                    style: AppStyle.font14MediumBlack87.override(fontSize: 16),
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          _audioPlayer.stop();
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset("assets/images/accept.png",height:  40,width: 40,fit: BoxFit.fill,),
                        ),
                      ),
                      SizedBox(width: 120,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset("assets/images/decline.png",height: 60,width: 60,fit: BoxFit.fill,),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCustomDialog(BuildContext context, int remainingTime, NotificationModel value) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            height: 350,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "New Orders",
                        style: AppStyle.font14MediumBlack87.override(fontSize: 16),
                      ),
                      SizedBox(width: 20,),
                      // Container(
                      //   width: 40,
                      //   height: 40,
                      //   decoration: BoxDecoration(
                      //     color: Colors.amber[800],
                      //     borderRadius: BorderRadius.circular(50),
                      //     border: Border.all(
                      //       color: Colors.black,
                      //       width: 1,
                      //     ),
                      //   ),
                      //   child: Center(
                      //     child: Text(
                      //       '$remainingTime',
                      //       style: TextStyle(
                      //         fontSize: 14,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                  SizedBox(height: 20,),

                  Image.asset("assets/images/received.png",height: 80,width: 80,),
                  SizedBox(height: 10,),
                  Text(
                    "Shop Name:#${value.data![0].shopName}",
                    maxLines: 1,overflow: TextOverflow.ellipsis,
                    style: AppStyle.font14MediumBlack87.override(fontSize: 16),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    "Order ID:#${firebaseOrderResponse.orderid}",
                    style: AppStyle.font14MediumBlack87.override(fontSize: 16),
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          _audioPlayer.stop();
                          _con.changeOrderStatus(firebaseOrderResponse.orderid!, "on_going",context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset("assets/images/accept.png",height:  40,width: 40,fit: BoxFit.fill,),
                        ),
                      ),
                      SizedBox(width: 120,),
                      InkWell(
                        onTap: (){
                          _audioPlayer.stop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderRejectPage(firebaseOrderResponse.orderid!,firebaseOrderResponse.vendorId!),
                            ),
                          ).then((value){

                          });
                          //_showRejectedReasons(context);
                          //_con.orderRejectStatus(context,firebaseOrderResponse.orderid!,"Rejected","Heavy Rain",firebaseOrderResponse.vendorId!);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset("assets/images/decline.png",height: 60,width: 60,fit: BoxFit.fill,),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showOnReadyCustomDialog(BuildContext context, int remainingTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Order is Ready. \n Please pick the order now.",
                        textAlign: TextAlign.center,
                        style: AppStyle.font14MediumBlack87.override(fontSize: 16),
                      ),

                    ],
                  ),
                  SizedBox(height: 20,),

                  Image.asset("assets/images/received.png",height: 80,width: 80,),
                  SizedBox(height: 10,),
                  Text(
                    "Order ID:#${firebaseOrderResponse.orderid}",
                    style: AppStyle.font14MediumBlack87.override(fontSize: 16),
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          _audioPlayer.stop();
                          Navigator.pop(context);
                          //_con.changeOrderStatus(firebaseOrderResponse.orderid!, "on_going",context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset("assets/images/accept.png",height:  40,width: 40,fit: BoxFit.fill,),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        title: InkWell(
          onTap: (){
            //_showCustomDialog(context);
          },
          child: Row(
            children: [
              icon,
              SizedBox(width: 5,),
              Text(title,style: AppStyle.font14MediumBlack87.override(color: Colors.white,fontSize: 18),),
            ],
          ),
        ),
        actions: [
          Switch.adaptive(
            value: _con.driverStatus,
            onChanged: (newValue) async {
                if(newValue){
                  playBikeStartSound();
                }
                _con.statusUpdate(context, newValue);
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.black87,
            inactiveTrackColor: Colors.black26,
            inactiveThumbColor: FlutterFlowTheme.of(context).secondaryText,
          )
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor:  AppColors.themeColor,
        unselectedItemColor: Colors.white, // Unselected icon color
        selectedItemColor: Colors.black45, // Selected icon color
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner_rounded),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ac_unit),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'Service',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}