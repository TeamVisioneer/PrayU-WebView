// view/show_network_error.dart
import 'package:flutter/material.dart';

void showNetworkError(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('네트워크 오류'),
        content: const Text('네트워크에 문제가 있습니다. 인터넷 연결을 확인해주세요.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('확인'),
          ),
        ],
      );
    },
  );
}
