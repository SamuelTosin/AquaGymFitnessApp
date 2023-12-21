import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:fitnessapp/utils/resources/Colors.dart';

class AppTheme {
  //
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: appBackground,
    splashColor: navigationBackground,
    primaryColor: colorPrimary,
    primaryColorDark: colorPrimaryDark,
    hoverColor: colorPrimary.withOpacity(0.1),
    cardColor: colorPrimaryDark,
    disabledColor: Colors.white10,
    fontFamily: GoogleFonts.nunito().fontFamily,
    appBarTheme: AppBarTheme(
      color: appBackground,
      iconTheme: IconThemeData(color: textColorPrimary),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: appBackground,
      ),
    ),
    cardTheme: CardTheme(color: colorPrimaryDark),
    iconTheme: IconThemeData(color: textColorPrimary),
    textTheme: TextTheme(
      labelLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: textColorPrimary),
      titleSmall: TextStyle(color: textColorSecondary),
      bodySmall: TextStyle(color: textColorThird),
      titleLarge: TextStyle(color: Colors.black),
    ),
    dialogBackgroundColor: navigationBackground,
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: navigationBackground,
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: MaterialStateProperty.all(primaryTextStyle(size: 14)),
    ), colorScheme: ColorScheme.light(
      primary: colorPrimary,
      onPrimary: colorPrimary,
      secondary: colorPrimary,
    ).copyWith(error: Color(0xFFE15858)),
  );
}
