import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/bloc/violations_bloc.dart';
import 'package:xturbox/blocs/events/violations_events.dart';
import 'package:xturbox/blocs/states/violations_states.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/data_providers/models/savedData.dart';
import 'package:xturbox/ui/courier/list_tiles/violations_card.dart';
import 'package:xturbox/ui/custom%20widgets/CaptainAppBar.dart';
import 'package:xturbox/ui/custom%20widgets/custom_loading.dart';
import 'package:xturbox/ui/custom%20widgets/drawerCaptain.dart';
import 'package:xturbox/ui/custom%20widgets/drawerDriver.dart';
import 'package:xturbox/utilities/Constants.dart';
import 'package:xturbox/utilities/comFunctions.dart';

class ViolationsScreen extends StatefulWidget {
  ResourcesData? resourcesData ;
  ViolationsScreen({this.resourcesData});
  @override
  _ViolationsScreenState createState() => _ViolationsScreenState();
}

class _ViolationsScreenState extends State<ViolationsScreen> {

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  double? screenWidth , screenHeight ;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return BlocProvider(
        create: (context)=>ViolationsBloc()..add(GetViolations()),
      child: Scaffold(
        key: _drawerKey,
        backgroundColor: Constants.greyColor,
        drawer:
        SavedData.profileDataModel.permission.toString() == "4" ?
        CaptainDrawer(
          resourcesData: widget.resourcesData,
        ) : DriverDrawer(
          resourcesData: widget.resourcesData,
        ),
        body: Column(
          children: [
            CaptainAppBar(
              drawerKey: _drawerKey, screenName: 'Violations'.tr(),
            ),
            SizedBox(height: 10,),
            Expanded(
              child: BlocConsumer<ViolationsBloc , ViolationsStates>(
                builder: (context , state){
                  if(state is ViolationsLoaded){
                    return RefreshIndicator(
                      onRefresh: () async{
                        BlocProvider.of<ViolationsBloc>(context).add(GetViolations());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: state.list.isNotEmpty ?
                        ListView.builder(
                            itemCount: state.list.length,
                            itemBuilder: (context , i ){
                              return ViolationsCard(violationModel: state.list[i]);
                            }) : ListView(
                          children: [
                            Center(child: Text("No Violations".tr(),style: TextStyle(fontSize: 19,color: Constants.blueColor),textAlign: TextAlign.center,))
                          ],
                        ),
                      ),
                    );
                  }
                  return CustomLoading();
                },
                listener: (context , state){
                  if(state is ViolationsError){
                    state.errorList?.forEach((element) {
                      ComFunctions.showToast(text:element , color: Colors.red);
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    
    
    
    );
  }
}
