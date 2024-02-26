package com.tools.notepad.text.sp.note

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    companion object{
        const val CHANNEL_NAME = "Flutter_X-NotePad_CHANNEL_V1.0.0"
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        flutterInvoke()
    }

    private fun flutterInvoke(){
        val channel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL_NAME)

        if (flutterEngine != null){
            channel.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                when(call.method){
                    "UserAgreement" ->{
                        val url = call.argument<String>("url")
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                        startActivity(intent)
                    }
                    "AppToast" ->{
                        val content = call.argument<String>("content")
                        Toast.makeText(this,content,Toast.LENGTH_LONG).show()
                    }
                }
            }
        }
    }
}
