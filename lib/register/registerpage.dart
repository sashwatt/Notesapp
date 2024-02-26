import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../bean/ServiceResponse.dart';
import '../utils/Base64Utils.dart';

class RegisterPage extends StatefulWidget{

  @override
  _RegisterWidget createState () => _RegisterWidget();
}

class _RegisterWidget extends State<RegisterPage>{

  late  TextEditingController _emailController;
  late  TextEditingController _passwordController;
  late  TextEditingController _confController;
  late bool _obscureText = true;
  late bool _obscureConfText = true;
  late bool _checkBoxValue = false;


  bool isEmail(String value) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');

    return emailRegex.hasMatch(value);
  }

  void showToast(String content) async {
    try {
      await _channel.invokeMethod('AppToast', {"content": content});
    } catch (e) {
      print("Error Invoke: $e");
    }
  }

  void verifyRegisterData(){
    late String? emailValue = _emailController.text;
    late String? passwordValue = _passwordController.text;
    late String? cfValue = _confController.text;

    if(emailValue == null || emailValue.isEmpty){
      showToast("Email Cant Null");
      return;
    }
    if(passwordValue == null || passwordValue.isEmpty){
      showToast("Password Cant Null");
      return;
    }
    if(cfValue == null || cfValue.isEmpty){
      showToast("Password Cant Null");
      return;
    }
    if(cfValue != passwordValue){
      showToast("The two passwords do not match");
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

    register(emailValue, passwordValue);
  }

  Future<void> register(String email,String password) async{
    var headers = {'Content-Type': 'application/json'};
    var data = json.encode({"email": Base64Utils.encryption(email), "password": Base64Utils.encryption(password)});
    var dio = Dio();
    var response = await dio.request('https://www.jtxqbu.top/user/register', options: Options(method: 'POST', headers: headers,), data: data,);
    if (response.statusCode == 200) {
      ServiceResponse serviceResponse = ServiceResponse.fromJson(response.data);
      showToast(serviceResponse.msg);
      if(serviceResponse.code == 200){
        Navigator.of(context).pop();
      }
    }
    else {
      showToast(response.statusMessage!!);
    }
  }


  final MethodChannel _channel = const MethodChannel('Flutter_X-NotePad_CHANNEL_V1.0.0');

  void _openUserAgreement(String url) async {
    try {
      await _channel.invokeMethod('UserAgreement', {"url": url});
    } catch (e) {
      print("Error Invoke: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confController = TextEditingController();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(backgroundColor: Colors.white,centerTitle: true,title: Text('Register',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)),body: Container(height: MediaQuery.of(context).size.height,color: Colors.black,child:
    SingleChildScrollView(child: Padding(padding: EdgeInsets.only(left: 10,right: 10,top: 20),child: Card(shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    ),elevation: 3,color: Colors.white,child:
    Column(crossAxisAlignment: CrossAxisAlignment.center,children: [
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
              prefixIcon: const Icon(Icons.lock_clock_outlined),
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

      Padding(
        padding:const EdgeInsets.only(top: 25,left: 10,right: 10),
        child: TextField(
          obscureText: _obscureConfText,
          controller: _confController,
          decoration: InputDecoration(
              hintText: 'Confirm Password',
              hintStyle: const TextStyle(color: Colors.grey),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelText: "Confirm Password",
              prefixIcon: const Icon(Icons.password),
              suffixIcon: IconButton(
                  icon: _obscureConfText ? Icon(Icons.visibility, color: Colors.black) : Icon(Icons.visibility_off, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _obscureConfText = !_obscureConfText;
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

      Padding(padding: const EdgeInsets.only(top: 50,left: 10,right: 10,bottom: 50),child: ElevatedButton(onPressed: () async{
        verifyRegisterData();
      }, style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
      ), child: Container(width: double.infinity,child: const Text("Submit",textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),),))),
    ],),),),),));
  }
}