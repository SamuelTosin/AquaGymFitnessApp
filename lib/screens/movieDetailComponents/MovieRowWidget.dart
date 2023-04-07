import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:fitnessapp/main.dart';
import 'package:fitnessapp/models/MovieData.dart';
import 'package:fitnessapp/network/NetworkUtils.dart';
import 'package:fitnessapp/network/RestApis.dart';
import 'package:fitnessapp/screens/EpisodeDetailScreen.dart';
import 'package:fitnessapp/screens/MovieDetailScreen.dart';
import 'package:fitnessapp/screens/UrlLauncherScreen.dart';
import 'package:fitnessapp/utils/AppWidgets.dart';
import 'package:fitnessapp/utils/Common.dart';
import 'package:fitnessapp/utils/Constants.dart';
import 'package:fitnessapp/utils/resources/Size.dart';

// ignore: must_be_immutable
class MovieRowList extends StatefulWidget {
  List<MovieData> list = [];

  MovieRowList(this.list);

  @override
  State<MovieRowList> createState() => _MovieRowListState();
}

class _MovieRowListState extends State<MovieRowList> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: widget.list.map((e) {
        MovieData data = e;

        return InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            if (RestrictionTypeRedirect ==
                data.restrictionSetting!.restrictType) {
              await UrlLauncherScreen(data.restrictionSetting!.restrictUrl)
                  .launch(context)
                  .then((value) async {
                await refreshToken();
                getUserProfileDetails().then((value) {
                  setState(() {});
                });
              });
            } else {
              if (data.postType == PostType.EPISODE) {
                Episode episode = Episode();
                episode.title = data.title;
                episode.image = data.image;
                episode.id = data.id;
                episode.postType = "episode";
                episode.description = data.description;
                episode.excerpt = data.excerpt;
                episode.restrictSubscriptionPlan = data.restSubPlan;
                episode.restrictUserStatus = data.restrictUserStatus;
                episode.isPostRestricted = data.isPostRestricted;
                episode.userHasPmsMember = data.userHasPmsMember;
                episode.trailerLink = data.trailerLink;

                await EpisodeDetailScreen(episode: episode, episodes: [])
                    .launch(context);
              } else {
                appStore.setTrailerVideoPlayer(true);
                await MovieDetailScreen(movieData: data).launch(context);
              }
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              commonCacheImageWidget(
                data.image.validate(),
                fit: BoxFit.cover,
                width: context.width() / 4,
                height: 50,
              ).cornerRadiusWithClipRRect(radius_container),
              6.height,
              SizedBox(
                width: context.width() / 2,
                child: Text(
                  parseHtmlString(data.title.validate()),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: ts_small_large,
                    /*shadows: <Shadow>[
                      Shadow(blurRadius: 5.0, color: Colors.black),
                    ],*/
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ).paddingSymmetric(horizontal: 8),
              ),
            ],
          ),
        );
      }).toList(),
    ).paddingAll(16);
  }
}
