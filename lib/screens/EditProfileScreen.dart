import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:fitnessapp/components/loader_widget.dart';
import 'package:fitnessapp/main.dart';
import 'package:fitnessapp/network/NetworkUtils.dart';
import 'package:fitnessapp/screens/EditProfileDetails.dart';
import 'package:fitnessapp/utils/AppWidgets.dart';
import 'package:fitnessapp/utils/Constants.dart';
import 'package:fitnessapp/utils/resources/Colors.dart';
import 'package:fitnessapp/utils/resources/Images.dart';
import 'package:fitnessapp/utils/resources/Size.dart';

import 'InAppWebviewScreen.dart';

class EditProfileScreen extends StatefulWidget {
  static String tag = '/ProfileScreen';

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  FocusNode lastNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();

  XFile? image;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    firstNameController.text = getStringAsync(NAME);
    lastNameController.text = getStringAsync(LAST_NAME);
    emailController.text = getStringAsync(USER_EMAIL);
  }

  Future<void> getImage() async {
    await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100).then((value) {
      image = value;
      setState(() {});
    }).catchError((error) {
      toast(errorSomethingWentWrong);
      log(error);
    });
  }

  Future<void> save() async {
    if (await isNetworkAvailable()) {
      appStore.setLoading(true);
      var multiPartRequest = await getMultiPartRequest('streamit-api/api/v2/streamit/update-profile');

      multiPartRequest.fields['first_name'] = firstNameController.text.trim();
      multiPartRequest.fields['last_name'] = lastNameController.text.trim();
      if (image != null) multiPartRequest.files.add(await MultipartFile.fromPath('profile_image', image!.path));

      multiPartRequest.headers.addAll(await buildTokenHeader());

      log(multiPartRequest.fields.toString());
      Response response = await Response.fromStream(await multiPartRequest.send());
      log(response.body);

      if (response.statusCode.isSuccessful()) {
        Map<String, dynamic> res = jsonDecode(response.body);

        toast(language!.profileHasBeenUpdatedSuccessfully);

        await setValue(NAME, res['first_name']);
        await setValue(LAST_NAME, res['last_name']);

        appStore.setFirstName(res['first_name']);
        appStore.setLastName(res['last_name']);

        if (res['streamit_profile_image'] != null) await setValue(USER_PROFILE, res['streamit_profile_image']);
        if (res['streamit_profile_image'] != null) appStore.setUserProfile(res['streamit_profile_image']);
        appStore.setLoading(false);
      } else {
        appStore.setLoading(false);
        toast(errorSomethingWentWrong);
      }
    } else {
      toast(errorInternetNotAvailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        centerTitle: false,
        /*titleTextStyle: boldTextStyle(color: Colors.white, size: 22, ),*/
        title: commonCacheImageWidget(ic_logo, height: 32),
        leading: BackButton(
          color: Colors.white,
        ),
      ),
      /*appBar: appBarWidget(language!.setting, showBack: false, color: Theme.of(context).cardColor, textColor: Colors.white),*/
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /*Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Card(
                        semanticContainer: true,
                        color: colorPrimary,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: spacing_standard_new,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(51)),
                        child: image != null
                            ? Image.file(File(image!.path), height: 95, width: 95, fit: BoxFit.cover)
                            : appStore.userProfileImage.validate().isNotEmpty
                                ? commonCacheImageWidget(appStore.userProfileImage, height: 95, width: 95, fit: BoxFit.cover)
                                : commonCacheImageWidget(appStore.userProfileImage.validate(), width: 95, height: 95, fit: BoxFit.cover),
                      ).onTap(() {
                        getImage();
                      }),
                      Text(language!.changeAvatar, style: secondaryTextStyle(size: ts_small.toInt())).paddingTop(spacing_standard_new),
                    ],
                  ).paddingOnly(top: 16),
                ).center(),*/
                Container(
                  margin: const EdgeInsets.only(top: 10.0, left: 12),
                  child: Column(
                    children: <Widget>[
                      Text(
                        language!.accountSetting,
                        style: boldTextStyle(
                            size: 26, color: Colors.black),
                      )
                    ],
                  ).paddingOnly(top: 16),
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          const ListTile(
                            leading: Icon(Icons.account_circle, color: Colors.white,),
                            title: Text('Edit profile details'),
                          ),
                        ],
                      ),
                    ).onTap(() {
                      EditProfileDetails().launch(context);
                    },
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(left: 16, right: 16),
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const ListTile(
                          leading: Icon(Icons.manage_accounts, color: Colors.white,),
                          title: Text('Edit account details'),
                        ),
                      ],
                    ),
                  ).onTap(() {
                    InAppWebViewScreen(Uri.parse(
                        'https://www.app.aquagym.fitness/account/'))
                        .launch(context);
                  },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10.0, left: 12),
                  child: Column(
                    children: <Widget>[
                      Text(
                        language!.other,
                        style: boldTextStyle(
                            size: 26, color: Colors.black),
                      )
                    ],
                  ).paddingOnly(top: 16),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(left: 16, right: 16),
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const ListTile(
                          leading: Icon(Icons.arrow_forward_ios, color: Colors.white,),
                          title: Text('Contact us'),
                        ),
                      ],
                    ),
                  ).onTap(() {
                    InAppWebViewScreen(Uri.parse(
                        'https://www.aquagym.fitness/contact/'))
                        .launch(context);
                  },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(left: 16, right: 16),
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const ListTile(
                          leading: Icon(Icons.arrow_forward_ios, color: Colors.white,),
                          title: Text('Terms, Conditions & Privacy Policy'),
                        ),
                      ],
                    ),
                  ).onTap(() {
                    InAppWebViewScreen(Uri.parse(
                        'https://www.aquagym.fitness/terms-conditions/'))
                        .launch(context);
                  },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent),
                ),
                /*Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(left: 16, right: 16),
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const ListTile(
                          leading: Icon(Icons.arrow_forward_ios, color: Colors.white,),
                          title: Text('Privacy Policy'),
                        ),
                      ],
                    ),
                  ).onTap(() {
                    InAppWebViewScreen(Uri.parse(
                        'https://www.aquagym.fitness/terms-conditions/'))
                        .launch(context);
                  },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent),
                ),*/
                /*Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AppTextField(
                        controller: firstNameController,
                        nextFocus: lastNameFocusNode,
                        textFieldType: TextFieldType.NAME,
                        errorThisFieldRequired: errorThisFieldRequired,
                        decoration: inputDecoration(hint: language!.firstName, suffixIcon: Icons.person_outline),
                        textStyle: primaryTextStyle(color: textColorPrimary),
                      ).paddingBottom(spacing_standard_new),
                      AppTextField(
                        controller: lastNameController,
                        focus: lastNameFocusNode,
                        nextFocus: emailFocusNode,
                        textFieldType: TextFieldType.NAME,
                        errorThisFieldRequired: errorThisFieldRequired,
                        decoration: inputDecoration(hint: language!.lastName, suffixIcon: Icons.person_outline),
                        textStyle: primaryTextStyle(color: textColorPrimary),
                      ).paddingBottom(spacing_standard_new),
                      AppTextField(
                        controller: emailController,
                        textFieldType: TextFieldType.EMAIL,
                        focus: emailFocusNode,
                        decoration: inputDecoration(hint: language!.email, suffixIcon: Icons.mail_outline),
                        textStyle: primaryTextStyle(color: textColorThird),
                        enabled: false,
                      ).paddingBottom(spacing_standard_new),
                    ],
                  ),
                ).paddingOnly(left: 16, right: 16, top: 36),
                AppButton(
                  width: context.width(),
                  text: language!.save,
                  color: colorPrimary,
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      save();
                    }
                  },
                ).paddingOnly(top: 30, left: 18, right: 18, bottom: 30)*/
              ],
            ),
          ),
          Observer(
            builder: (_) => LoaderWidget().visible(appStore.isLoading),
          ),
        ],
      ),
    );
  }
}
