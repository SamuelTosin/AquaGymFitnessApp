import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:fitnessapp/main.dart';
import 'package:fitnessapp/network/RestApis.dart';
import 'package:fitnessapp/screens/HomeScreen.dart';
import 'package:fitnessapp/screens/OnboardingScreen.dart';
import 'package:fitnessapp/screens/Signin.dart';
import 'package:fitnessapp/utils/AppWidgets.dart';
import 'package:fitnessapp/utils/Common.dart';
import 'package:fitnessapp/utils/Constants.dart';
import 'package:fitnessapp/utils/resources/Images.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  void navigationToDashboard() async {
    await 3.seconds.delay;

    mIsLoggedIn = getBoolAsync(isLoggedIn);

    /*OnBoardingScreen().launch(context, isNewTask: true);*/

    if (getBoolAsync(isFirstTime, defaultValue: true)) {
      await setValue(isFirstTime, false);
      SignInScreen().launch(context, isNewTask: true);
    } else if (mIsLoggedIn) {
      await getUserProfileDetails().then((res) async {
        getDetails(logRes: res, image: res.profileImage.validate())
            .then((value) => HomeScreen().launch(context, isNewTask: true));
      }).catchError((e) async {
        log('Token Refreshing');

        Map req = {
          "username": getStringAsync(USER_EMAIL),
          "password": getStringAsync(PASSWORD),
        };

        await token(req).then((value) {
          HomeScreen().launch(context, isNewTask: true);
        }).catchError((e) {
          logout(context);
        });
      });
    } else {
      SignInScreen().launch(context, isNewTask: true);
    }
  }

  @override
  void initState() {
    super.initState();
    navigationToDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        child: Center(
          child: commonCacheImageWidget(ic_loading_gif, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
