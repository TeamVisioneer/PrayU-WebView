import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../viewmodels/webview_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final WebViewViewModel _viewModel = WebViewViewModel();

  double initialSwipePosition = 0.0;
  double swipeThreshold = 120.0;
  bool isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); //
    _viewModel.initWebView(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
            _viewModel.onSwipeStart(details);
          },
          onPointerMove: (details) {
            _viewModel.onSwipeUpdate(details, screenWidth);
          },
          child: WebViewWidget(
            controller: _viewModel.controller,
          ),
        ),
      ),
    );
  }
}
