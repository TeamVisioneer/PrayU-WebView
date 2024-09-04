import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';

final homeUrl = Uri.parse('https://prayu.vercel.app/');

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
            // intent://로 시작하는 URL을 가로채어 네이티브 코드로 처리
            _launchIntentURL(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(homeUrl);
  }

  Future<void> _launchIntentURL(String url) async {
    try {
      final bool result = await platform.invokeMethod('startSchemeIntent', {'url': url});
      if (!result) {
        print('Could not launch the intent');
      }
    } on PlatformException catch (e) {
      print("Failed to launch intent: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false; // 웹뷰에서 뒤로가기를 수행하고, 앱의 뒤로가기 동작을 막음
        }
        return true; // 앱의 기본 뒤로가기 동작을 수행
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('PrayU'),
          centerTitle: true,
        ),
        body: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }
}