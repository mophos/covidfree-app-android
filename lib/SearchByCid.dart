import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'Api.dart';
import 'Helper.dart';

class SearchByCidPage extends StatefulWidget {
  const SearchByCidPage({Key? key}) : super(key: key);

  @override
  _SearchByCidPageState createState() => _SearchByCidPageState();
}

class _SearchByCidPageState extends State<SearchByCidPage> {
  Api api = Api();
  Helper helper = Helper();

  String errorMessage = "";
  String cid = "";
  String firstName = "";

  bool isLoading = false;

  TextEditingController ctrlCid = TextEditingController();

  int isPass = 1; // 1 = reading, 2 = pass, 3 = deny

  Future getHealthStatus(String _cid) async {
    setState(() {
      isLoading = true;
      isPass = 1;
    });
    try {
      String? token = await helper.getStorage("token");

      Response res = await api.checkPass(_cid, token!);

      setState(() {
        isLoading = false;
      });
      if (res.statusCode == 200) {
        var data = res.data;
        print(data);

        if (data["ok"]) {
          setState(() {
            bool _isPass = data['pass'];
            // firstName = data["rows"]["name"];
            cid = data["cid"];
            isPass = _isPass ? 2 : 3;
          });
        } else {
          setState(() {
            isPass = 3;
          });
        }
      } else {
        helper.toastError("เชื่อมต่อ Health pass api ไม่ได้");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      helper.toastError("เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์");
      print(e);
    }
  }

  void showCondition() {
    showModalBottomSheet(
        backgroundColor: Color(0xff1a237e),
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Center(
                          child: Text("เกณฑ์การพิจารณา",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20))),
                    ),
                    Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(10),
                        // height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Center(
                                child: Text(
                              "เงื่อนไขปลอดโควิด [สีเขียว]",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                            Text(
                              "1. ผู้รับบริการไม่มีผลการตรวจพบเชื่อไว้รัสโควิด-19 (ผลเป็นบวก) ภายในระยะเวลา 14 วัน และมีข้อมูลอย่างใดอย่างหนึ่ง ดังต่อไปนี้",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            Text(
                                "2.1 ผู้รับบริการได้รับการฉีดวัคซีนครบตามสูตร หรือตั้งแต่ 2 เข็มขึ้นไป",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            Text(
                                "2.2 ผู้รับบริการเคยได้รับเชื้อไวรัสโควิด-19 และรักษาหาย แต่ไม่เกิน 180 วัน นับจากวันที่ติดเชื้อ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            Text(
                                "2.3 ผู้รับบริการมีผลการตรวจไม่พบเชื้อไวรัสโควิด-19 (ผลเป็นลบ) ภายในระยะเวลา 7 วัน",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14))
                          ],
                        )),
                  ],
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ค้นจากเลขบัตรประชาชน"),
        actions: [IconButton(icon: Icon(Icons.help), onPressed: () => showCondition(),)],
      ),
      body: Column(
        children: [
          isLoading
              ? LinearProgressIndicator(
                  minHeight: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                  backgroundColor: Colors.pink[100],
                )
              : Container(),
          TextFormField(
            controller: ctrlCid,
            readOnly: false,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xff1a237e)),
            keyboardType: TextInputType.number,
            maxLength: 13,
            onFieldSubmitted: (value) {
              if (ctrlCid.text.isNotEmpty) {
                setState(() {
                  isPass = 1;
                  isLoading = true;
                  cid = "";
                  firstName = "";
                });
                getHealthStatus(ctrlCid.text);
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(0)),
              // prefixIcon: Icon(Icons.credit_card),
              fillColor: Colors.indigo[50],
              filled: true,
              counterText: "",
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.search,
                  size: 35,
                  color: Color(0xff1a237e),
                ),
                onPressed: ctrlCid.text.isNotEmpty && !isLoading
                    ? () {
                        setState(() {
                          isPass = 1;
                          cid = "";
                          firstName = "";
                        });
                        getHealthStatus(ctrlCid.text);
                      }
                    : null,
              ),
              hintText: "ระบุเลขบัตรประชาชน...",
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              // labelText: 'เครื่องอ่านบัตร',
            ),
          ),
          SizedBox(height: 40,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 20, bottom: 20),
                        height: 160,
                        width: 160,
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        child: isPass == 3
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ไม่เข้าเงื่อนไข',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            : isPass == 2
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'เข้าเงื่อนไข',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '...',
                                        style: TextStyle(
                                            letterSpacing: 4,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: isPass == 2
                                  ? Colors.green
                                  : isPass == 3
                                      ? Colors.pink
                                      : Colors.orange,
                              width: 8),
                          color: isPass == 2
                              ? Colors.green[50]
                              : isPass == 3
                                  ? Colors.pink[50]
                                  : Colors.orange[50],
                          shape: BoxShape.circle,
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 5,
                        child: CircleAvatar(
                          child: Icon(
                            isPass == 2
                                ? Icons.check_circle
                                : isPass == 3
                                    ? Icons.remove_circle
                                    : Icons.help,
                            size: 60,
                            color: isPass == 2
                                ? Colors.green
                                : isPass == 3
                                    ? Colors.pink
                                    : Colors.orange,
                          ),
                          backgroundColor: Colors.white,
                          radius: 30,
                        ),
                      )
                    ],
                  ),
                ),
                cid.isNotEmpty
                    ? Text(
                        '($cid)',
                        style: TextStyle(
                            fontWeight: FontWeight.normal, color: Colors.grey),
                      )
                    : Container(),
                const SizedBox(height: 40),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
