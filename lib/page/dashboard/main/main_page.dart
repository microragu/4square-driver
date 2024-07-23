
import 'package:driver/constants/app_colors.dart';
import 'package:driver/constants/app_style.dart';
import 'package:driver/flutter_flow/flutter_flow_theme.dart';
import 'package:driver/navigation/page_navigation.dart';
import 'package:driver/utils/preference_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
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

  _MainPageState() : super(HomeController()) {
    _con = controller as HomeController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _con.listMainPage();
  }

  @override
  Widget build(BuildContext context) {

    return _con.mainPageResponse.data!=null ? Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      child: Image.asset("assets/images/sos.png",height: 50,),
                  onTap: (){
                        FlutterPhoneDirectCaller.callNumber(_con.mainPageResponse.data!.sos!);
                  },),
                  InkWell(child: Image.asset("assets/images/help.png",height: 50,),
                  onTap: () async {
                    String? userId = await PreferenceUtils.getUserId();
                    PageNavigation.gotoChatPage(context, userId!, "admin","driver");
                  },),
                ],
              ),
            ),
            SizedBox(height: 20,),
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
                              "Today Orders Delivered",
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
                              "Current Picked Orders",
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
                              "Today Other Services",
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
                              "Pending Other Services",
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
            )
          ],
        ),
      ),
    ):Container();
  }
}
