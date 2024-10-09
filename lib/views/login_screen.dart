import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../viewmodels/login_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    final session = Supabase.instance.client.auth.currentSession;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kakao 로그인'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await viewModel.loginWithKakao();
                if (Supabase.instance.client.auth.currentSession != null) {
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('로그인 실패'),
                  ));
                }
              },
              child: Text('카카오로 로그인'),
            ),
            SizedBox(height: 20),
            if (session != null)
              ElevatedButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('로그아웃 성공'),
                  ));
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text('로그아웃'),
              ),
          ],
        ),
      ),
    );
  }
}
