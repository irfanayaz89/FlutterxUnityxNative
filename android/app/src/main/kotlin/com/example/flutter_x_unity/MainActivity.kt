package com.example.flutter_x_unity

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.widget.Toast

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.flutterxunity.unityview/channel"
    var methodChannel : MethodChannel? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        methodChannel = MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        methodChannel?.let { methodChannel ->

            methodChannel.setMethodCallHandler { call, result ->
                if (call.method.equals("openUnityView")) {
                    val intent = Intent(this, UnityActivity::class.java)
                    startActivityForResult(intent, 1)
                    result.success("Unity Activity for Android Started")
                    methodChannel.invokeMethod("unityViewCreated", true);
                } else {
                    result.notImplemented()
                }
            }
        }

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1 && resultCode == 1) {
            methodChannel?.invokeMethod("unityViewFinished", true);
        }
    }
}
