import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:package_info/package_info.dart';
import 'package:sisterly/utils/localization/app_localizations.dart';
import 'package:sisterly/utils/session_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisterly/widgets/alert/custom_alert.dart';
import 'constants.dart';
import 'package:image/image.dart' as Img;

class ApiManager {
  static bool isErrorShowing = false;
  final BuildContext context;

  ApiManager(this.context);

  //USER APIS

  login(email, password, success, failure) async {
    var params = {
      "email": email,
      "password": password,
      "username_email": email
    };

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    var currentVersion = packageInfo.version;
    params["app_version"] = currentVersion;

    makePostRequest("/client/token", params, success, failure);
  }

  signup(email, confirmemail, username, password, firstName, lastName, phone,
      birthday, success, failure) async {
    var params = {
      "email": email,
      "confirmemail": confirmemail,
      "password": password,
      "first_name": firstName,
      "last_name": lastName,
      "phone": phone,
      "username": username,
      "birthday": birthday
    };

    makePostRequest("/client/register", params, success, failure);
  }

  createUser(success, failure) {
    debugPrint("postUser called");
    makePostRequest("/api/users", null, success, failure);
  }

  salesManagoEvent(params, success, failure) {
    debugPrint("salesManagoEvent called");
    makePostRequest("/salesmanago/event", params, success, failure);
  }

  salesManagoContact(success, failure) {
    debugPrint("salesManagoContact called");
    makePostRequest("/salesmanago/contact", null, success, failure);
  }

  //delete contact
  salesManagoContactDelete(success, failure) {
    debugPrint("salesManagoDelete called");
    makeDeleteRequest("/salesmanago/delete_contact", success, failure);
  }

  refreshToken(refreshToken, success, failure) async {
    debugPrint("refreshToken called");
    var params = {"refresh": refreshToken};

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var currentVersion = packageInfo.version;
    params["app_version"] = currentVersion;

    await internalMakePostRequest("/client/token/refresh", params,
        SessionData().token, success, failure, false);
  }

  makePostRequest(endpoint, params, success, failure) async {
    debugPrint("========token========");
    debugPrint(SessionData().token.toString());
    debugPrint("=======UserId=========");
    debugPrint(SessionData().userId.toString());

    await internalMakePostRequest(
        endpoint, params, SessionData().token, success, failure, true);
  }

  makeDeleteRequest(endpoint, success, failure) async {
    await internalMakeDeleteRequest(endpoint, success, failure);
  }

  internalMakePostRequest(
      endpoint, params, token, success, failure, retry) async {
    String url = Constants.SERVER_URL + endpoint;

    Map<String, String> headers = {
      "Content-type": "application/json",
      "Accept-Language": await getLocale(context) ?? ''
    };
    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    String json = jsonEncode(params);

    debugPrint("internalMakePostRequest " + url + " with params: " + json);

    try {
      Response response =
          await http.post(Uri.parse(url), headers: headers, body: json);
      int statusCode = response.statusCode;
      String body = response.body;

      log("Status: " + statusCode.toString() + "  body: " + body);

      var bodyResponse = jsonDecode(body);

      if (bodyResponse["status"].toString() == "500") {
        debugPrint("internalMakePostRequest " + url + " invalid token");
        failure(401);
      } else if ((bodyResponse["status"] != null &&
              bodyResponse["status"].toString() == "401" &&
              retry) ||
          bodyResponse["code"] == "token_not_valid") {
        debugPrint("makePostRequest: refreshToken retry " + retry.toString());

        if (retry) {
          debugPrint("refresh");
          var preferences = await SharedPreferences.getInstance();
          var token = preferences.getString(Constants.PREFS_REFRESH_TOKEN);
          refreshToken(token, (response) async {
            var preferences = await SharedPreferences.getInstance();
            preferences.setString(Constants.PREFS_TOKEN, response["access"]);
            preferences.setString(
                Constants.PREFS_REFRESH_TOKEN, response["refresh"]);
            SessionData().token = response["access"];
            internalMakePostRequest(
                endpoint, params, SessionData().token, success, failure, false);
          }, () {
            failure(401);

            SessionData().logout(context);
          });
        } else {
          failure(401);
        }
      } else {
        log("internalMakePostRequest " + url + " success. Body: " + body);
        success(bodyResponse);
      }
    } catch (ex) {
      debugPrint("internalMakePostRequest exception " + ex.toString());
      failure(null);
    }
  }

  String encodeMap(Map data) {
    return data.keys
        .map((key) =>
            "${Uri.encodeComponent(key)}=${Uri.encodeComponent(data[key].toString())}")
        .join("&");
  }

  makeGetRequest(endpoint, params, success, failure) async {
    await internalMakeGetRequest(
        endpoint, params, SessionData().token, success, failure, true);
  }

  makeGetLambdaRequest(endpoint, params, success, failure) async {
    await internalMakeGetLambdaRequest(
        endpoint, params, SessionData().token, success, failure, true);
  }

  makeFutureGetRequest(endpoint, params) async {
    return await internalFutureMakeGetRequest(
        endpoint, params, SessionData().token);
  }

  internalMakeGetLambdaRequest(
      endpoint, params, token, success, failure, retry) async {
    debugPrint("internalMakeGetLambdaRequest " +
        Constants.LAMBDA_URL +
        endpoint +
        " with params: " +
        jsonEncode(params));

    var paramsString = "";

    if (params != null) {
      paramsString = "?" + encodeMap(params);
    }

    debugPrint("internalMakeGetLambdaRequest final url " +
        Constants.LAMBDA_URL +
        endpoint +
        paramsString);
    debugPrint("internalMakeGetLambdaRequest token " + token.toString());

    try {
      var response = await http.get(
          Uri.parse(Constants.LAMBDA_URL + endpoint + paramsString),
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
            "Accept-Language": await getLocale(context) ?? ''
          });

      debugPrint("internalMakeGetLambdaRequest response:");
      log(response.body);

      int statusCode = response.statusCode;
      String json = response.body;

      log("Status: " + statusCode.toString() + "  body: " + json);

      try {
        var bodyResponse = jsonDecode(json);

        if (bodyResponse["status"] != null &&
            bodyResponse["status"].toString() == "500") {
          debugPrint(
              "internalMakeGetLambdaRequest " + endpoint + " invalid token");
          manageFailure(failure, context, 401, json);
        } else if ((bodyResponse["status"] != null &&
                bodyResponse["status"].toString() == "401" &&
                retry) ||
            bodyResponse["code"] == "token_not_valid") {
          debugPrint("internalMakeGetLambdaRequest: refreshToken");
          retry = false;
          var preferences = await SharedPreferences.getInstance();
          var token = preferences.getString(Constants.PREFS_REFRESH_TOKEN);
          refreshToken(token, (response) async {
            if (response != null && response["access"] != null) {
              var preferences = await SharedPreferences.getInstance();
              preferences.setString(Constants.PREFS_TOKEN, response["access"]);
              preferences.setString(
                  Constants.PREFS_REFRESH_TOKEN, response["refresh"]);
              SessionData().token = response["access"];
              internalMakeGetLambdaRequest(endpoint, params,
                  SessionData().token, success, failure, false);
            } else {
              SessionData().logout(context);
            }
          }, failure);
        } else {
          debugPrint("internalMakeGetLambdaRequest " + endpoint + " success");
          success(bodyResponse);
        }
      } catch (ex) {
        debugPrint("internalMakeGetLambdaRequest " +
            endpoint +
            " catch failure " +
            ex.toString());
        manageFailure(failure, context, statusCode, json);
      }
    } catch (ex) {
      debugPrint("internalMakeGetLambdaRequest catch");
      manageFailure(failure, context, null, json);
    }
  }

  internalMakeGetRequest(
      endpoint, params, token, success, failure, retry) async {
    debugPrint("makeGetRequest " +
        Constants.SERVER_URL +
        endpoint +
        " with params: " +
        jsonEncode(params));

    var paramsString = "";

    if (params != null) {
      paramsString = "?" + encodeMap(params);
    }

    debugPrint("makeGetRequest final url " +
        Constants.SERVER_URL +
        endpoint +
        paramsString);
    debugPrint("makeGetRequest token " + token.toString());

    try {
      var response = await http.get(
          Uri.parse(Constants.SERVER_URL + endpoint + paramsString),
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
            "Accept-Language": await getLocale(context) ?? ''
          });

      debugPrint("makeGetRequest response:");
      log(response.body);

      int statusCode = response.statusCode;
      String json = response.body;

      log("Status: " + statusCode.toString() + "  body: " + json);

      try {
        var bodyResponse = jsonDecode(json);

        if (bodyResponse["status"] != null &&
            bodyResponse["status"].toString() == "500") {
          debugPrint("makeGetRequest " + endpoint + " invalid token");
          manageFailure(failure, context, 401, json);
        } else if ((bodyResponse["status"] != null &&
                bodyResponse["status"].toString() == "401" &&
                retry) ||
            bodyResponse["code"] == "token_not_valid") {
          debugPrint("makeGetRequest: refreshToken");
          retry = false;
          var preferences = await SharedPreferences.getInstance();
          var token = preferences.getString(Constants.PREFS_REFRESH_TOKEN);
          refreshToken(token, (response) async {
            if (response != null && response["access"] != null) {
              var preferences = await SharedPreferences.getInstance();
              preferences.setString(Constants.PREFS_TOKEN, response["access"]);
              preferences.setString(
                  Constants.PREFS_REFRESH_TOKEN, response["refresh"]);
              SessionData().token = response["access"];
              internalMakeGetRequest(endpoint, params, SessionData().token,
                  success, failure, false);
            } else {
              SessionData().logout(context);
            }
          }, failure);
        } else {
          debugPrint("makeGetRequest " + endpoint + " success");
          success(bodyResponse);
        }
      } catch (ex) {
        debugPrint(
            "makeGetRequest " + endpoint + " catch failure " + ex.toString());
        manageFailure(failure, context, statusCode, json);
      }
    } catch (ex) {
      debugPrint("makeGetRequest catch");
      manageFailure(failure, context, null, json);
    }
  }

  internalFutureMakeGetRequest(endpoint, params, token) async {
    debugPrint("internalFutureMakeGetRequest " +
        Constants.SERVER_URL +
        endpoint +
        " with params: " +
        jsonEncode(params));

    var paramsString = "";

    if (params != null) {
      paramsString = "?" + encodeMap(params);
    }

    debugPrint("internalFutureMakeGetRequest final url " +
        Constants.SERVER_URL +
        endpoint +
        paramsString);

    try {
      var response = await http.get(
          Uri.parse(Constants.SERVER_URL + endpoint + paramsString),
          headers: {
            "Accept": "application/json",
            "Authorization": token,
            "Accept-Language": await getLocale(context) ?? ''
          });

      /*Response response = await get(uri);*/

      int statusCode = response.statusCode;
      String json = response.body;

      log("Status: " + statusCode.toString() + "  body: " + json);

      if (statusCode == 200 || statusCode == 201) {
        try {
          var bodyResponse = jsonDecode(json);

          if (bodyResponse["status"] != null &&
              bodyResponse["status"].toString() == "500") {
            debugPrint(
                "internalFutureMakeGetRequest " + endpoint + " invalid token");
            return await manageFutureFailure(context, 401, json);
          } else {
            if (bodyResponse["success"] == true) {
              debugPrint(
                  "internalFutureMakeGetRequest " + endpoint + " success");
              return bodyResponse;
            } else {
              ApiManager.showFreeToast(context, endpoint + " success FALSE");
              debugPrint("internalFutureMakeGetRequest " +
                  endpoint +
                  " success FALSE");
              return await manageFutureFailure(context, statusCode, json);
            }
          }
        } catch (ex) {
          ApiManager.showFreeToast(
              context, endpoint + " catch failure " + ex.toString());
          debugPrint("internalFutureMakeGetRequest " +
              endpoint +
              " catch failure " +
              ex.toString());
          return await manageFutureFailure(context, statusCode, json);
        }
      } else {
        ApiManager.showFreeToast(
            context, endpoint + " status code error: " + statusCode.toString());
        debugPrint("internalFutureMakeGetRequest status code error: " +
            statusCode.toString());
        return await manageFutureFailure(context, statusCode, json);
      }
    } catch (ex) {
      ApiManager.showFreeToast(
          context, endpoint + " catch error " + ex.toString());
      debugPrint("internalFutureMakeGetRequest catch error " + ex.toString());
      return await manageFutureFailure(context, null, json);
    }
  }

  makePutRequest(endpoint, params, success, failure) async {
    await internalMakePutRequest(
        endpoint, params, SessionData().token, success, failure, true);
  }

  internalMakePutRequest(
      endpoint, params, token, success, failure, retry) async {
    String url = Constants.SERVER_URL + endpoint;

    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer $token",
      "Accept-Language": await getLocale(context) ?? ''
    };
    String json = jsonEncode(params);

    debugPrint("internalMakePutRequest " + url + " with params: " + json);

    try {
      Response response =
          await http.put(Uri.parse(url), headers: headers, body: json);
      int statusCode = response.statusCode;
      String body = response.body;

      debugPrint("Status: " + statusCode.toString() + "  body: " + body);

      var bodyResponse = jsonDecode(body);

      if ((bodyResponse["status"] != null &&
              bodyResponse["status"].toString() == "401" &&
              retry) ||
          bodyResponse["code"] == "token_not_valid") {
        debugPrint("makePutRequest: refreshToken");
        retry = false;
        var preferences = await SharedPreferences.getInstance();
        var token = preferences.getString(Constants.PREFS_REFRESH_TOKEN);
        refreshToken(token, (response) async {
          if (response != null && response["access"] != null) {
            var preferences = await SharedPreferences.getInstance();
            preferences.setString(Constants.PREFS_TOKEN, response["access"]);
            preferences.setString(
                Constants.PREFS_REFRESH_TOKEN, response["refresh"]);
            SessionData().token = response["access"];
            internalMakePutRequest(
                endpoint, params, SessionData().token, success, failure, false);
          } else {
            SessionData().logout(context);
          }
        }, failure);
      } else if (bodyResponse["errors"] != null) {
        debugPrint("internalMakePutRequest " + url + " error");
        failure(bodyResponse);
      } else {
        debugPrint("internalMakePutRequest " + url + " success. Body: " + body);
        success(bodyResponse);
      }
    } catch (ex) {
      debugPrint("errorTryCatch " + ex.toString());
      manageFailure(failure, context, null, json);
    }
  }

  internalMakeDeleteRequest(endpoint, success, failure) async {
    String url = Constants.SERVER_URL + endpoint;

    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer ${SessionData().token!}",
      "Accept-Language": await getLocale(context) ?? ''
    };

    debugPrint("internalMakeDeleteRequest " + url);

    try {
      Response response = await http.delete(Uri.parse(url), headers: headers);
      int statusCode = response.statusCode;
      String body = response.body;

      debugPrint("Status: " + statusCode.toString() + "  body: " + body);

      var bodyResponse = jsonDecode(body);

      if (bodyResponse["errors"] != null || bodyResponse["code"] != null) {
        debugPrint("internalMakeDeleteRequest " + url + " error");
        failure(bodyResponse);
      } else {
        debugPrint(
            "internalMakeDeleteRequest " + url + " success. Body: " + body);
        success(bodyResponse);
      }
    } catch (ex) {
      debugPrint(
          "internalMakeDeleteRequest " + url + " failure ex " + ex.toString());
      manageFailure(failure, context, null, null);
    }
  }

  makeUploadRequest(context, method, endpoint, filePath, params, success,
      failure, key) async {
    final postUri = Uri.parse(Constants.SERVER_URL + endpoint);
    http.MultipartRequest request = http.MultipartRequest(method, postUri);

    request.headers.addAll({
      "Authorization": "Bearer ${SessionData().token!}",
      "Content-Type": "multipart/form-data",
      "Accept-Language": await getLocale(context) ?? ''
    });

    try {
      http.MultipartFile multipartFile =
          await http.MultipartFile.fromPath(key, filePath);

      debugPrint("multipartFile postUri: " +
          postUri.toString() +
          "  multipartFile.length: " +
          multipartFile.length.toString());

      request.files.add(multipartFile);
      //request.fields["order"] = order.toString();

      if (params != null) {
        params.forEach((k, v) => request.fields[k] = v.toString());
      }

      http.StreamedResponse response = await request.send();
      final json = await response.stream.bytesToString();
      int statusCode = response.statusCode;

      debugPrint("makeUploadRequest completed json: " +
          json +
          "   files: " +
          request.files.length.toString());

      try {
        success(jsonDecode(json.toString()));
      } catch (ex) {
        manageFailure(failure, context, statusCode, json);
      }
    } catch (ex) {
      manageFailure(failure, context, 500, json);
    }
  }

  makeUploadDocumentsRequest(context, method, endpoint, fileFront, fileBack,
      params, success, failure) async {
    final postUri = Uri.parse(Constants.SERVER_URL + endpoint);
    http.MultipartRequest request = http.MultipartRequest(method, postUri);

    request.headers.addAll({
      "Authorization": "Bearer ${SessionData().token!}",
      "Content-Type": "multipart/form-data",
      "Accept-Language": await getLocale(context) ?? ''
    });

    try {
      if (fileFront != null) {
        http.MultipartFile multipartFileFront =
            await http.MultipartFile.fromPath("front", fileFront.path);
        request.files.add(multipartFileFront);
        debugPrint("multipartFile postUri: " +
            postUri.toString() +
            "  multipartFileFront.length: " +
            multipartFileFront.length.toString());
      }

      if (fileBack != null) {
        http.MultipartFile multipartFileRetro =
            await http.MultipartFile.fromPath("back", fileBack.path);
        request.files.add(multipartFileRetro);
        debugPrint("multipartFile postUri: " +
            postUri.toString() +
            "  multipartFileRetro.length: " +
            multipartFileRetro.length.toString());
      }

      //request.fields["order"] = order.toString();

      if (params != null) {
        params.forEach((k, v) => request.fields[k] = v.toString());
      }

      http.StreamedResponse response = await request.send();
      final json = await response.stream.bytesToString();
      int statusCode = response.statusCode;

      debugPrint("makeUploadRequest completed json: " +
          json +
          "   files: " +
          request.files.length.toString());

      try {
        success(jsonDecode(json.toString()));
      } catch (ex) {
        manageFailure(failure, context, statusCode, json);
      }
    } catch (ex) {
      manageFailure(failure, context, 500, json);
    }
  }

  /*uploadFile(File file, String folder) async {
    var uuid = Uuid();
    var urlParts = file.path.split(".");
    var extension = urlParts[urlParts.length - 1];
    var filename = uuid.v1() + "." + extension;

    String uploadedImageUrl = await UploadAWS().uploadImage(file, folder + "/" + filename, filename);

    /*String uploadedImageUrl = await AmazonS3Cognito.upload(
        file.path,
        "swappyverse",
        "eu-central-1:45466813-e5f8-4325-8b7d-929c3fc9c68b",
        folder + "/" + uuid.v1() + "." + extension,
        AwsRegion.EU_CENTRAL_1,
        AwsRegion.EU_CENTRAL_1);*/

    debugPrint("uploadedImageUrl "+uploadedImageUrl);

    return uploadedImageUrl;
  }*/

  manageFailure(callback, context, statusCode, json) async {
    debugPrint(
        "manageFailure " + statusCode.toString() + " json: " + json.toString());

    if (json != null) {
      try {
        var response = jsonDecode(json.toString());
        Map<String, dynamic> rawItem = new Map<String, dynamic>.from(response);

        if (rawItem["status"] == "500" ||
            rawItem["message"] == "INVALID TOKEN") {
          debugPrint("manageFailure logout due to invalid token");
          SessionData().logout(context);
          return;
        }
      } catch (ex) {
        debugPrint("manageFailure calling failure EXCEPTION " + ex.toString());
      }
    }

    debugPrint("manageFailure calling failure callback");

    callback(statusCode);
  }

  manageFutureFailure(context, statusCode, json) async {
    debugPrint("manageFutureFailure " +
        statusCode.toString() +
        " json: " +
        json.toString());

    if (statusCode == null) {
      return null;
    }

    if (json != null) {
      var response = jsonDecode(json.toString());
      Map<String, dynamic> rawItem = new Map<String, dynamic>.from(response);

      if (rawItem["status"] == "500" || rawItem["message"] == "INVALID TOKEN") {
        debugPrint("manageFailure logout due to invalid token");
        SessionData().logout(context);
        return null;
      } else if (response["success"] == false) {
        showErrorMessage(context, "generic_error");
      }
    }

    debugPrint("manageFailure calling failure callback");

    return null;
  }

  static showSuccessMessage(context, String textKey) {
    if (context == null) return;

    CustomAlert.show(context,
        //title: AppLocalizations.of(context).translate("generic_success"),
        confirmButtonColor: Constants.SECONDARY_COLOR,
        subtitle: AppLocalizations.of(context).translate(textKey),
        //style: CustomAlertStyle.success,
        onPress: (bool isConfirm) {
      Navigator.of(context, rootNavigator: true).pop();

      return false;
    });
  }

  static showFreeSuccessMessage(context, String text) {
    if (context == null) return;

    CustomAlert.show(context,
        //title: AppLocalizations.of(context).translate("generic_success"),
        confirmButtonColor: Constants.SECONDARY_COLOR,
        subtitle: text,
        //style: CustomAlertStyle.success,
        onPress: (bool isConfirm) {
      Navigator.of(context, rootNavigator: true).pop();

      return false;
    });
  }

  static showFreeSuccessMessageWithCallback(
      context, String text, Function callback) {
    if (context == null) return;

    CustomAlert.show(context,
        //title: AppLocalizations.of(context).translate("generic_success"),
        confirmButtonColor: Constants.SECONDARY_COLOR,
        subtitle: text,
        //style: CustomAlertStyle.success,
        onPress: (bool isConfirm) {
      Navigator.of(context, rootNavigator: true).pop();

      if (isConfirm) callback();

      return false;
    });
  }

  static showErrorMessage(context, String textKey) {
    if (context == null) return;

    CustomAlert.show(context,
        confirmButtonColor: Constants.SECONDARY_COLOR,
        //title: AppLocalizations.of(context).translate("generic_warning"),
        subtitle: AppLocalizations.of(context).translate(textKey),
        //style: CustomAlertStyle.error,
        onPress: (bool isConfirm) {
      Navigator.of(context, rootNavigator: true).pop();

      return false;
    });
  }

  static showFreeErrorMessage(context, String text) {
    if (context == null) return;

    CustomAlert.show(context,
        confirmButtonColor: Constants.SECONDARY_COLOR,
        //title: AppLocalizations.of(context).translate("generic_warning"),
        subtitle: text, onPress: (bool isConfirm) {
      Navigator.of(context, rootNavigator: true).pop();

      return false;
    });
  }

  static showSadMessage(context, String textKey) {
    if (context == null) return;

    CustomAlert.show(context,
        title: ":-(",
        subtitle: AppLocalizations.of(context).translate(textKey),
        style: CustomAlertStyle.error, onPress: (bool isConfirm) {
      Navigator.of(context, rootNavigator: true).pop();

      return false;
    });
  }

  static showConnectionError(context, String textKey) {
    isErrorShowing = true;

    CustomAlert.show(context,
        title: AppLocalizations.of(context).translate("generic_warning"),
        subtitle: AppLocalizations.of(context).translate(textKey),
        style: CustomAlertStyle.error,
        confirmButtonText: "Riprova", onPress: (bool isConfirm) {
      isErrorShowing = false;
      Navigator.of(context, rootNavigator: true).pop();

      return false;
    });
  }

  static isOnline() async {
    return true;
  }

  static showSuccessToast(context, String textKey) {
    Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate(textKey),
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 2,
        gravity: ToastGravity.CENTER,
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static showErrorToast(context, String textKey) {
    Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate(textKey),
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 3,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static showFreeToast(context, String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Constants.SECONDARY_COLOR,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static showFreeErrorToast(context, String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  loadLanguage() async {
    /*var preferences = await SharedPreferences.getInstance();
    String lang = preferences.getString(Constants.PREFS_LANGUAGE);

    if(lang == null) {
      SessionData().updateLanguage("it");
      lang = "it";
    }

    SessionData().updateLanguage(lang);

    Locale newLocale = Locale(lang.toLowerCase(), lang.toUpperCase());
    AppLocalizations.of(context).locale = newLocale;
    await AppLocalizations.of(context).load();
    await AppLocalizations.delegate.load(newLocale);
    debugPrint("load new locale "+lang);*/
  }

  subscribePushNotifications(user) {
    if (user == null) return;

    /*OneSignal.shared.sendTag("userId", user.id);
    OneSignal.shared.sendTag("firstName", user.firstName);
    OneSignal.shared.sendTag("lastName", user.lastName);
    OneSignal.shared.sendTag("email", user.email);
    OneSignal.shared.setEmail(email: user.email);
    OneSignal.shared.setExternalUserId(user.id);
    OneSignal.shared.setSubscription(true);

    debugPrint("subscribePushNotifications for userId "+user.id+"  and email "+user.email);*/
  }

  manageApiError(errorCode, context) {
    if (errorCode == 401 || errorCode == 403) {
      SessionData().logout(context);
    }
  }

  static isEmpty(String text) {
    if (text == null || text == "") {
      return true;
    }

    return false;
  }

  getLocale(context) async {
    /* Locale locale = Localizations.localeOf(context);
    return locale.languageCode;*/
    var preferences = await SharedPreferences.getInstance();
    return preferences.getString(Constants.PREFS_LANGUAGE);
  }

  static storeJson(String key, String json) async {
    var preferences = await SharedPreferences.getInstance();
    preferences.setString(key, json);
  }

  static retrieveJson(String key) async {
    var preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }
}
