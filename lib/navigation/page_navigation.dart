import 'package:driver/model/service/service_response_model.dart';
import 'package:driver/page/dashboard/dashboard_page.dart';
import 'package:driver/page/dashboard/order/order_details_page.dart';
import 'package:driver/page/dashboard/service/service_details_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../page/login/login_page.dart';

class PageNavigation{


  static gotoLoginScreen(BuildContext context){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  static gotoDashboardPage(BuildContext context){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const DashBoardPage(),
      ),
    );
  }

  static gotoOrderDetailsPage(BuildContext context,orderBean){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(orderBean),
      ),
    );
  }

  static gotoServiceDetailsPage(BuildContext context, Service serviceBean){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailsPage(serviceBean),
      ),
    );
  }



  static goLogout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    gotoLoginScreen(context);
  }

}