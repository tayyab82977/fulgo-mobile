import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xturbox/blocs/bloc/LoginBloc.dart';
import 'package:xturbox/blocs/bloc/authentication_bloc.dart';
import 'package:xturbox/blocs/events/authentication_events.dart';
import 'package:xturbox/blocs/states/authentication_state.dart';
import 'package:xturbox/data_providers/apis/EventsApi.dart';
import 'package:xturbox/data_providers/models/ResponseViewModel.dart';
import 'package:xturbox/data_providers/models/resourcstDataModel.dart';
import 'package:xturbox/main.dart';
import 'package:lottie/lottie.dart';
import 'package:xturbox/ui/common/chooseLanguageScreen.dart';
import 'package:xturbox/ui/custom%20widgets/myAppBar.dart';
import 'package:xturbox/ui/custom%20widgets/my_container.dart';
import 'package:xturbox/ui/common/dashboard.dart';
import 'package:xturbox/utilities/Constants.dart';


import '../../UserRepo.dart';


class SplashScreen extends StatefulWidget {


  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {


  AuthenticationBloc authenticationBloc = AuthenticationBloc() ;
  AnimationController? _controller;


  @override
  void initState() {
    super.initState();
    authenticationBloc.add(AppStarted());
    _controller = AnimationController(vsync: this , duration: Duration(seconds: 5) );
    _controller!.forward().whenComplete(() {
      authenticationBloc.add(Decision());
    });
  }

  @override
  void dispose() {
    authenticationBloc.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size ;
    double screenHeight = size.width ;
    double screenWidth = size.width;
    return BlocBuilder<AuthenticationBloc , AuthenticationState>(
      bloc: authenticationBloc,
      // bloc: widget.authenticationBloc,
      builder: (context, state){
        if(state is AuthenticationUninitialized){
          return Scaffold(
            backgroundColor: Color(0xffFBFBFB),
              body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          EasyLocalization.of(context)!.locale == Locale('en') ? Expanded(
                          child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xffFBFBFB),
                          ),
                          child: Lottie.asset('assets/images/en.json',
                              controller: _controller,
                              width: screenWidth,
                              height: screenHeight),
                        ))
                      : Expanded(
                          child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xffFBFBFB),
                          ),
                          child: Lottie.asset('assets/images/ar.json',
                              controller: _controller,
                              onLoaded: (composition) {},
                              width: screenWidth,
                              height: screenHeight),
                        ))
                ],
              ));
        }
       else if(state is AuthenticationError){

          return  SafeArea(
            child:Scaffold(

              // drawer: Drawer(),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const ClientAppBar(),
                  SizedBox(height: 150,),
                  Center(
                    child: Text('Please check your internet Connection and try again'.tr(),
                      style:TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal
                      ),
                    ),
                  ),
                  SizedBox(height: 50,),

                  // MaterialButton(
                  //   onPressed: (){
                  //
                  //     // RestartWidget.restartApp(context);
                  //     RestartWidget.restartApp(context);
                  //   },
                  //   shape: RoundedRectangleBorder(),
                  //   color:  Colors.blue,
                  //   child: Text('Retry'.tr(),
                  //     style:TextStyle(
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.bold,
                  //       color: Colors.white
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ) ,
          );


        }
       else if (state is AuthenticationAuthenticated){

          return ResourcesScreen(resourcesData: state.resourcesData,);
        }
       else if (state is AuthenticationUnauthenticated){

          return ChooseLanguageScreen(resourcesData: state.resourcesData,);
        }
       else if (state is AuthenticationUpdate){
         return Scaffold(
             appBar: AppBar(
               title: Text('Xturbo'),
             ),
           body: Container(
             width: MediaQuery.of(context).size.width,
             height: MediaQuery.of(context).size.width,
             child: Center(
             child:  Text ('please update the application to be able to continue'.tr(),
             style: TextStyle(
               fontSize: 14,
               fontWeight: FontWeight.bold
             ),
             )
             ),
           ),
         );

        }
        return Container();
      },
    );
  }
}
