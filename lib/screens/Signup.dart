import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:fitnessapp/main.dart';
import 'package:fitnessapp/network/RestApis.dart';
import 'package:fitnessapp/screens/HomeScreen.dart';
import 'package:fitnessapp/utils/AppWidgets.dart';
import 'package:fitnessapp/utils/Constants.dart';
import 'package:fitnessapp/utils/resources/Colors.dart';
import 'package:fitnessapp/utils/resources/Size.dart';
import 'payment_configurations.dart';
import 'package:pay/pay.dart';

import 'InAppWebviewScreen.dart';

const _paymentItems = [
  PaymentItem(
    label: 'Monthly Subscription',
    amount: '9.99',
    status: PaymentItemStatus.final_price,
  )
];

class SignUpScreen extends StatefulWidget {
  static String tag = '/SignUpScreen';

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  late final Future<PaymentConfiguration> _googlePayConfigFuture;

  @override
  void initState() {
    super.initState();
    _googlePayConfigFuture =
        PaymentConfiguration.fromAsset('default_google_pay_config.json');
  }

  void onGooglePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
    doSignUp();
  }

  void onApplePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
    doSignUp();
  }

  //Google and Apple Pay implementation
  String os = Platform.operatingSystem;

    /*var applePayButton = ApplePayButton(
    paymentConfiguration: PaymentConfiguration.fromJsonString(defaultApplePay),
    paymentItems: const [
      *//*PaymentItem(
        label: 'Item A',
        amount: '0.01',
        status: PaymentItemStatus.final_price,
      ),
      PaymentItem(
        label: 'Item B',
        amount: '0.01',
        status: PaymentItemStatus.final_price,
      ),*//*
      PaymentItem(
        label: 'Monthly Subscription',
        amount: '9.99',
        status: PaymentItemStatus.final_price,
      )
    ],
    style: ApplePayButtonStyle.black,
    width: double.infinity,
    height: 50,
    type: ApplePayButtonType.buy,
    margin: const EdgeInsets.only(top: 15.0),
    onPaymentResult: (result) => debugPrint('Payment Result $result'),
    loadingIndicator: const Center(
      child: CircularProgressIndicator(),
    ),
  );

  var googlePayButton = GooglePayButton(
    paymentConfiguration: PaymentConfiguration.fromJsonString(defaultGooglePay),
    paymentItems: const [
      PaymentItem(
        label: 'Monthly Subscription',
        amount: '9.99',
        status: PaymentItemStatus.final_price,
      )
    ],
    type: GooglePayButtonType.pay,
    margin: const EdgeInsets.only(top: 15.0),
    onPaymentResult: (result) => debugPrint('Payment Result $result'),
    loadingIndicator: const Center(
      child: CircularProgressIndicator(),
    ),
  );*/



  // Every Other Business
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode lastNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode passFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  bool passwordVisible = false;

  bool isLoading = false;

  Future<void> doSignUp() async {
    hideKeyboard(context);

    /*//in-app-purchase implementation
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      // The store cannot be reached or accessed. Update the UI accordingly.
    }

    // Set literals require Dart 2.2. Alternatively, use
    // `Set<String> _kIds = <String>['product1', 'product2'].toSet()`.
    const Set<String> _kIds = <String>{'aquagym_monthly', 'product2'};
    final ProductDetailsResponse response =
    await InAppPurchase.instance.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error.
    }
    List<ProductDetails> products = response.productDetails;

    final ProductDetails productDetails = products as ProductDetails; // Saved earlier from queryProductDetails().
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
    *//*if (_isConsumable(productDetails)) {
    InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
    } else {
    InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    }*//*
    InAppPurchase.instance.completePurchase;
// From here the purchase flow will be handled by the underlying store.
// Updates will be delivered to the `InAppPurchase.instance.purchaseStream`.*/


    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Map req = {
        "first_name": firstNameController.text,
        "last_name": lastNameController.text,
        "user_email": emailController.text,
        "user_login": userNameController.text,
        "user_pass": passwordController.text,
      };

      isLoading = true;
      setState(() {});

      await register(req).then((value) async {
        Map req = {
          "username": emailController.text,
          "password": passwordController.text,
        };

        await token(req).then((value) async {
          await setValue(PASSWORD, passwordController.text);

          HomeScreen().launch(context);
        }).catchError((e) {
          isLoading = false;
          setState(() {});
          toast(e.toString());
        });
      }).catchError((e) {
        isLoading = false;
        setState(() {});
        toast(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget form = Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: firstNameController,
            cursorColor: colorPrimary,
            maxLines: 1,
            keyboardType: TextInputType.text,
            validator: (value) {
              return value!.isEmpty ? errorThisFieldRequired : null;
            },
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            onFieldSubmitted: (arg) {
              FocusScope.of(context).requestFocus(lastNameFocus);
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.grey.shade500)),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              labelText: language!.firstName,
              labelStyle: primaryTextStyle(color: Colors.black),
              //contentPadding: EdgeInsets.only(top: 8),
            ),
            style: TextStyle(fontSize: ts_normal, color: Theme.of(context).textTheme.titleLarge!.color),
          ).paddingBottom(spacing_standard_new),
          12.height,
          TextFormField(
            controller: lastNameController,
            cursorColor: colorPrimary,
            maxLines: 1,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              return value!.isEmpty ? errorThisFieldRequired : null;
            },
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (arg) {
              FocusScope.of(context).requestFocus(userNameFocus);
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.grey.shade500)),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              labelText: language!.lastName,
              labelStyle: primaryTextStyle(color: Colors.black),
              //contentPadding: EdgeInsets.only(top: 8),
            ),
            style: TextStyle(fontSize: ts_normal, color: Theme.of(context).textTheme.titleLarge!.color),
          ).paddingBottom(spacing_standard_new),
          12.height,
          TextFormField(
            controller: userNameController,
            cursorColor: colorPrimary,
            maxLines: 1,
            focusNode: userNameFocus,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              return value!.isEmpty ? errorThisFieldRequired : null;
            },
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (arg) {
              FocusScope.of(context).requestFocus(emailFocus);
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.grey.shade500)),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              labelText: language!.username,
              labelStyle: primaryTextStyle(color: Colors.black),
              //contentPadding: EdgeInsets.only(top: 8),
            ),
            style: TextStyle(fontSize: ts_normal, color: Theme.of(context).textTheme.titleLarge!.color),
          ).paddingBottom(spacing_standard_new),
          12.height,
          TextFormField(
            controller: emailController,
            cursorColor: colorPrimary,
            maxLines: 1,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value!.isEmpty) return errorThisFieldRequired;
              if (!value.validateEmail()) return language!.emailIsInvalid;
              return null;
            },
            textInputAction: TextInputAction.next,
            focusNode: emailFocus,
            onFieldSubmitted: (arg) {
              FocusScope.of(context).requestFocus(passFocus);
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.grey.shade500)),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              labelText: language!.email,
              labelStyle: primaryTextStyle(color: Colors.black),
              //contentPadding: EdgeInsets.only(top: 8),
            ),
            style: TextStyle(fontSize: ts_normal, color: Theme.of(context).textTheme.titleLarge!.color),
          ).paddingBottom(spacing_standard_new),
          12.height,
          TextFormField(
            controller: passwordController,
            obscureText: !passwordVisible,
            cursorColor: colorPrimary,
            style: TextStyle(fontSize: ts_normal, color: Theme.of(context).textTheme.titleLarge!.color),
            validator: (value) {
              if (value!.isEmpty) return errorThisFieldRequired;
              if (value.length < passwordLength) return passwordLengthMsg;
              return null;
            },
            focusNode: passFocus,
            onFieldSubmitted: (s) {
              FocusScope.of(context).requestFocus(confirmPasswordFocus);
            },
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.grey.shade500)),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              labelText: language!.password,
              labelStyle: primaryTextStyle(color: Colors.black),
              suffixIcon: GestureDetector(
                onTap: () {
                  passwordVisible = !passwordVisible;
                  setState(() {});
                },
                child: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off, color: colorPrimary, size: 20),
              ),
              //contentPadding: EdgeInsets.only(top: 8),
            ),
          ).paddingBottom(spacing_standard_new),
          12.height,
          TextFormField(
            obscureText: !passwordVisible,
            cursorColor: colorPrimary,
            style: TextStyle(fontSize: ts_normal, color: Theme.of(context).textTheme.titleLarge!.color),
            focusNode: confirmPasswordFocus,
            validator: (value) {
              if (value!.isEmpty) return errorThisFieldRequired;
              return passwordController.text == value ? null : language!.passWordNotMatch;
            },
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (arg) {
              doSignUp();
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.grey.shade500)),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorPrimary)),
              labelText: language!.confirmPassword,
              labelStyle: primaryTextStyle(color: Colors.black),
              suffixIcon: GestureDetector(
                onTap: () {
                  passwordVisible = !passwordVisible;
                  setState(() {});
                },
                child: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off, color: colorPrimary, size: 20),
              ),
              //contentPadding: EdgeInsets.only(top: 8),
            ),
          ),
          24.height,
          GestureDetector(
            onTap: () async {
              InAppWebViewScreen(Uri.parse(
                                'https://www.aquagym.fitness/terms-conditions/'))
                                .launch(context);
              /*SignUpScreen().launch(context, isNewTask: true);*/
              /*if (getStringAsync(REGISTRATION_PAGE).isNotEmpty) {
                              // UrlLauncherScreen(getStringAsync(REGISTRATION_PAGE)).launch(context);
                              InAppWebViewScreen(Uri.parse(
                                      getStringAsync(REGISTRATION_PAGE)))
                                  .launch(context);
                              // launchCustomTabURL(url: getStringAsync(REGISTRATION_PAGE));
                            } else {
                              toast(redirectionUrlNotFound);
                            }*/
            },
            child: RichTextWidget(
              list: <TextSpan>[
                TextSpan(
                  text: language!.iagree + ' ',
                  style: boldTextStyle(
                      size: 12,
                      fontFamily:
                      GoogleFonts.nunito().fontFamily),
                ),
                TextSpan(
                  text: language!.termPolicy,
                  style: boldTextStyle(
                      size: 14,
                      color: colorPrimary,
                      fontFamily:
                      GoogleFonts.nunito().fontFamily),
                ),
              ],
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 16, vertical: 24),
        ),
      ),
    );


    Widget applesignUpButton = ApplePayButton(
      paymentConfiguration: PaymentConfiguration.fromJsonString(
          defaultApplePay),
      paymentItems: _paymentItems,
      style: ApplePayButtonStyle.black,
      type: ApplePayButtonType.buy,
      margin: const EdgeInsets.only(top: 15.0),
      onPaymentResult: onApplePayResult,
      loadingIndicator: const Center(
        child: CircularProgressIndicator(),
      ),
    ).paddingSymmetric(horizontal: 16, vertical: 24);

    Widget googlesignUpButton = GooglePayButton(
      paymentConfiguration: PaymentConfiguration.fromJsonString(
          defaultGooglePay),
      paymentItems: _paymentItems,
      type: GooglePayButtonType.pay,
      margin: const EdgeInsets.only(top: 15.0),
      onPaymentResult: onGooglePayResult,
      loadingIndicator: const Center(
        child: CircularProgressIndicator(),
      ),
    ).paddingSymmetric(horizontal: 16, vertical: 24);

    /*Widget signUpButton = SizedBox(
      width: double.infinity,
      //child: Platform.isIOS ? applePayButton : googlePayButton,
      //child: Center(child: Platform.isIOS ? applePayButton : googlePayButton),
      child: button(context, 'Subscribe', onTap: () {
        doSignUp();
      }),
    ).paddingSymmetric(horizontal: 16, vertical: 24);*/

    return Scaffold(
      /*appBar: appBarWidget('', color: Colors.transparent, textColor: Colors.white, elevation: 0),*/
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        centerTitle: false,
        titleTextStyle: boldTextStyle(color: Colors.white, size: 18, ),
        title: const Text('Subscribe-AQUAGYM ANYWHERE'),
        leading: BackButton(
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 70),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /*Text(
                  language!.createAccount,
                  style: primaryTextStyle(size: 24, color: textColorPrimary),
                  maxLines: 2,
                ).paddingOnly(top: spacing_standard_new, left: spacing_standard_new, right: spacing_standard_new).center(),
                Text(
                  language!.signUpToDiscoverOurFeature,
                  style: primaryTextStyle(size: ts_normal.toInt(), color: textColorPrimary),
                  maxLines: 2,
                ).paddingOnly(top: spacing_control, left: spacing_standard_new, right: spacing_standard_new),*/
                form.paddingOnly(
                  left: spacing_standard_new,
                  right: spacing_standard_new,
                  top: spacing_large,
                  bottom: spacing_standard_new,
                ),
              ],
            ),
          ),
          /*Align(
            alignment: Alignment.bottomCenter,
            child: signUpButton.paddingOnly(
              left: spacing_standard_new,
              right: spacing_standard_new,
              top: spacing_large,
              bottom: spacing_standard_new,
            ),
          ),*/
          Align(
            alignment: Alignment.bottomCenter,
            child: applesignUpButton.paddingOnly(
              left: spacing_standard_new,
              right: spacing_standard_new,
              top: spacing_large,
              bottom: spacing_standard_new,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: googlesignUpButton.paddingOnly(
              left: spacing_standard_new,
              right: spacing_standard_new,
              top: spacing_large,
              bottom: spacing_standard_new,
            ),
          ),
          Center(child: loadingWidgetMaker().visible(isLoading))
        ],
      ),
    );
  }
}
