import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../viewmodels/webview_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WebViewViewModel _viewModel = WebViewViewModel();
  double initialSwipePosition = 0.0;
  double swipeThreshold = 120.0;
  bool isNavigating = false;

  @override
  void initState() {
    super.initState();
    _viewModel.initWebView();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _viewModel.handleBackNavigation,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: AppBar(
            backgroundColor: Color(0xFFF2F3FD),
            centerTitle: true,
          ),
        ),
        body: Listener(
          onPointerDown: (details) {
            initialSwipePosition = details.position.dx;
          },
          onPointerMove: (details) {
            double swipeDistance = details.position.dx - initialSwipePosition;

            if (initialSwipePosition <= screenWidth / 10 && swipeDistance > swipeThreshold) {
              _handleSwipeBack();
            }
          },
          child: WebViewWidget(
            controller: _viewModel.controller,
          ),
        ),
      ),
    );
  }

  void _handleSwipeBack() async {
    if (!isNavigating && await _viewModel.controller.canGoBack()) {
      isNavigating = true; // 뒤로 가기 시작
      _viewModel.controller.goBack();
      Future.delayed(const Duration(milliseconds: 500), () {
        isNavigating = false;
      });
    }
  }
}