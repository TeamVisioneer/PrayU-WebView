import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final homeUrl = Uri.parse('https://prayu.vercel.app/');

class HomeScreen extends StatelessWidget {
  final WebViewController controller;

  HomeScreen({super.key})
      : controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36')
    ..loadRequest(homeUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('PrayU'),
        centerTitle: true,
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}