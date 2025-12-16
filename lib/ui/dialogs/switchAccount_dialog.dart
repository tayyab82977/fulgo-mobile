import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:xturbox/blocs/bloc/switchAccount_bloc.dart';
import 'package:xturbox/blocs/events/switchAccount_events.dart';
import 'package:xturbox/blocs/states/switchAccount_states.dart';
import 'package:xturbox/ui/common/dashboard.dart';
import 'package:xturbox/ui/custom%20widgets/custom_loading.dart';
import 'package:xturbox/utilities/Constants.dart';

import '../../utilities/comFunctions.dart';

class SwitchAccountDialog extends StatefulWidget {
  String name ;
  String phone ;
  String password ;
  SwitchAccountDialog({required this.name,required this.phone, required this.password}) ;

  @override
  _SwitchAccountDialogState createState() => _SwitchAccountDialogState();
}

class _SwitchAccountDialogState extends State<SwitchAccountDialog> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<SwitchAccountBloc,SwitchAccountStates>(
      listener: (context , state ){
        if(state is SwitchAccountLoading){
          Loader.show(context,progressIndicator:CustomLoading());
        }else{
          Loader.hide();
        }
        if(state is SwitchAccountSetSuccess){
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ResourcesScreen(
              ),
            ),
                (route) => false,
          );
        }
        if(state is SwitchAccountError){
          state.errorList?.forEach((element) {
            ComFunctions.showToast(text: element);
          });
        }
      },
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15,),

              InkWell(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Constants.blueColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Column(
                      children: [
                        Text("Login with".tr(),style: TextStyle(color: Colors.white),),
                        Text(widget.name ,style: TextStyle(color: Colors.white,fontSize: 22),),
                      ],
                    )),
                  ),
                ),
                onTap: (){
                  BlocProvider.of<SwitchAccountBloc>(context).add(SwitchingAccount(phone: widget.phone, password: widget.password));
                },
              ),
              SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Constants.redColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text("Cancel".tr(),style: TextStyle(color: Colors.white),)),
                        ),
                      ),
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Spacer()

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
