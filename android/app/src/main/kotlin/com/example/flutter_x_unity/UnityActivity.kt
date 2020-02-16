package com.example.flutter_x_unity

import android.os.Bundle

import androidx.annotation.NonNull
import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.util.Log
import android.view.View
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import com.example.flutter_x_unity.MainUnityActivity

class UnityActivity: AppCompatActivity() {

    internal var isUnityLoaded = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_unity)
        val toolbar = findViewById(R.id.toolbar) as Toolbar
        setSupportActionBar(toolbar)

        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
        setIntent(intent)
    }

    internal fun handleIntent(intent: Intent?) {
        if (intent == null || intent.extras == null) return

        if (intent.extras!!.containsKey("setColor")) {
            val v = findViewById(R.id.button2) as Button
            when (intent.extras!!.getString("setColor")) {
                "yellow" -> v.setBackgroundColor(Color.YELLOW)
                "red" -> v.setBackgroundColor(Color.RED)
                "blue" -> v.setBackgroundColor(Color.BLUE)
                else -> {
                }
            }
        }
    }

    fun btnLoadUnity(v: View) {
        isUnityLoaded = true
        val intent = Intent(this, MainUnityActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        startActivityForResult(intent, 1)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1) isUnityLoaded = false
    }

    fun unloadUnity(doShowToast: Boolean?) {
        if (isUnityLoaded) {
            val intent = Intent(this, MainUnityActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
            intent.putExtra("doQuit", true)
            startActivity(intent)
            isUnityLoaded = false
        } else if (doShowToast!!) showToast("Show Unity First")
    }

    fun btnUnloadUnity(v: View) {
        unloadUnity(true)
    }

    fun showToast(message: String) {
        val duration = Toast.LENGTH_SHORT
        val toast = Toast.makeText(applicationContext, message, duration)
        toast.show()
    }

    override fun onBackPressed() {
        setResult(1)
        finish()
    }
}
