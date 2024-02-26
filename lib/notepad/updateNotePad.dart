import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:note/event/Event.dart';
import 'package:note/utils/Base64Utils.dart';
import '../bean/ServiceResponse.dart';
import '../event/EventBusCallBack.dart';

class UpdateNotePadPage extends StatefulWidget{
  String id;
  String options;
  String title;
  String content;

  UpdateNotePadPage({required this.id,required this.options,required this.title,required this.content});

  @override
  _UpdateNotePadWidget createState () => _UpdateNotePadWidget();
}


class _UpdateNotePadWidget extends State<UpdateNotePadPage>{

  List<String> options = ['work', 'save', 'family','important password','record','other'];
  String selectedValue =  "work";
  String noteId = "";
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    noteId = widget.id;
    selectedValue = widget.options;
    _titleController = TextEditingController(text: widget.title);
    _contentController = TextEditingController(text: widget.content);

    print(nowTime());
  }



  void verityUpdateData (){
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

    updateNotePad(Base64Utils.encryption(title),Base64Utils.encryption(contentValue),Base64Utils.encryption(selectedValue));
  }

  final MethodChannel _channel = const MethodChannel('Flutter_X-NotePad_CHANNEL_V1.0.0');

  void showToast(String content) async {
    try {
      await _channel.invokeMethod('AppToast', {"content": content});
    } catch (e) {
      print("Error Invoke: $e");
    }
  }

  String nowTime(){
    DateTime now = DateTime.now();
    String formattedDate = "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}";

    return formattedDate;
  }

  Future<void> updateNotePad(String title,String content,String options) async{
    var headers = {'Content-Type': 'application/json'};
    var data = json.encode({"id": Base64Utils.encryption(noteId), "title": title, "content": content, "type": options,"createtime":Base64Utils.encryption(nowTime())});
    var dio = Dio();
    var response = await dio.request('https://www.jtxqbu.top/note/updateNote', options: Options(method: 'POST', headers: headers,), data: data,);
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


  Future<void> deleteNotePad() async{
    var headers = {'Content-Type': 'application/json'};
    var data = json.encode({"noteId": Base64Utils.encryption(noteId)});
    var dio = Dio();
    var response = await dio.request('https://www.jtxqbu.top/note/deleteNote', options: Options(method: 'POST', headers: headers,), data: data,);
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

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Confirm whether the record needs to be deleted?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm',style: TextStyle(color: Colors.redAccent),),
              onPressed: () {
                deleteNotePad();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(centerTitle: true,title: Text("Update NotePad",style: TextStyle(color: Colors.black,fontSize: 25,fontWeight: FontWeight.bold),),),
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
                counterText: widget.title,
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

        Padding(padding: const EdgeInsets.only(left: 10,right: 10,top: 25),child: ElevatedButton(onPressed: (){
          verityUpdateData();
        }, child: const SizedBox(width: double.infinity,child: Text("Update",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),)),),
        Padding(padding: const EdgeInsets.only(left: 10,right: 10,top: 15,bottom: 30),child: ElevatedButton(onPressed: (){
          _showConfirmationDialog(context);
          }, child: const SizedBox(width: double.infinity,child: Text("Delete",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.redAccent),),)),),
      ],),),),),),),);
  }
}