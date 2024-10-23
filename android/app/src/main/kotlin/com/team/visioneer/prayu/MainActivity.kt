package com.team.visioneer.prayu

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.net.URISyntaxException

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.team.visioneer.prayu/scheme_intent"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(
            flutterEngine?.dartExecutor?.binaryMessenger ?: return,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "startSchemeIntent") {
                val url: String = call.argument("url") ?: ""
                val success = startSchemeIntent(url)
                if (success) {
                    result.success(true)
                } else {
                    result.error("UNAVAILABLE", "Scheme Intent could not be handled", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startSchemeIntent(url: String): Boolean {
    return try {
        // 'intent://'로 시작하는 URL을 처리
        val schemeIntent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)

        // 앱이 설치되어 있으면 해당 앱으로 이동
        startActivity(schemeIntent)
        true
    } catch (e: URISyntaxException) {
        Log.e("MainActivity", "URI Syntax Error: $e")
        false
    } catch (e: ActivityNotFoundException) {
        if (!url.startsWith("intent:#")) {
            // 앱이 설치되어 있지 않은 경우 Play 스토어로 이동
            try {
                val storeIntent = Intent(
                    Intent.ACTION_VIEW,
                    Uri.parse("market://details?id=com.kakao.talk")
                )
                startActivity(storeIntent)
            } catch (ex: ActivityNotFoundException) {
                Log.e("MainActivity", "Play Store not found: $ex")
            }
        } else {
            Log.i("MainActivity", "URL starts with #, skipping Play Store redirect.")
        }
        false
    }
}
}