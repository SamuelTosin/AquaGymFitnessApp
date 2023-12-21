import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:fitnessapp/fragments/HomeFragment.dart';
import 'package:fitnessapp/fragments/MoreFragment.dart';
import 'package:fitnessapp/fragments/SearchFragment.dart';
import 'package:fitnessapp/fragments/WatchlistFragment.dart';
import 'package:fitnessapp/fragments/genre_fragment.dart';
import 'package:fitnessapp/main.dart';
import 'package:fitnessapp/models/DownloadData.dart';
import 'package:fitnessapp/models/MovieDetailResponse.dart';
import 'package:fitnessapp/network/RestApis.dart';
import 'package:fitnessapp/screens/MovieDetailScreen.dart';
import 'package:fitnessapp/screens/Signin.dart';
import 'package:fitnessapp/utils/Constants.dart';
import 'package:fitnessapp/utils/resources/Colors.dart';
import 'package:fitnessapp/utils/resources/Images.dart';

class HomeScreen extends StatefulWidget {
  static String tag = '/HomeScreen';

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  List<Widget> widgets = [
    HomeFragment(),
    SearchFragment(),
    WatchlistFragment(),
    GenreFragment(),
    MoreFragment(),
  ];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    /*OneSignal.shared.setNotificationOpenedHandler((notification) async {
      if (getBoolAsync(isLoggedIn)) {
        if (notification.notification.additionalData != null) {
          if (notification.notification.additionalData!.containsKey('id')) {
            String? postId = notification.notification.additionalData!["id"];
            String? postType =
                notification.notification.additionalData!["post_type"];

            Future<MovieDetailResponse>? future;

            if (postType == 'movie') {
              future = movieDetail(postId.toInt().validate());
            } else if (postType == 'tv_show') {
              future = tvShowDetail(postId.toInt().validate());
            } else if (postType == 'episode') {
              future = episodeDetail(postId.toInt().validate());
            } else if (postType == 'video') {
              future = getVideosDetail(postId.toInt().validate());
            }

            if (postId.validate().isNotEmpty && future != null) {
              await future.then((value) {
                appStore.setTrailerVideoPlayer(true);
                MovieDetailScreen(movieData: value.data!).launch(context);
              });
            }
          }
        }
      }
    });*/

    if (getStringAsync(DOWNLOADED_DATA).isNotEmpty) {
      List<DownloadData> listData =
          (jsonDecode(getStringAsync(DOWNLOADED_DATA)) as List)
              .map((e) => DownloadData.fromJson(e))
              .toList();
      for (DownloadData data in listData) {
        if (data.userId.validate() == getIntAsync(USER_ID)) {
          appStore.downloadedItemList.add(data);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      onWillPop: () async {
        if (selectedIndex == 0) return true;
        setState(() {
          selectedIndex = 0;
        });
        return false;
      },
      child: Scaffold(
        body: widgets[selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).splashColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                offset: Offset.fromDirection(3, 1),
                spreadRadius: 3,
                blurRadius: 5,
              ),
            ],
          ),
          child: NavigationBar(
            animationDuration: Duration(milliseconds: 300),
            backgroundColor: Theme.of(context).splashColor,
            selectedIndex: selectedIndex,
            onDestinationSelected: (i) async {
              if ((i == 2) && !mIsLoggedIn) {
                SignInScreen().launch(context);
              } else {
                selectedIndex = i;
                setState(() {});
              }
            },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Image.asset(ic_home,
                    fit: BoxFit.fitHeight,
                    color: colorPrimary,
                    height: 20,
                    width: 20),
                selectedIcon: Image.asset(ic_home,
                    color: colorPrimaryDark, height: 20, width: 20),
                label: language!.home,
                tooltip: language!.home,
              ),
              NavigationDestination(
                icon: Image.asset(ic_search,
                    fit: BoxFit.fitHeight,
                    color: colorPrimary,
                    height: 20,
                    width: 20),
                selectedIcon: Image.asset(ic_search,
                    color: colorPrimaryDark, height: 20, width: 20),
                label: language!.search,
              ),
              NavigationDestination(
                icon: Image.asset(ic_favorite,
                    fit: BoxFit.fitHeight,
                    color: colorPrimary,
                    height: 20,
                    width: 20),
                selectedIcon: Image.asset(ic_favorite,
                    color: colorPrimaryDark, height: 20, width: 20),
                label: language!.favorite,
              ),
              /* NavigationDestination(
                icon: Image.asset(ic_genre,
                    fit: BoxFit.fitHeight,
                    color: Colors.white,
                    height: 22,
                    width: 22),
                selectedIcon: Image.asset(ic_genre,
                    color: colorPrimary, height: 22, width: 22),
                label: language!.genre,
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined,
                    size: 22, color: Colors.white),
                selectedIcon: Icon(Icons.settings_outlined,
                    size: 22, color: colorPrimary),
                label: language!.settings,
              ), */
            ],
          ),
        ),
      ),
    );
  }
}
