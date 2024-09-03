package com.team.visioneer.prayu

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.net.URISyntaxException

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.yourcompany.app/scheme_intent"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger ?: return, CHANNEL).setMethodCallHandler { call, result ->
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
        val schemeIntent: Intent = try {
            Intent.parseUri(url, Intent.URI_INTENT_SCHEME) // Intent 스킴을 파싱
        } catch (e: URISyntaxException) {
            return false
        }
        try {
            startActivity(schemeIntent) // 앱으로 이동
            return true
        } catch (e: ActivityNotFoundException) { // 앱이 설치 안 되어 있는 경우
            val packageName = schemeIntent.`package`

            if (!packageName.isNullOrBlank()) {
                startActivity(
                    Intent(
                        Intent.ACTION_VIEW,
                        Uri.parse("market://details?id=$packageName") // 스토어로 이동
                    )
                )
                return true
            }
        }
        return false
    }
}