import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../login/loginpage.dart';

class SplashPage extends StatefulWidget{


  @override
  _SplashWidget createState () => _SplashWidget();
}

class _SplashWidget extends State<SplashPage>{

  Future<void> startHomePage(BuildContext context) async {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => LoginPage(),),);
    });
  }

  @override
  Widget build(BuildContext context){
    startHomePage(context);

    return Center(child:Lottie.asset("images/ic_splash.json",animate: true),);
  }
}