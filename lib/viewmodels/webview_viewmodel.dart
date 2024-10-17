import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:prayu_webview/services/firebase_sevice.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  WebViewController get controller => _controller;

  void initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('intent://') ||
              request.url.startsWith('intent:#')) {
            _launchIntentURL(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ));
    _saveFCMTokenToLocalStorage();
    _setUserAgentAndLoadPage();
  }

  Future<void> _saveFCMTokenToLocalStorage() async {
    try {
      if (fcmToken != null) {
        _controller.runJavaScript(
          'localStorage.setItem("fcmToken", "$fcmToken")',
        );
        debugPrint("FCM token saved to localStorage: $fcmToken");
      } else {
        debugPrint("FCM token is null");
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
      if (!result) {}
    } on PlatformException {}
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

  Future<void> _updateUserWithFCMToken(String userId, String? fcmToken) async {
    if (fcmToken == null) {
      debugPrint('FCM token is null');
      return;
    }

    // 현재 저장된 FCM 토큰을 확인
    final existingTokenResponse = await Supabase.instance.client
        .from('profiles')
        .select('fcm_token')
        .eq('id', userId)
        .single();

    if (existingTokenResponse['fcm_token'] == fcmToken) {
      debugPrint('FCM token is already up-to-date');
      return; // 토큰이 같다면 업데이트하지 않음
    }

    // FCM 토큰이 다르면 업데이트
    final response = await Supabase.instance.client
        .from('profiles')
        .update({'fcm_token': fcmToken})
        .eq('id', userId)
        .select();

    if (response.isNotEmpty && response[0]['error'] != null) {
      debugPrint('Error updating Supabase: ${response[0]['error']['message']}');
    } else {
      debugPrint('response is $response');
      debugPrint('FCM token updated successfully for userId: $userId');
    }
  }
}
