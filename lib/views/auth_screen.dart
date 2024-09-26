import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatelessWidget {
  // SupabaseClient initialization from Supabase instance
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> signInWithKakao() async {
    try {
      // Initiating Kakao OAuth login with Supabase
      await supabase.auth.signInWithOAuth(OAuthProvider.kakao, redirectTo: "abc");

      // Fetch the user session information
      final session = supabase.auth.currentSession;
      if (session != null && session.user != null) {
        print('로그인 성공! User ID: ${session.user.id}');
        // Navigate to the next screen or handle the authenticated state
      }
    } catch (error) {
      print('로그인 오류: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kakao Login with Supabase")),
      body: Center(
        child: ElevatedButton(
          onPressed: signInWithKakao,
          child: Text('Login with Kakao'),
        ),
      ),
    );
  }
}
