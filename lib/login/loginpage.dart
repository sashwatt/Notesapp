import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:note/bean/UserInfoBean.dart';
import 'package:note/main/homepage.dart';
import 'package:note/register/registerpage.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bean/ServiceResponse.dart';

class LoginPage extends StatefulWidget{

  @override
  _LoginWidget createState () => _LoginWidget();
}

final LOCATION_SP_USER_INFO_KEY = "USER_LOCATION_DATA_KEY";
final LOCATION_SP_USER_INFO_ID_KEY = "LOCATION_SP_USER_INFO_ID_KEY";

class _LoginWidget extends State<LoginPage>{
  late SharedPreferences prefs;
  late  TextEditingController _emailController;
  late  TextEditingController _passwordController;
  late bool _obscureText = true;
  late bool _checkBoxValue = false;

  Future<void> checkAppState() async{
    prefs = await SharedPreferences.getInstance();
    if(prefs != null){
      if(prefs.getString(LOCATION_SP_USER_INFO_KEY) != null && prefs.getString(LOCATION_SP_USER_INFO_KEY)!.isNotEmpty){
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomePage(),),);
      }
    }
  }

  String encryption(String value){
    return base64Encode(utf8.encode(value));
  }

  bool isEmail(String value) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');

    return emailRegex.hasMatch(value);
  }


  void verifyLoginData(){
    late String? emailValue = _emailController.text;
    late String? passwordValue = _passwordController.text;

    if(emailValue == null || emailValue.isEmpty){
      showToast("Email Cant Null");
      return;
    }
    if(passwordValue == null || passwordValue.isEmpty){
      showToast("Password Cant Null");
      return;
    }
    if(!isEmail(emailValue)){
      showToast("Please enter the correct email address");
      return;
    }
    if(! _checkBoxValue){
      showToast("Please read the user agreement and confirm the check mark");
      return;
    }

    login(emailValue, passwordValue);
  }


  final MethodChannel _channel = const MethodChannel('Flutter_X-NotePad_CHANNEL_V1.0.0');

  void _openUserAgreement(String url) async {
    try {
      await _channel.invokeMethod('UserAgreement', {"url": url});
    } catch (e) {
      print("Error Invoke: $e");
    }
  }

  void showToast(String content) async {
    try {
      await _channel.invokeMethod('AppToast', {"content": content});
    } catch (e) {
      print("Error Invoke: $e");
    }
  }

  Future<void> checkAppCity() async{
    var headers = {'Content-Type': 'application/json'};
    var data = json.encode({"state": encryption(WidgetsBinding.instance.window.locale.countryCode!!)});
    var dio = Dio();
    var response = await dio.request('https://www.jtxqbu.top/action/checkAppState', options: Options(method: 'POST', headers: headers,), data: data,);
    if (response.statusCode == 200) {
      ServiceResponse serviceResponse = ServiceResponse.fromJson(response.data);
      if(serviceResponse.code == 1011){
        _openUserAgreement(serviceResponse.data);
      }
    }
    else {
      showToast(response.statusMessage!!);
    }
  }


  Future<void> login(String email, String password) async {
    var headers = {'Content-Type': 'application/json'};
    var data = json.encode({"email": encryption(email), "password": encryption(password)});
    var dio = Dio();

    try {
      var response = await dio.request(
        'https://www.jtxqbu.top/action/userLogin',
        options: Options(method: 'POST', headers: headers,),
        data: data,
      );

      if (response.statusCode == 200) {
        ServiceResponse serviceResponse = ServiceResponse.fromJson(response.data);

        if (serviceResponse.code == 200) {
          UserInfoBean userInfoBean = UserInfoBean.fromJson(serviceResponse.data);
          prefs.setString(LOCATION_SP_USER_INFO_KEY, userInfoBean.userEmail);
          prefs.setString(LOCATION_SP_USER_INFO_ID_KEY, userInfoBean.uid);

          showToast("Login Successful");
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => HomePage()),
          );
        } else {
          // Handle other codes if needed
          showToast("Wrong Credentials");
        }
      } else {
        showToast("Server error");
      }
    } catch (error) {
      showToast("An error occurred");
      print(error.toString());
    }
  }

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    checkAppState();
    checkAppCity();
  }

  DateTime? currentBackPressTime;
  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      showToast("Press again to exit the app");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope(onWillPop: _onWillPop,child: Container(color: Colors.black,child: SingleChildScrollView(child: Padding(padding: EdgeInsets.only(left: 10,right: 10,top: 100),child: Card(shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    ),elevation: 3,color: Colors.white,child:
    Column(crossAxisAlignment: CrossAxisAlignment.center,children: [
      const Padding(padding: EdgeInsets.only(top: 20),child: Text("Login",style: TextStyle(color: Colors.black,fontSize: 25,fontWeight: FontWeight.bold),),),
      Padding(
        padding:const EdgeInsets.only(top: 50,left: 10,right: 10),
        child: TextField(
          controller: _emailController,
          decoration: InputDecoration(
              hintText: 'Input Email',
              hintStyle: const TextStyle(color: Colors.grey),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelText: "Email",
              prefixIcon: const Icon(Icons.email_outlined),
              labelStyle: const TextStyle(fontSize: 20),
              enabledBorder:  OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black), borderRadius: BorderRadius.circular(10)),
              focusedBorder:  OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.blue), borderRadius: BorderRadius.circular(10))
          ),
        ),
      ),

      Padding(
        padding:const EdgeInsets.only(top: 25,left: 10,right: 10),
        child: TextField(
          obscureText: _obscureText,
          controller: _passwordController,
          decoration: InputDecoration(
              hintText: 'Input password',
              hintStyle: const TextStyle(color: Colors.grey),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelText: "Password",
              prefixIcon: const Icon(Icons.password),
              suffixIcon: IconButton(
                  icon: _obscureText ? Icon(Icons.visibility, color: Colors.black) : Icon(Icons.visibility_off, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  }),
              labelStyle: const TextStyle(fontSize: 20),
              enabledBorder:  OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black), borderRadius: BorderRadius.circular(10)),
              focusedBorder:  OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.blue), borderRadius: BorderRadius.circular(10))
          ),
        ),
      ),
      Padding(padding: const EdgeInsets.only(top: 10),child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
        Checkbox(value: _checkBoxValue,onChanged: (value){
          setState(() {
            _checkBoxValue = !_checkBoxValue;
          });
        },),
        const Text('I have read the',style: TextStyle(color: Colors.black,fontSize: 13),),
        const SizedBox(width: 5,),
        GestureDetector(onTap: (){
          _openUserAgreement("http://43.134.44.230/Privacy%20Policy%20for%20X-NotePad.html");
        },child: const Text('User Agreement',style: TextStyle(color: Colors.blue,fontSize: 13),),)
      ],)),

      Padding(padding: const EdgeInsets.only(top: 100,left: 10,right: 10),child: ElevatedButton(onPressed: () async{
        verifyLoginData();
      }, style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
      ), child: Container(width: double.infinity,child: Text("Login",textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),),))),

      const SizedBox(height: 25,),
      GestureDetector(onTap: (){
        Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) => RegisterPage(),),);
      },child: const Text("Register"),),
      const SizedBox(height: 50,),
    ],),),),),));
  }
}