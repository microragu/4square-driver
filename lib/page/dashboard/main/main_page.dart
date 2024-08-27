
import 'package:driver/constants/api_constants.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/constants/app_style.dart';
import 'package:driver/flutter_flow/flutter_flow_theme.dart';
import 'package:driver/navigation/page_navigation.dart';
import 'package:driver/utils/preference_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../controller/home_controller.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends StateMVC<MainPage> {

  Offset offset = Offset.zero;
  late HomeController _con;
  String _currentLocation = "Fetching location...";


  _MainPageState() : super(HomeController()) {
    _con = controller as HomeController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _con.listMainPage();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission;

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentLocation = "Location services are disabled.";
      });
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentLocation = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentLocation = "Location permissions are permanently denied.";
      });
      return;
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      //_currentLocation = "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
      PreferenceUtils.saveLatitude(position.latitude.toString());
      PreferenceUtils.saveLongitude(position.longitude.toString());

      _getAddressFromLatLng(position);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
        position!.latitude, position!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentLocation =
        '${place.street}, ${place.subLocality},${place.subAdministrativeArea}, ${place.postalCode}';
      });
      PreferenceUtils.saveLocation(_currentLocation);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {

    return _con.mainPageResponse.data!=null ? Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              child: Card(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text("Current Location: ",style: AppStyle.font14MediumBlack87,),
                    SizedBox(height: 2,),
                    Text(_currentLocation,style: AppStyle.font14MediumBlack87.override(fontSize: 16),),
                  ],
                ),
              )),
            ),
          ),
          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: (){
                    FlutterPhoneDirectCaller.callNumber(_con.mainPageResponse.data!.sos!);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red, // Background color
                      borderRadius: BorderRadius.only(topRight: Radius.circular(10.0),bottomRight: Radius.circular(10.0)), // Rounded corners
                      border: Border.all(
                        color: Colors.red, // Light gray border color
                        width: 2.0, // Border width
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("SOS",style: AppStyle.font14MediumBlack87.override(fontSize: 18,color: Colors.white),),
                    ),
                  ),
                ),
                InkWell(child: Column(
                  children: [
                    Icon(Icons.support_agent,color: AppColors.themeColor,size: 40,),
                    SizedBox(height: 2,),
                    Text("Chat",style: AppStyle.font14MediumBlack87.override(fontSize: 14),)
                  ],
                ),
                  onTap: () async {
                    String? userId = await PreferenceUtils.getUserId();
                    PageNavigation.gotoChatPage(context, userId!, "admin","driver");
                  },),
              ],
            ),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text("Today's Dashboard",style: AppStyle.font14MediumBlack87.override(fontSize: 16),),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.themeColor, // Background color
                            borderRadius: BorderRadius.circular(10.0), // Rounded corners
                            border: Border.all(
                              color: AppColors.themeColor, // Light gray border color
                              width: 2.0, // Border width
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Today Orders \nDelivered",
                                  textAlign: TextAlign.center,
                                  style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.white),
                                ),
                                SizedBox(height: 5,),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Background color
                                    borderRadius: BorderRadius.circular(40.0), // Rounded corners
                                    border: Border.all(
                                      color: Colors.white, // Light gray border color
                                      width: 2.0, // Border width
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      _con.mainPageResponse.data!.todaycount.toString(),
                                      textAlign: TextAlign.center,
                                      style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.themeColor, // Background color
                            borderRadius: BorderRadius.circular(10.0), // Rounded corners
                            border: Border.all(
                              color: AppColors.themeColor, // Light gray border color
                              width: 2.0, // Border width
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Current Picked \nOrders",
                                  textAlign: TextAlign.center,
                                  style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.white),
                                ),
                                SizedBox(height: 5,),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Background color
                                    borderRadius: BorderRadius.circular(40.0), // Rounded corners
                                    border: Border.all(
                                      color: Colors.white, // Light gray border color
                                      width: 2.0, // Border width
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      _con.mainPageResponse.data!.currentcount.toString(),
                                      textAlign: TextAlign.center,
                                      style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.themeColor, // Background color
                            borderRadius: BorderRadius.circular(10.0), // Rounded corners
                            border: Border.all(
                              color: AppColors.themeColor, // Light gray border color
                              width: 2.0, // Border width
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Today Other \nServices",
                                  textAlign: TextAlign.center,
                                  style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.white),
                                ),
                                SizedBox(height: 5,),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Background color
                                    borderRadius: BorderRadius.circular(40.0), // Rounded corners
                                    border: Border.all(
                                      color: Colors.white, // Light gray border color
                                      width: 2.0, // Border width
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      _con.mainPageResponse.data!.todayotherservicecount.toString(),
                                      textAlign: TextAlign.center,
                                      style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.themeColor, // Background color
                            borderRadius: BorderRadius.circular(10.0), // Rounded corners
                            border: Border.all(
                              color: AppColors.themeColor, // Light gray border color
                              width: 2.0, // Border width
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Pending Other \nServices",
                                  textAlign: TextAlign.center,
                                  style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.white),
                                ),
                                SizedBox(height: 5,),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Background color
                                    borderRadius: BorderRadius.circular(40.0), // Rounded corners
                                    border: Border.all(
                                      color: Colors.white, // Light gray border color
                                      width: 2.0, // Border width
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      _con.mainPageResponse.data!.overallotherservicecount.toString(),
                                      textAlign: TextAlign.center,
                                      style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.themeColor, // Background color
                            borderRadius: BorderRadius.circular(10.0), // Rounded corners
                            border: Border.all(
                              color: AppColors.themeColor, // Light gray border color
                              width: 2.0, // Border width
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "In Hand Amount",
                                  textAlign: TextAlign.center,
                                  style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.white),
                                ),
                                SizedBox(height: 5,),
                                Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Background color
                                    borderRadius: BorderRadius.circular(40.0), // Rounded corners
                                    border: Border.all(
                                      color: Colors.white, // Light gray border color
                                      width: 2.0, // Border width
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      _con.mainPageResponse.data!.inHandAmount!=null ? ApiConstants.currency+_con.mainPageResponse.data!.inHandAmount.toString():"0",
                                      textAlign: TextAlign.center,
                                      style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    ):Container();
  }
}
