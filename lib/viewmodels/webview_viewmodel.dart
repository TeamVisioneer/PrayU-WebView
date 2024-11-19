import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:prayu_webview/services/firebase_sevice.dart';
import 'package:prayu_webview/views/show_network_error.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import '../models/webview_model.dart';

class WebViewViewModel {
  final WebViewModel model = WebViewModel();
  late WebViewController _controller;
  static const platform =
      MethodChannel('com.team.visioneer.prayu/scheme_intent');
  double initialSwipePosition = 0.0;
  double swipeThreshold = 120.0;
  bool isNavigating = false;
  int retryCount = 0;
  final int maxRetryAttempts = 3;

  WebViewController get controller => _controller;

  void initWebView(BuildContext context) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('intent:')) {
            _launchIntentURL(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageFinished: (url) {
          _saveFCMTokenToLocalStorage();
        },
        onWebResourceError: (WebResourceError error) async {
          if (retryCount < maxRetryAttempts) {
            retryCount++;
            await Future.delayed(const Duration(seconds: 1));
            _setUserAgentAndLoadPage();
          } else {
            FirebaseCrashlytics.instance.recordError(
              error,
              null,
              reason: 'WebView loading error: ${error.description}',
              fatal: true,
            );
            showNetworkError(context);
          }
        },
      ));
    _setUserAgentAndLoadPage();
  }

  Future<void> _saveFCMTokenToLocalStorage() async {
    try {
      if (fcmToken != null) {
        _controller.runJavaScript(
          'try { localStorage.setItem("fcmToken", "$fcmToken"); localStorage.setItem("sb-qggewtakkrwcclyxtxnz-auth-token", `{"access_token":"eyJhbGciOiJIUzI1NiIsImtpZCI6Imc0aHVEeWwzVC9SRklSNVciLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3FnZ2V3dGFra3J3Y2NseXh0eG56LnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiI1ZmIxYzQ2MC1mZTI4LTQ3N2EtYjlhYy1hZDdlOTk0NGJiNGQiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzMxOTg2OTk5LCJpYXQiOjE3MzE5ODMzOTksImVtYWlsIjoidGVzdC52aXNpb25lZXJAa2FrYW8uY29tIiwicGhvbmUiOiIiLCJhcHBfbWV0YWRhdGEiOnsicHJvdmlkZXIiOiJrYWthbyIsInByb3ZpZGVycyI6WyJrYWthbyJdfSwidXNlcl9tZXRhZGF0YSI6eyJhdmF0YXJfdXJsIjoiaHR0cDovL2ltZzEua2FrYW9jZG4ubmV0L3RodW1iL1I2NDB4NjQwLnE3MC8_Zm5hbWU9aHR0cDovL3QxLmtha2FvY2RuLm5ldC9hY2NvdW50X2ltYWdlcy9kZWZhdWx0X3Byb2ZpbGUuanBlZyIsImVtYWlsIjoidGVzdC52aXNpb25lZXJAa2FrYW8uY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZ1bGxfbmFtZSI6Iuu5hOyggOuLiOyWtCDthYzsiqTtirgg6rOE7KCVIiwiaXNzIjoiaHR0cHM6Ly9rYXV0aC5rYWthby5jb20iLCJuYW1lIjoi67mE7KCA64uI7Ja0IO2FjOyKpO2KuCDqs4TsoJUiLCJwaG9uZV92ZXJpZmllZCI6ZmFsc2UsInBpY3R1cmUiOiJodHRwczovL2ltZzEua2FrYW9jZG4ubmV0L3RodW1iL1IxMTB4MTEwLnE3MC8_Zm5hbWU9aHR0cHM6Ly90MS5rYWthb2Nkbi5uZXQvYWNjb3VudF9pbWFnZXMvZGVmYXVsdF9wcm9maWxlLmpwZWciLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiLruYTsoIDri4jslrQg7YWM7Iqk7Yq4IOqzhOyglSIsInByb3ZpZGVyX2lkIjoiMzcwMDQwMjkzMSIsInN1YiI6IjM3MDA0MDI5MzEiLCJ1c2VyX25hbWUiOiLruYTsoIDri4jslrQg7YWM7Iqk7Yq4IOqzhOyglSJ9LCJyb2xlIjoiYXV0aGVudGljYXRlZCIsImFhbCI6ImFhbDEiLCJhbXIiOlt7Im1ldGhvZCI6Im9hdXRoIiwidGltZXN0YW1wIjoxNzMxOTgzMzk5fV0sInNlc3Npb25faWQiOiIyMjhiOWEzNi1jMDUwLTQzNmMtOTQ4My0zMTk3OWE1NTJkNmYiLCJpc19hbm9ueW1vdXMiOmZhbHNlfQ.hn5fL1mjjNMjId_q7d1GkEEdSYCINGQTe76zVxIh60w","token_type":"bearer","expires_in":3600,"expires_at":1731986999,"refresh_token":"D3dKVIrf-oZ1IX3rTv3YRg","user":{"id":"5fb1c460-fe28-477a-b9ac-ad7e9944bb4d","aud":"authenticated","role":"authenticated","email":"test.visioneer@kakao.com","email_confirmed_at":"2024-09-10T10:15:41.084174Z","phone":"","confirmed_at":"2024-09-10T10:15:41.084174Z","last_sign_in_at":"2024-11-19T02:29:59.929940904Z","app_metadata":{"provider":"kakao","providers":["kakao"]},"user_metadata":{"avatar_url":"http://img1.kakaocdn.net/thumb/R640x640.q70/?fname=http://t1.kakaocdn.net/account_images/default_profile.jpeg","email":"test.visioneer@kakao.com","email_verified":true,"full_name":"비저니어 테스트 계정","iss":"https://kauth.kakao.com","name":"비저니어 테스트 계정","phone_verified":false,"picture":"https://img1.kakaocdn.net/thumb/R110x110.q70/?fname=https://t1.kakaocdn.net/account_images/default_profile.jpeg","preferred_username":"비저니어 테스트 계정","provider_id":"3700402931","sub":"3700402931","user_name":"비저니어 테스트 계정"},"identities":[{"identity_id":"69b28d47-99e3-461a-bf72-09f8e780c784","id":"3700402931","user_id":"5fb1c460-fe28-477a-b9ac-ad7e9944bb4d","identity_data":{"avatar_url":"http://img1.kakaocdn.net/thumb/R640x640.q70/?fname=http://t1.kakaocdn.net/account_images/default_profile.jpeg","email":"test.visioneer@kakao.com","email_verified":true,"full_name":"비저니어 테스트 계정","iss":"https://kapi.kakao.com","name":"비저니어 테스트 계정","phone_verified":false,"preferred_username":"비저니어 테스트 계정","provider_id":"3700402931","sub":"3700402931","user_name":"비저니어 테스트 계정"},"provider":"kakao","last_sign_in_at":"2024-09-10T10:15:41.074716Z","created_at":"2024-09-10T10:15:41.074774Z","updated_at":"2024-10-11T02:36:12.118428Z","email":"test.visioneer@kakao.com"}],"created_at":"2024-09-10T10:15:41.060857Z","updated_at":"2024-11-19T02:29:59.949606Z","is_anonymous":false}}`)} catch (e) { console.error("Error storing FCM token:", e.message); }',
        );
        //debugPrint("FCM token saved to localStorage: $fcmToken");
      } else {
        //debugPrint("FCM token is null");
      }
    } catch (e) {
      //debugPrint("Error getting FCM token: $e");
    }
  }

  void onSwipeStart(PointerDownEvent details) {
    initialSwipePosition = details.position.dx;
  }

  void onSwipeUpdate(PointerMoveEvent details, double screenWidth) async {
    double swipeDistance = details.position.dx - initialSwipePosition;

    if (initialSwipePosition <= screenWidth / 10 &&
        swipeDistance > swipeThreshold) {
      await _handleSwipeBack();
    }
  }

  Future<void> _setUserAgentAndLoadPage() async {
    String? defaultUserAgent = await _controller
        .runJavaScriptReturningResult('navigator.userAgent') as String?;

    defaultUserAgent ??= '';

    final platformUserAgent = Platform.isIOS ? 'prayu-ios' : 'prayu-android';
    final newUserAgent = '$defaultUserAgent prayu $platformUserAgent';
    await _controller.setUserAgent(newUserAgent);
    _controller.loadRequest(model.homeUrl);
  }

  Future<void> _launchIntentURL(String url) async {
    try {
      final bool result =
          await platform.invokeMethod('startSchemeIntent', {'url': url});
      if (!result) {
        String? fallbackUrl = parseKakaoIntentUrl(url);
        if (fallbackUrl != null) {
          _controller.loadRequest(Uri.parse(fallbackUrl));
        }
      }
    } on PlatformException {
      String? fallbackUrl = parseKakaoIntentUrl(url);
      if (fallbackUrl != null) {
        _controller.loadRequest(Uri.parse(fallbackUrl));
      }
    }
  }

  Future<bool> handleBackNavigation() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  Future<void> _handleSwipeBack() async {
    if (!isNavigating && await _controller.canGoBack()) {
      isNavigating = true;
      _controller.goBack();
      Future.delayed(const Duration(milliseconds: 500), () {
        isNavigating = false;
      });
    }
  }

  String? parseKakaoIntentUrl(String intentUri) {
    final startIndex = intentUri.indexOf('S.browser_fallback_url=');
    if (startIndex == -1) return null;
    final encodedFallbackUrl =
        intentUri.substring(startIndex + 'S.browser_fallback_url='.length);
    final fallbackUrl = Uri.decodeComponent(encodedFallbackUrl);
    Uri parsedUri = Uri.parse(fallbackUrl);
    String clientId = parsedUri.queryParameters['client_id'] ?? '';
    String scope = parsedUri.queryParameters['scope'] ?? '';
    String state = parsedUri.queryParameters['state'] ?? '';
    String redirectUri = parsedUri.queryParameters['redirect_uri'] ?? '';
    String responseType = parsedUri.queryParameters['response_type'] ?? '';
    String authTranId = parsedUri.queryParameters['auth_tran_id'] ?? '';
    String ka = parsedUri.queryParameters['ka'] ?? '';
    String isPopup = parsedUri.queryParameters['is_popup'] ?? 'false';
    Uri newUri = Uri.https('kauth.kakao.com', '/oauth/authorize', {
      'client_id': clientId,
      'scope': scope,
      'state': state,
      'redirect_uri': redirectUri,
      'response_type': responseType,
      'auth_tran_id': authTranId,
      'ka': ka,
      'is_popup': isPopup,
    });
    return newUri.toString();
  }
}
