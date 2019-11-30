package com.example.app_launcher

import android.content.Intent
import android.os.Bundle
import android.widget.Toast

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  private val CHANNEL = "com.tangs.com/launch"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      if (call.method == "launch") {
        val pkg = call.argument<String>("pkg")
        val url = call.argument<String>("url")
        launchApp(pkg, url)
      }
    }
  }

  private fun launchApp(pkg: String?, url: String?) {
//    Intent()
    var msg = "pak: " + pkg + ", url: " + url
    Toast.makeText(this, msg, Toast.LENGTH_LONG).show()
  }
}
