import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:fitnessapp/components/loader_widget.dart';
import 'package:fitnessapp/models/MovieData.dart';
import 'package:fitnessapp/network/RestApis.dart';
import 'package:fitnessapp/screens/MovieDetailScreen.dart';
import 'package:fitnessapp/screens/EditProfileScreen.dart';
import 'package:fitnessapp/screens/Signin.dart';
import 'package:fitnessapp/utils/AppWidgets.dart';
import 'package:fitnessapp/utils/Constants.dart';
import 'package:fitnessapp/utils/resources/Colors.dart';
import 'package:fitnessapp/utils/resources/Images.dart';
import 'package:fitnessapp/utils/resources/Size.dart';

import '../main.dart';

class WatchlistFragment extends StatefulWidget {
  static String tag = '/WatchlistFragment';

  @override
  WatchlistFragmentState createState() => WatchlistFragmentState();
}

class WatchlistFragmentState extends State<WatchlistFragment> {
  int userId = 0;

  Random random = Random();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    userId = getIntAsync(USER_ID);
  }

  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        return await 2.seconds.delay;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          centerTitle: false,
          title: commonCacheImageWidget(ic_logo, height: 32),
          automaticallyImplyLeading: false,
            actions: [
              appStore.isLogging
                  ? Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: commonCacheImageWidget(
                  appStore.userProfileImage.validate(),
                  fit: appStore.userProfileImage.validate().contains("http")
                      ? BoxFit.cover
                      : BoxFit.cover,
                ).onTap(() {
                  EditProfileScreen().launch(context);
                },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent),
              )
                  : commonCacheImageWidget(
                add_user,
                width: 20,
                fit: BoxFit.cover,
                height: 20,
                color: Colors.white,
              ).paddingAll(16).onTap(() {
                SignInScreen().launch(context);
              }, borderRadius: BorderRadius.circular(60)),
            ],
        ),

        body: SnapHelperWidget<MovieResponse>(
          future: getWatchList(),
          onSuccess: (MovieResponse? res) {
            if (res!.data!.isEmpty) {
              return NoDataWidget(
                imageWidget: Image.asset(ic_empty, height: 130),
                title: language!.noData,
              ).center();
            }
            return SizedBox(
              height: context.height(),
              width: context.width(),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 65),
                    child: Wrap(
                      runSpacing: 16,
                      spacing: 16,
                      children: res.data!.map((e) {
                        MovieData data = res.data![res.data!.indexOf(e)];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: context.width() / 2 - 24,
                              height: 100,
                              child: Stack(
                                children: <Widget>[
                                  commonCacheImageWidget(data.image.validate(),
                                      width: context.width() / 2,
                                      height: 130,
                                      fit: BoxFit.cover),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(60.0),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 10.0, sigmaY: 10.0),
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Colors.white.withOpacity(0.1),
                                          ),
                                          child: Icon(Icons.favorite,
                                                  size: 18, color: colorPrimary)
                                              .paddingAll(2)
                                              .onTap(() {
                                            if (!mIsLoggedIn) {
                                              SignInScreen().launch(context);
                                              return;
                                            }
                                            Map req = {
                                              'post_id': data.id.validate(),
                                              'user_id': userId,
                                            };

                                            res.data!.remove(data);
                                            setState(() {});

                                            toast(language!.pleaseWait);
                                            watchlistMovie(req).then((value) {
                                              setState(() {});
                                            }).catchError((e) {
                                              toast(e.toString());
                                            });
                                          }),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ).onTap(() {
                                appStore.setTrailerVideoPlayer(true);
                                MovieDetailScreen(movieData: data)
                                    .launch(context);
                              }).cornerRadiusWithClipRRect(radius_container),
                            ),
                            6.height,
                            SizedBox(
                              width: context.width() / 2 - 24,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  itemTitle(context, data.title.validate(),
                                      maxLine: 2),
                                  itemTitle(context, data.runTime.validate(),
                                      fontSize: 10),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ).paddingAll(16);
          },
          loadingWidget: LoaderWidget(),
          errorBuilder: (msg) {
            return Text(msg, style: boldTextStyle(color: Colors.white))
                .center();
          },
        ).makeRefreshable,
      ),
    );
  }
}
