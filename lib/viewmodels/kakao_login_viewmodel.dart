import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  User? _user; // User 정보를 저장할 변수
  User? get user => _user; // 외부에서 사용자 정보를 접근할 수 있도록 getter 추가

  Future<void> loginWithKakao() async {
    if (await isKakaoTalkInstalled()) {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
        await fetchUserInfo();

      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }

    }
  }

  // 사용자 정보 가져오기
  Future<void> fetchUserInfo() async {
    try {
      User user = await UserApi.instance.me();
      _user = user; // User 정보를 변수에 저장
      print('사용자 정보: ${user.kakaoAccount?.profile?.nickname}, ${user.kakaoAccount?.email}');
      notifyListeners(); // 상태가 변경되었음을 알림
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
    }
  }
}