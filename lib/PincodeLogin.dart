import 'package:covidfree/Api.dart';
import 'package:covidfree/Helper.dart';
import 'package:covidfree/VerifyLogin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'Loading.dart';

class PincodeLoginPage extends StatefulWidget {
  const PincodeLoginPage({Key? key}) : super(key: key);

  @override
  _PincodeLoginPageState createState() => _PincodeLoginPageState();
}

class _PincodeLoginPageState extends State<PincodeLoginPage> {

  Api api = Api();
  Helper helper = Helper();

  TextEditingController ctrlPhoneNumber = TextEditingController();


  Future login(String phoneNumber) async {
    try {
      context.loaderOverlay.show(widget: Loading());
      Response rs = await api.login(phoneNumber);
      context.loaderOverlay.hide();
      if (rs.statusCode == 200) {
        var data = rs.data;

        if(data["ok"]) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => VerifyLoginPage(
                refCode: data["ref_code"],
                phoneNumber: data["phone_number"],
                transactionId: data["transaction_id"],
                vendor: data["vendor"],
              )));
        } else {
          helper.toastError(data["error"]);
        }

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
  Widget build(BuildContext context) {
    return LoaderOverlay(
        child: Scaffold(
      appBar: AppBar(
        title: Text("เข้าสู่ระบบ"),
      ),
          body: Column(children: [
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
                      child: Text("ระบุหมายเลขโทรศัพท์ ที่ทำการสมัครไว้กับระบบ COVID FREE โดยกระทรวงสาธารณสุข")),
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
                              controller: ctrlPhoneNumber,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
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
                                      if (ctrlPhoneNumber.text.isEmpty) {
                                        helper.toastError("กรุณาระบุหมายเลขโทรศัพท์");
                                      } else {
                                        login(ctrlPhoneNumber.text);
                                      }
                                    },
                                    child: Text(
                                      'เข้าใช้งานระบบ',
                                      style: TextStyle(fontFamily: "Kanit"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: TextButton(
                            //         style: TextButton.styleFrom(
                            //           // textStyle: const TextStyle(fontSize: 20),
                            //         ),
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
          ],),
    ));
  }
}
