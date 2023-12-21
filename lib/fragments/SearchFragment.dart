import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:fitnessapp/components/LoadingDotWidget.dart';
import 'package:fitnessapp/main.dart';
import 'package:fitnessapp/screens/EditProfileScreen.dart';
import 'package:fitnessapp/screens/Signin.dart';
import 'package:fitnessapp/models/MovieData.dart';
import 'package:fitnessapp/network/RestApis.dart';
import 'package:fitnessapp/screens/VoiceSearchScreen.dart';
import 'package:fitnessapp/utils/AppWidgets.dart';
import 'package:fitnessapp/utils/resources/Colors.dart';
import 'package:fitnessapp/utils/resources/Images.dart';
import 'package:fitnessapp/utils/resources/Size.dart';

import '../components/loader_widget.dart';
import '../screens/movieDetailComponents/MovieGridWidget.dart';

class SearchFragment extends StatefulWidget {
  static String tag = '/SearchFragment';

  @override
  SearchFragmentState createState() => SearchFragmentState();
}

class SearchFragmentState extends State<SearchFragment> {
  List<MovieData> movies = [];

  Future<List<MovieData>>? future;

  TextEditingController searchController = TextEditingController();

  int page = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init({bool isLoading = true}) async {
    future = searchMovie(searchController.text,
        page: page, movies: movies, isLoading: isLoading);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      /*appBarWidget(language!.search,
          showBack: false,
          color: Theme.of(context).cardColor,
          textColor: Colors.white),*/
      body: RefreshIndicator(
        onRefresh: () async {
          page = 1;
          init(isLoading: false);
          setState(() {});
          return await 2.seconds.delay;
        },
        child: Stack(
          children: [
            AnimatedScrollView(
              padding: EdgeInsets.only(bottom: 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              onNextPage: () {
                page = page + 1;
                init();
                setState(() {});
              },
              children: [
                Container(
                  color: textColorPrimary,
                  padding: EdgeInsets.only(
                      left: spacing_standard_new, right: spacing_standard),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: searchController,
                          textInputAction: TextInputAction.search,
                          style: TextStyle(
                              fontSize: ts_normal,
                              color:
                                  Theme.of(context).textTheme.titleLarge!.color),
                          decoration: InputDecoration(
                            hintText: language!.searchMoviesTvShowsVideos,
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .color),
                            border: InputBorder.none,
                            filled: false,
                          ),
                          onChanged: (s) {
                            page = 1;
                            if (s.isNotEmpty) init();

                            setState(() {});
                          },
                          onFieldSubmitted: (s) {
                            page = 1;
                            if (s.isNotEmpty) init();

                            setState(() {});
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          page = 1;
                          searchController.clear();
                          hideKeyboard(context);

                          setState(() {});
                        },
                        icon: Icon(Icons.cancel, color: colorPrimary, size: 20),
                      ).visible(searchController.text.isNotEmpty),
                      IconButton(
                        onPressed: () {
                          VoiceSearchScreen().launch(context).then((value) {
                            if (value != null) {
                              searchController.text = value;

                              hideKeyboard(context);
                              page = 1;
                              init();
                            }
                          });
                        },
                        icon: Icon(Icons.keyboard_voice,
                            color: colorPrimary, size: 20),
                      ).visible(searchController.text.isEmpty),
                    ],
                  ),
                ),

                //new_toggle
                /*Container(
                  color: appBackground,
                  padding: EdgeInsets.only(
                      left: spacing_standard_new, right: spacing_standard),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          page = 1;
                          searchController.clear();
                          hideKeyboard(context);

                          setState(() {});
                        },
                        icon: Image.asset(ic_gallery,
                            fit: BoxFit.fitHeight,
                            color: colorPrimary,
                            height: 20,
                            width: 20),
                        selectedIcon: Image.asset(ic_gallery,
                            color: colorPrimaryDark, height: 20, width: 20),
                      ) *//*.visible(searchController.text.isNotEmpty)*//*,
                      IconButton(
                        onPressed: () {
                          page = 1;
                          searchController.clear();
                          hideKeyboard(context);

                          setState(() {});
                        },
                        icon: Image.asset(ic_list,
                            fit: BoxFit.fitHeight,
                            color: colorPrimary,
                            height: 20,
                            width: 20),
                        selectedIcon: Image.asset(ic_list,
                            color: colorPrimaryDark, height: 20, width: 20),
                      ) *//*.visible(searchController.text.isNotEmpty)*//*,
                    ],
                  ),
                ),*/

                SnapHelperWidget<List<MovieData>>(
                  future: future,
                  errorBuilder: (e) {
                    return NoDataWidget(
                      title: e.toString(),
                      onRetry: () {
                        page = 1;
                        init();
                        setState(() {});
                      },
                    );
                  },
                  loadingWidget: Offstage(),
                  onSuccess: (data) {
                    if (data.validate().isEmpty) {
                      return NoDataWidget(
                        imageWidget: Image.asset(ic_empty, height: 130),
                        title: language!.noData,
                      ).center();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        headingText(language!.resultFor +
                                " \'" +
                                searchController.text +
                                "\'")
                            .paddingOnly(
                                left: 16, right: 16, top: 16, bottom: 12)
                            .visible(searchController.text.isNotEmpty),
                        MovieGridList(data.validate()),
                        /*MovieRowList(data.validate()),*/
                      ],
                    );
                  },
                ),
              ],
            ).makeRefreshable,
            Observer(
              builder: (_) {
                if (page == 1) {
                  return LoaderWidget().center().visible(appStore.isLoading);
                } else {
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: LoadingDotsWidget(),
                  ).visible(appStore.isLoading);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
