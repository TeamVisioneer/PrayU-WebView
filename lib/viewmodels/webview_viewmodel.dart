import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import '../models/webview_model.dart';

class WebViewViewModel {
  final WebViewModel model = WebViewModel();
  late WebViewController _controller;
  static const platform = MethodChannel('com.yourcompany.app/scheme_intent');
  double initialSwipePosition = 0.0;
  double swipeThreshold = 120.0;
  bool isNavigating = false;

  WebViewController get controller => _controller;

  void initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('intent://')) {
            _launchIntentURL(request.url);
            return NavigationDecision.prevent;
          } else if (request.url.startsWith('intent:#')) {
            String? newUrl = parseKakaoIntentUrl(request.url);
            if (newUrl != null) {
              _controller.loadRequest(Uri.parse(newUrl));
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ));

    if (Platform.isIOS) {
      _setUserAgentAndLoadPage();
    } else {
      _controller.loadRequest(model.homeUrl);
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

    final newUserAgent = '$defaultUserAgent prayu-ios';
    await _controller.setUserAgent(newUserAgent);
    _controller.loadRequest(model.homeUrl);
  }

  Future<void> _launchIntentURL(String url) async {
    try {
      final bool result =
          await platform.invokeMethod('startSchemeIntent', {'url': url});
      if (!result) {
        print('Could not launch the intent');
      }
    } on PlatformException catch (e) {
      print("Failed to launch intent: '${e.message}'.");
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
}
