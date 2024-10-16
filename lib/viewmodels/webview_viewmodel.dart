import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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
    _setUserAgentAndLoadPage();
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
}
