import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:prayu_webview/services/firebase_sevice.dart';
import 'package:prayu_webview/views/show_network_error.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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
  bool _isFCMTokenSaved = false;

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
          // 이미지 다운로드 처리
          if (_isImageURL(request.url)) {
            _downloadImage(request.url, context);
            return NavigationDecision.prevent; // WebView에서 열지 않음
          }
          return NavigationDecision.navigate;
        },
        onPageFinished: (url) {
          if (!_isFCMTokenSaved) {
            // 처음 한 번만 실행
            _saveFCMTokenToLocalStorage();
            _isFCMTokenSaved = true; // 실행 후 플래그 변경
          }
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
          'try { localStorage.setItem("fcmToken", "$fcmToken"); localStorage.setItem("sb-qggewtakkrwcclyxtxnz-auth-token", `{"access_token":"eyJhbGciOiJIUzI1NiIsImtpZCI6Imc0aHVEeWwzVC9SRklSNVciLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3FnZ2V3dGFra3J3Y2NseXh0eG56LnN1cGFiYXNlLmNvL2F1dGgvdjEiLCJzdWIiOiJlY2MwNGFiYy1jZmZmLTQxODctYjJlZS02Y2E5MzdkZmNhYzYiLCJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNzMyMjYxMTcyLCJpYXQiOjE3MzIyNTc1NzIsImVtYWlsIjoidGVzdC52aXNpb25lZXIxNUBnbWFpbC5jb20iLCJwaG9uZSI6IiIsImFwcF9tZXRhZGF0YSI6eyJwcm92aWRlciI6ImVtYWlsIiwicHJvdmlkZXJzIjpbImVtYWlsIl19LCJ1c2VyX21ldGFkYXRhIjp7ImVtYWlsIjoidGVzdC52aXNpb25lZXIxNUBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInBob25lX3ZlcmlmaWVkIjpmYWxzZSwic3ViIjoiZWNjMDRhYmMtY2ZmZi00MTg3LWIyZWUtNmNhOTM3ZGZjYWM2In0sInJvbGUiOiJhdXRoZW50aWNhdGVkIiwiYWFsIjoiYWFsMSIsImFtciI6W3sibWV0aG9kIjoicGFzc3dvcmQiLCJ0aW1lc3RhbXAiOjE3MzIyNTc1NzJ9XSwic2Vzc2lvbl9pZCI6IjY2YjdiOTdmLWFkM2ItNGYwYS04OGYwLTlmZDQ5MzM4OTg4NSIsImlzX2Fub255bW91cyI6ZmFsc2V9.QQSoXBT8ez3uAbzk_HILdhEXzTWv2SIHnbGTfuwMCfI","token_type":"bearer","expires_in":3600,"expires_at":1732261172,"refresh_token":"Aj3n4X3348MYvQyb32Pp5Q","user":{"id":"ecc04abc-cfff-4187-b2ee-6ca937dfcac6","aud":"authenticated","role":"authenticated","email":"test.visioneer15@gmail.com","email_confirmed_at":"2024-09-25T15:41:01.004331Z","phone":"","confirmation_sent_at":"2024-09-25T15:40:11.340592Z","confirmed_at":"2024-09-25T15:41:01.004331Z","last_sign_in_at":"2024-11-22T06:39:32.394951091Z","app_metadata":{"provider":"email","providers":["email"]},"user_metadata":{"email":"test.visioneer15@gmail.com","email_verified":false,"phone_verified":false,"sub":"ecc04abc-cfff-4187-b2ee-6ca937dfcac6"},"identities":[{"identity_id":"c9907c18-333a-4183-afad-219d32ead91b","id":"ecc04abc-cfff-4187-b2ee-6ca937dfcac6","user_id":"ecc04abc-cfff-4187-b2ee-6ca937dfcac6","identity_data":{"email":"test.visioneer15@gmail.com","email_verified":false,"phone_verified":false,"sub":"ecc04abc-cfff-4187-b2ee-6ca937dfcac6"},"provider":"email","last_sign_in_at":"2024-09-25T15:40:11.336684Z","created_at":"2024-09-25T15:40:11.336735Z","updated_at":"2024-09-25T15:40:11.336735Z","email":"test.visioneer15@gmail.com"}],"created_at":"2024-09-25T15:40:11.326379Z","updated_at":"2024-11-22T06:39:32.420316Z","is_anonymous":false}}`)} catch (e) { console.error("Error storing FCM token:", e.message); }',
        );
      }
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
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

  /// 특정 URL이 이미지 파일인지 확인하는 함수
  bool _isImageURL(String url) {
    return url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.png') ||
        url.endsWith('.gif');
  }

  /// 이미지 다운로드 처리 함수
  Future<void> _downloadImage(String url, BuildContext context) async {
    try {
      // HTTP 요청으로 이미지 다운로드
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // 사진 저장 권한 요청
        final PermissionState permission =
            await PhotoManager.requestPermissionExtend();
        if (permission.isAuth) {
          // 이미지를 갤러리에 저장
          await PhotoManager.editor.saveImage(
            response.bodyBytes,
            filename: "biblecard",
          );

          // 다운로드 성공 메시지
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('이미지가 갤러리에 저장되었습니다.'),
          ));
        } else {
          // 권한 거부 처리
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('사진 저장 권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
          ));
        }
      } else {
        throw Exception('이미지 다운로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      // 다운로드 실패 메시지
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('이미지 저장에 실패했습니다: $e'),
      ));
    }
  }
}
