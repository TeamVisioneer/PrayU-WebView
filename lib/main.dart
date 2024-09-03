import 'package:flutter/material.dart';
import 'package:prayu_webview/screen/home_screen.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      home: HomeScreen(),
    ),
  );
}
