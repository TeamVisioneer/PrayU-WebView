import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:io';

final homeUrl = Uri.parse('http://169.254.38.63:5173/');

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('com.yourcompany.app/scheme_intent');
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('intent://')) {
            /* intent://로 시작하는 URL을 가로채어 네이티브 코드로 처리 */
            _launchIntentURL(request.url);
            return NavigationDecision.prevent;
          } else if (request.url.startsWith('intent:#')) {
            /* intent:#로 시작하는 URL을 처리하여 새로운 URL로 변환 */
            String? newUrl = parseKakaoIntentUrl(request.url);
            if (newUrl != null) {
              _controller.loadRequest(Uri.parse(newUrl)); // WebView에 새 URL 로드
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(homeUrl);

    if (Platform.isIOS) {
      _controller.setUserAgent('ios_app');
    }
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false; /* 웹뷰에서 뒤로가기를 수행하고, 앱의 뒤로가기 동작을 막음 */
        }
        return true; /* 앱의 기본 뒤로가기 동작을 수행 */
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(30.0), // Adjust the height
          child: AppBar(
            backgroundColor: Color(0xFFF2F3FD),
            centerTitle: true,
          ),
        ),
        body: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }
}
