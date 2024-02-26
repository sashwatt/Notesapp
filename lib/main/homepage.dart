import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:note/login/loginpage.dart';
import 'package:note/notepad/writenotepad.dart';
import 'package:note/utils/Base64Utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../bean/NotePadBean.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bean/ServiceResponse.dart';
import '../event/Event.dart';
import '../event/EventBusCallBack.dart';
import '../notepad/updateNotePad.dart';

class HomePage extends StatefulWidget{

  @override
  _HomeWidget createState () => _HomeWidget();
}

final LOCATION_SP_USER_INFO_KEY = "USER_LOCATION_DATA_KEY";
final LOCATION_SP_USER_INFO_ID_KEY = "LOCATION_SP_USER_INFO_ID_KEY";


class _HomeWidget extends State<HomePage>{
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  late SharedPreferences prefs;
  List<NotePadBean> items = [];

  Future<void> initEventBus() async{
    EventBusCallBack.eventBus.on<EventData>().listen((event) {
      _onRefresh();
    });
  }

  Future<void> initSharedPreferences() async{
    prefs = await SharedPreferences.getInstance();
    if(prefs != null){
      if(prefs.getString(LOCATION_SP_USER_INFO_KEY) != null){
        userEmila = prefs.getString(LOCATION_SP_USER_INFO_KEY)!!;
        uid = prefs.getString(LOCATION_SP_USER_INFO_ID_KEY)!!;
        notePadList();
      }
    }
  }

  Future<void> notePadList() async{
    var headers = {'Content-Type': 'application/json'};
    var data = json.encode({"noteId": notePadId, "uid": uid});
    var dio = Dio();
    var response = await dio.request('https://www.jtxqbu.top/note/noteList', options: Options(method: 'POST', headers: headers,), data: data,);
    if (response.statusCode == 200) {
      ServiceResponse serviceResponse = ServiceResponse.fromJson(response.data);
      if(serviceResponse.code == 200){
        if (serviceResponse.data is List) {
          List<NotePadBean> infoData = (serviceResponse.data as List<dynamic>)
              .map((item) => NotePadBean.fromJson(item as Map<String, dynamic>))
              .toList();

          setState(() {
            items.addAll(infoData);
          });
        }
      }
    }
    else {
      showToast(response.statusMessage!!);
    }
  }

  late String userEmila = "Default";
  late String uid = "MQ==";
  late String notePadId = "MA==";



  void _onRefresh() async {
    notePadId = "MA==";
    setState(() {
      items.clear();
    });
    notePadList();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    notePadId = Base64Utils.encryption(items.last.id.toString());
    notePadList();
    _refreshController.loadComplete();
  }


  @override
  void initState() {
    super.initState();
    initSharedPreferences();
    initEventBus();
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

  Future<void> removeUser() async{
    var headers = {'Content-Type': 'application/json'};
    var data = json.encode({"emil": userEmila});
    var dio = Dio();
    var response = await dio.request('https://www.jtxqbu.top/action/deleteUser', options: Options(method: 'POST', headers: headers,), data: data,);
    if (response.statusCode == 200) {
      ServiceResponse serviceResponse = ServiceResponse.fromJson(response.data);
      showToast(serviceResponse.msg);
      if(serviceResponse.code == 200){
        prefs.setString(LOCATION_SP_USER_INFO_KEY, "");
        prefs.setString(LOCATION_SP_USER_INFO_ID_KEY, "");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()),);
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
                Text('Do you confirm that you need to delete this account? All your data will be cleared and you will no longer be able to log in.'),
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
                removeUser();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Sashwat's-NotePad",style: TextStyle(color: Colors.white),),centerTitle: true,backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white),),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[ const DrawerHeader(decoration: BoxDecoration(color: Colors.black,),
            child: Align(alignment: Alignment.centerLeft,child: Text("Sashwat's-NotePad", style: TextStyle(color: Colors.white, fontSize: 24,),),)),

          ListTile(
            leading: const Icon(Icons.supervised_user_circle_rounded),
            title: const Text('User',style: TextStyle(fontSize: 14,color: Colors.black),),
            onTap: () {
                showToast("Now User: ${Base64Utils.decrypt(userEmila)}");
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy and Policies',style: TextStyle(fontSize: 14,color: Colors.black),),
            onTap: () {
              _openUserAgreement("http://43.134.44.230/Privacy%20Policy%20for%20X-NotePad.html");
              },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: Text('Log-Out',style: const TextStyle(fontSize: 14,color: Colors.black),),
            onTap: () {
              prefs.setString(LOCATION_SP_USER_INFO_KEY, "");
              prefs.setString(LOCATION_SP_USER_INFO_ID_KEY, "");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            }
          ),
          ListTile(
            leading: const Icon(Icons.remove_circle),
            title: Text('Delete Account',style: const TextStyle(fontSize: 14,color: Colors.red),),
            onTap: () {
              _showConfirmationDialog(context);
              },
          ),
        ],
        ),
      ),
        body: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: ListView.separated(
            padding: const EdgeInsets.only(left: 10,right: 10),
            itemCount: items.length,
            separatorBuilder: (context,index){
              return SizedBox(height: 6,);
            },
            itemBuilder: (context, index) {
              return InkWell(
                onTap: (){
                  Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) => UpdateNotePadPage(id: items[index].id.toString(),options: items[index].type,title: items[index].title,content: items[index].content,),),);
                },
                child: Card(elevation: 5,shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),child: Padding(padding: EdgeInsets.only(left: 10,right: 10,bottom: 10,top: 10),child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                  Text(items[index].title,style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis,),
                  const SizedBox(height: 5,),
                  Text("${items[index].createtime} : ${items[index].content}",style: TextStyle(color: Colors.grey,fontSize: 13),maxLines: 1,overflow: TextOverflow.ellipsis,),
                  Row(children: [
                    Expanded(flex: 1,child: Container(color: Colors.black,))
                  ],)
                ],),)),
              );
            },
          ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) => WriteNotePad(),),);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}