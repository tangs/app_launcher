package com.example.app_launcher

import android.content.Intent
import android.content.pm.PackageManager
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
//    var msg = "pkg: " + pkg + ", url: " + url
//    Toast.makeText(this, msg, Toast.LENGTH_LONG).show()
    try {
      var bundle = Bundle()
      bundle.putBoolean("enableDevMode", true)
      bundle.putString("devMode_url", url)
      var intent = packageManager.getLaunchIntentForPackage(pkg)
      intent.putExtras(bundle)
      startActivity(intent)
    } catch (e: Exception) {
      Toast.makeText(this, "未找到程序,请确认包名是否正确.", Toast.LENGTH_LONG).show()
    }
  }
}
