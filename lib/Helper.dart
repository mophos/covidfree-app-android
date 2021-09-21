import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Helper {
  Helper();

  final storage = new FlutterSecureStorage();

  Future<String?> getStorage(String key) async {
    return await storage.read(key: key);
  }

  Future<void> deleteStorage(String key) async {
    await storage.delete(key: key);
  }

  Future<void> saveStorage(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  String toThaiDate(DateTime date) {
    // create format
    var strDate = new DateFormat.MMMd('th_TH').format(date);
    var _strDate = '$strDate ${date.year + 543}';
    // return thai date
    return _strDate;
  }

  String toLongThaiDate(DateTime date) {
    // create format
    var strDate = new DateFormat.MMMMd('th_TH').format(date);
    var _strDate = '$strDate ${date.year + 543}';
    // return thai date
    return _strDate;
  }

  String toStringThaiDate(DateTime date) {
    // create format
    var month = date.month.toString().padLeft(2, "0");
    var year = date.year + 543;
    var day = date.day.toString().padLeft(2, "0");
    // return thai date
    return "$year-$month-$day";
  }

  String toLongThaiDateAndTime(DateTime date) {
    // create format
    var strDate = new DateFormat.MMMMd('th_TH').format(date);
    var strTime = new DateFormat.Hm().format(date);
    var _strDate = '$strDate ${date.year + 543} $strTime น.';
    // return thai date
    return _strDate;
  }

  String timestampToTime(DateTime date) {
    // create format
    var strDate = new DateFormat.Hm('th_TH').format(date);
    // return thai date
    return strDate;
  }

  toastError(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  toastInfo(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
  }

  toastSuccess() {
    Fluttertoast.showToast(
        msg: 'ดำเนินการเรียบร้อย',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
  }

  checkVaccinePass(List vaccines) {
    return vaccines.length >= 2;
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  checkTestsPass(List tests) {
    DateTime currentDate = new DateTime.now();
    DateTime maxDate = new DateTime(1900);
    Map lastResult = {};

    // get last test
    tests.forEach((e) {
      DateTime sc = DateTime.parse(e["sc"]);
      if (sc.isAfter(maxDate)) {
        maxDate = sc;
      }
      lastResult = e;
    });

    print("last test date: $lastResult");

    // get last result
    if (lastResult.isNotEmpty) {
      DateTime lastDate = DateTime.parse(lastResult["sc"]);
      int dayDiff = daysBetween(lastDate, currentDate);

      return dayDiff <= 7 && lastResult["tr"] == "260415000";
    }
  }

  checkRecoveryPass(List recovery) {
    DateTime currentDate = new DateTime.now();
    DateTime maxDate = new DateTime(1900);
    Map lastResult = {};

    // get last test
    recovery.forEach((e) {
      DateTime fr = DateTime.parse(e["fr"]);
      if (fr.isAfter(maxDate)) {
        maxDate = fr;
      }
      lastResult = e;
    });

    print("last recovery date: $lastResult");

    // get last result
    if (lastResult.isNotEmpty) {
      DateTime df = DateTime.parse(lastResult["df"]);
      DateTime du = DateTime.parse(lastResult["du"]);

      return df.isBefore(currentDate) && du.isAfter(currentDate);
    }
  }
}
