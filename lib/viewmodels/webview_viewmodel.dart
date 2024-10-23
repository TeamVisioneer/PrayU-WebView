import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:prayu_webview/services/firebase_sevice.dart';
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
          if (request.url.startsWith('intent:')) {
            _launchIntentURL(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageFinished: (url) {
          _saveFCMTokenToLocalStorage();
        },
      ));

    _setUserAgentAndLoadPage();
  }

  Future<void> _saveFCMTokenToLocalStorage() async {
    try {
      if (fcmToken != null) {
        _controller.runJavaScript(
          'try { localStorage.setItem("fcmToken", "$fcmToken"); } catch (e) { console.error("Error storing FCM token:", e.message); }',
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
