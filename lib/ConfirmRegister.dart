import 'package:covidfree/Api.dart';
import 'package:covidfree/Helper.dart';
import 'package:covidfree/Login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:loader_overlay/src/overlay_controller_widget_extension.dart';

import 'Loading.dart';

class ConfirmRegisterPage extends StatefulWidget {
  final String refCode;
  final String phoneNumber;
  final String transactionId;
  final String vendor;

  ConfirmRegisterPage(
      {required this.refCode,
      required this.phoneNumber,
      required this.transactionId,
      required this.vendor});

  @override
  _ConfirmRegisterPageState createState() => _ConfirmRegisterPageState();
}

class _ConfirmRegisterPageState extends State<ConfirmRegisterPage> {
  Api api = Api();
  Helper helper = Helper();

  String _phoneNumber = "xxxxxxxxxx";

  TextEditingController ctrlOtp = TextEditingController();

  void setInfo() {
    String phoneStart = widget.phoneNumber.substring(0, 3);
    String phoneEnd = widget.phoneNumber.substring(8, 10);
    setState(() {
      _phoneNumber = phoneStart + "xxxx" + phoneEnd;
    });
  }

  Future registerVerify(
      String vendor, String transactionId, String otp, String tel) async {
    try {
      context.loaderOverlay.show(widget: Loading());
      Response rs = await api.registerVerify(vendor, transactionId, tel, otp);
      context.loaderOverlay.hide();
      if (rs.statusCode == 200) {
        var data = rs.data;

        print(data);

        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        print(rs);
        helper.toastError(rs.statusMessage.toString());
      }
    } catch (error) {
      print(error);
      context.loaderOverlay.hide();
      helper.toastError("เกิดข้อผิดพลาด");
    }
  }

  @override
  void initState() {
    setInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
          appBar: AppBar(
            title: Text("ยืนยันการลงทะเบียน"),
            elevation: 0,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.indigo[50]),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.verified_user,
                        color: Color(0xff1a237e),
                        size: 40,
                      ),
                    ),
                    Flexible(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ระบุ OTP ที่ได้ส่งไปยังหมายเลข"),
                        Text(
                          "$_phoneNumber",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Row(
                          children: [
                            Text("รหัสอ้างอิง"),
                            SizedBox(
                              width: 20,
                            ),
                            Text("${widget.refCode}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20))
                          ],
                        ),
                      ],
                    )),
                  ],
                ),
              ),
              Expanded(
                  child: ListView(
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: ctrlOtp,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(20),
                                border: InputBorder.none,
                                fillColor: Colors.indigo[50],
                                filled: true),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    // textStyle: TextStyle(fontSize: 18),
                                    elevation: 0,
                                    primary: Color(0xff1a237e),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 20),
                                  ),
                                  onPressed: () {
                                    if (ctrlOtp.text.isEmpty) {
                                      helper.toastError("กรุณาระบุ OTP");
                                    } else {
                                      registerVerify(
                                          widget.vendor,
                                          widget.transactionId,
                                          ctrlOtp.text,
                                          widget.phoneNumber);
                                    }
                                  },
                                  child: Text(
                                    'ยืนยันการลงทะเบียน',
                                    style: TextStyle(fontFamily: "Kanit"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // const SizedBox(height: 10),
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: TextButton(
                          //         style: TextButton.styleFrom(
                          //             // textStyle: const TextStyle(fontSize: 20),
                          //             ),
                          //         onPressed: () {},
                          //         child: const Text(
                          //           'ขอรหัส OPT ใหม่',
                          //           style: TextStyle(
                          //               fontWeight: FontWeight.normal,
                          //               fontFamily: "Kanit"),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
              Text('')
            ],
          )),
    );
  }
}
