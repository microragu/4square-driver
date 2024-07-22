

import 'package:driver/constants/api_constants.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/flutter_flow/flutter_flow_theme.dart';
import 'package:driver/page/dashboard/service/service_details_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../constants/app_style.dart';
import '../../../controller/home_controller.dart';
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
                                        Text(
                                          TimeUtils.convertUTC(serviceBean.fromtime!),
                                          style: AppStyle.font14MediumBlack87.override(fontSize: 14,color: Colors.grey.shade500),
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

                                    Divider(
                                      color: Colors.grey.shade500,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "",
                                          style: AppStyle.font18BoldWhite.override(fontSize: 12),
                                        ),
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
                                    ),
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
      ):Container(),
    );
  }


}
