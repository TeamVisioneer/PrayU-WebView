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
  double swipeThreshold = 110.0; // Adjust the threshold as needed

  @override
  void initState() {
    super.initState();
    _viewModel.initWebView();
  }

  @override
  Widget build(BuildContext context) {
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
        body: GestureDetector(
          onHorizontalDragStart: (details) {
            initialSwipePosition = details.localPosition.dx;
          },
          onHorizontalDragUpdate: (details) {
            double swipeDistance = details.localPosition.dx - initialSwipePosition;
            if (swipeDistance > swipeThreshold) {
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
    if (await _viewModel.controller.canGoBack()) {
      _viewModel.controller.goBack();
    }
  }
}