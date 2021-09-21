import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class Api {

  String apiUrl = "https://covidfree.moph.go.th/app-api";
  Dio dio = new Dio(new BaseOptions(
      receiveDataWhenStatusError: true,
      connectTimeout: 60 * 1000,
      receiveTimeout: 60 * 1000));

  Api() {
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
  }

  Future register(String cid, String laser, String firstName, String lastName,
      String dob, String tel) async {
    var url = "$apiUrl/covidfree/register";
    return dio.post(
      url,
      data: {
        "cid": cid,
        "laser": laser,
        "firstName": firstName,
        "lastName": lastName,
        "tel": tel,
        "dob": dob,
      },);
  }

  Future registerVerify(String vendor, String transactionId, String tel, String otp) async {
    var url = "$apiUrl/covidfree/register/verify";
    return dio.post(
      url,
      data: {
        "vendor": vendor,
        "transactionId": transactionId,
        "tel": tel,
        "otp": otp,
      },);
  }

  Future login(String tel) async {
    var url = "$apiUrl/covidfree/login";
    return dio.post(
      url,
      data: {
        "tel": tel,
      },);
  }

  Future loginVerify(String vendor, String transactionId, String tel, String otp) async {
    var url = "$apiUrl/covidfree/login/verify";
    return dio.post(
      url,
      data: {
        "vendor": vendor,
        "transactionId": transactionId,
        "tel": tel,
        "otp": otp,
      },);
  }

  Future checkPass(String cid, String token) async {
    var url = "$apiUrl/covidfree/pass";
    return dio.post(
      url,
      data: {
        "cid": cid,
      },
        options: Options(
            headers: {HttpHeaders.authorizationHeader: 'Bearer $token'}));
  }
}
