// 한국어 주석: 앱 전체에서 사용하는 타이포그래피 상수 정의
/// App-wide typography constants following Material Design 3 guidelines

import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._(); // Private constructor to prevent instantiation

  // Font family - Noto Sans KR
  static const String fontFamily = 'Noto Sans KR';

  // Text styles
  static const TextStyle headline1 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
    height: 1.2,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
    height: 1.2,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    fontFamily: fontFamily,
    height: 1.5,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    fontFamily: fontFamily,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    fontFamily: fontFamily,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    letterSpacing: 0.5,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    letterSpacing: 0.4,
  );
}

