import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import '../../../../shared/models/user.dart' as app_user;
import '../../../../core/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 현재 사용자 가져오기
  Future<app_user.User?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      if (response.data['success']) {
        final userData = response.data['data'];
        return app_user.User(
          uid: userData['uid'],
          email: userData['email'],
          displayName: userData['displayName'],
          photoUrl: userData['photoUrl'],
          phoneNumber: userData['phoneNumber'],
          loginProvider: userData['loginProvider'],
        );
      }
      return null;
    } catch (e) {
      print('현재 사용자 조회 오류: $e');
      return null;
    }
  }

  // 구글 로그인
  Future<app_user.User?> signInWithGoogle() async {
    try {
      // Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // 사용자가 취소함

      // 사용자 정보
      final user = app_user.User(
        uid: googleUser.id,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
        phoneNumber: null,
        loginProvider: 'google',
      );

      // 백엔드 API에 소셜 로그인 정보 전송
      final response = await _apiService.post('/auth/social-login', data: {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'phoneNumber': user.phoneNumber,
        'loginProvider': user.loginProvider,
      });

      if (response.data['success']) {
        // JWT 토큰 저장
        final token = response.data['data']['token'];
        await _apiService.setToken(token);
        return user;
      }

      return null;
    } catch (e) {
      print('Google 로그인 오류: $e');
      return null;
    }
  }

  // 카카오 로그인
  Future<app_user.User?> signInWithKakao() async {
    try {
      // 카카오톡 설치 여부 확인
      bool isInstalled = await isKakaoTalkInstalled();

      OAuthToken token;
      if (isInstalled) {
        // 카카오톡으로 로그인
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오 계정으로 로그인
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // 카카오 사용자 정보 가져오기
      KakaoUser kakaoUser = await UserApi.instance.me();

      final user = app_user.User(
        uid: 'kakao_${kakaoUser.id}',
        email: kakaoUser.kakaoAccount?.email,
        displayName: kakaoUser.kakaoAccount?.profile?.nickname,
        photoUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        phoneNumber: kakaoUser.kakaoAccount?.phoneNumber,
        loginProvider: 'kakao',
      );

      // 백엔드 API에 소셜 로그인 정보 전송
      final response = await _apiService.post('/auth/social-login', data: {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'phoneNumber': user.phoneNumber,
        'loginProvider': user.loginProvider,
      });

      if (response.data['success']) {
        // JWT 토큰 저장
        final jwtToken = response.data['data']['token'];
        await _apiService.setToken(jwtToken);
        return user;
      }

      return null;
    } catch (e) {
      print('카카오 로그인 오류: $e');
      return null;
    }
  }

  // 네이버 로그인
  Future<app_user.User?> signInWithNaver() async {
    try {
      // 네이버 로그인
      final NaverLoginResult result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.loggedIn) {
        // 네이버 사용자 정보 가져오기
        final NaverAccountResult account =
            await FlutterNaverLogin.currentAccount();

        final user = app_user.User(
          uid: 'naver_${account.id}',
          email: account.email,
          displayName: account.name,
          photoUrl: account.profileImage,
          phoneNumber: account.mobile,
          loginProvider: 'naver',
        );

        // 백엔드 API에 소셜 로그인 정보 전송
        final response = await _apiService.post('/auth/social-login', data: {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoUrl': user.photoUrl,
          'phoneNumber': user.phoneNumber,
          'loginProvider': user.loginProvider,
        });

        if (response.data['success']) {
          // JWT 토큰 저장
          final token = response.data['data']['token'];
          await _apiService.setToken(token);
          return user;
        }
      }

      return null;
    } catch (e) {
      print('네이버 로그인 오류: $e');
      return null;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      // 백엔드 API 로그아웃 호출
      await _apiService.post('/auth/logout');

      // 로컬 토큰 삭제
      await _apiService.clearToken();

      // Google 로그아웃
      await _googleSignIn.signOut();

      // 카카오 로그아웃
      try {
        await UserApi.instance.logout();
      } catch (e) {
        // 카카오 로그인 상태가 아니면 무시
      }

      // 네이버 로그아웃
      try {
        await FlutterNaverLogin.logOut();
      } catch (e) {
        // 네이버 로그인 상태가 아니면 무시
      }
    } catch (e) {
      print('로그아웃 오류: $e');
      rethrow;
    }
  }
}
