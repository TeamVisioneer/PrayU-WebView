import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class LoginViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  kakao.User? _user; // Kakao SDK의 User 정보를 저장할 변수
  kakao.User? get user => _user; // 외부에서 사용자 정보를 접근할 수 있도록 getter 추가

  Future<void> loginWithKakao() async {
    try {
      // 카카오톡으로 로그인
      OAuthToken token = await kakao.UserApi.instance.loginWithKakaoTalk();
      print('Kakao access token: ${token.accessToken}');
      fetchUserInfo();
      print(token);
      // Edge Function으로 카카오 토큰 전송
      await sendTokenToEdgeFunction(token.accessToken);
    } catch (error) {
      print('Failed to login with Kakao: $error');
    }
  }

  Future<void> sendTokenToEdgeFunction(String kakaoToken) async {
    final response = await http.post(
      Uri.parse('https://cguxpeghdqcqfdhvkmyv.supabase.co/functions/v1/kakao_login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'token': kakaoToken,
      }),
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final supabaseToken = responseBody['supabaseToken'];

      // Supabase 클라이언트를 사용해 JWT 세션을 설정
      await Supabase.instance.client.auth.setSession(supabaseToken);
      print('Logged in with Supabase token: $supabaseToken');
    } else {
      print('Failed to validate token');
    }
  }

  // 사용자 정보 가져오기
  Future<void> fetchUserInfo() async {
    try {
      kakao.User user = await kakao.UserApi.instance.me(); // Kakao SDK의 User 사용
      _user = user; // Kakao SDK의 User 정보를 변수에 저장
      print(
          '사용자 정보: ${user.kakaoAccount?.profile?.nickname}, ${user.kakaoAccount?.email}');
      notifyListeners(); // 상태가 변경되었음을 알림
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
    }
  }

  Future<void> testKakaoToken(String token) async {
    final response = await http.get(
      Uri.parse('https://kapi.kakao.com/v2/user/me'),
      headers: {
        'Authorization': 'Bearer $token', // Bearer 토큰 형식으로 전송
      },
    );

    if (response.statusCode == 200) {
      print('Kakao token is valid. Response: ${response.body}');
    } else {
      print('Failed to validate Kakao token. Status code: ${response.statusCode}');
    }
  }
}