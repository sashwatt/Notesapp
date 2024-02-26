import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:note/event/Event.dart';
import '../bean/ServiceResponse.dart';
import '../event/EventBusCallBack.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/Base64Utils.dart';

class WriteNotePad extends StatefulWidget{

  @override
  _WriteNotePadWidget createState() => _WriteNotePadWidget();
}

final LOCATION_SP_USER_INFO_ID_KEY = "LOCATION_SP_USER_INFO_ID_KEY";
class _WriteNotePadWidget extends State<WriteNotePad>{
  List<String> options = ['work', 'save', 'family','important password','record','other'];
  String selectedValue =  "work";
  String uid = "";
  late SharedPreferences prefs;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  final MethodChannel _channel = const MethodChannel('Flutter_X-NotePad_CHANNEL_V1.0.0');

  void showToast(String content) async {
    try {
      await _channel.invokeMethod('AppToast', {"content": content});
    } catch (e) {
      print("Error Invoke: $e");
    }
  }

  Future<void> initSp() async{
    prefs = await SharedPreferences.getInstance();
    
    if(prefs != null){
      if(prefs.getString(LOCATION_SP_USER_INFO_ID_KEY) != null){
        uid = prefs.getString(LOCATION_SP_USER_INFO_ID_KEY)!!;
      }
    }
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSp();
  }

  void verityData (){
    late String title = _titleController.text;
    late String contentValue = _contentController.text;

    if(title.isEmpty){
      showToast("Title Cant Null");
      return;
    }
    if(contentValue.isEmpty){
      showToast("Content Cant Null");
      return;
    }

    addNotePad(Base64Utils.encryption(title),Base64Utils.encryption(contentValue),Base64Utils.encryption(selectedValue));
  }


  String nowTime(){
    DateTime now = DateTime.now();
    String formattedDate = "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}";

    return formattedDate;
  }

  Future<void> addNotePad(String title,String content,String options) async{
    var headers = {'Content-Type': 'application/json'};
    var data = json.encode({"title": title, "content": content, "createtime": Base64Utils.encryption(nowTime()), "type": options, "uid": uid});
    var dio = Dio();
    var response = await dio.request('https://www.jtxqbu.top/note/addNote', options: Options(method: 'POST', headers: headers,), data: data,);
    if (response.statusCode == 200) {
      ServiceResponse serviceResponse = ServiceResponse.fromJson(response.data);
      showToast(serviceResponse.msg);
      if(serviceResponse.code == 200){
        EventBusCallBack.eventBus.fire(EventData(code: "200", msg: "refresh"));
        Navigator.of(context).pop();
      }
    }
    else {
      showToast(response.statusMessage!!);
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(centerTitle: true,title: Text("NotePad",style: TextStyle(color: Colors.black,fontSize: 25,fontWeight: FontWeight.bold),),),
      body: Container(color: Colors.black,width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,child: SingleChildScrollView(child:
      Padding(padding: EdgeInsets.only(left: 10,right: 10,top: 25),child: Card(elevation: 3,child: Padding(padding: EdgeInsets.only(left: 10,right: 10,top: 20),child:
        Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          DropdownButton<String>(
            value: selectedValue,
            isExpanded: true,
            iconSize: 25,
            isDense: false,
            iconEnabledColor: Colors.black,
            iconDisabledColor: Colors.green,
            borderRadius: BorderRadius.circular(20),
            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
            onChanged: (String? newValue) {
              setState(() {
                selectedValue = newValue!;
              });
            },
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
              );
            }).toList(),
          ),
          Padding(
            padding:const EdgeInsets.only(left: 10,right: 10,top: 15),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: const TextStyle(color: Colors.grey),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: "Title",
                  prefixIcon: const Icon(Icons.title),
                  labelStyle: const TextStyle(fontSize: 20),
                  enabledBorder:  OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black), borderRadius: BorderRadius.circular(5)),
                  focusedBorder:  OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.blue), borderRadius: BorderRadius.circular(5))
              ),
            ),
          ),
          const SizedBox(height: 20,),
          Padding(
            padding:const EdgeInsets.only(left: 10,right: 10),
            child: TextField(
              controller: _contentController,
              maxLines: 10,
              minLines: 10,
              decoration: InputDecoration(
                  hintText: 'Content',
                  hintStyle: const TextStyle(color: Colors.grey),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: "Content",
                  labelStyle: const TextStyle(fontSize: 20),
                  enabledBorder:  OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black), borderRadius: BorderRadius.circular(5)),
                  focusedBorder:  OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.blue), borderRadius: BorderRadius.circular(5))
              ),
            ),
          ),
          
          Padding(padding: const EdgeInsets.only(left: 10,right: 10,top: 25,bottom: 30),child: ElevatedButton(onPressed: (){
            verityData();
          }, child: const SizedBox(width: double.infinity,child: Text("Submit",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),)),)
        ],),),),),),),);
  }
}