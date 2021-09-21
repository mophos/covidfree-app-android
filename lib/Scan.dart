import 'package:covidfree/Api.dart';
import 'package:covidfree/Helper.dart';
import 'package:covidfree/Login.dart';
import 'package:covidfree/ScanQrcode.dart';
import 'package:covidfree/SearchByCid.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  static const platform = const MethodChannel("th.go.moph.covidfree/reader");

  Api api = Api();
  Helper helper = Helper();

  String version = "";
  String developerLicense = "";

  String readerName = "";

  String errorMessage = "";
  String cid = "";
  String firstName = "";

  bool isLoading = false;

  TextEditingController ctrlReaderName = TextEditingController();

  int isPass = 1; // 1 = reading, 2 = pass, 3 = deny

  Future getReaderVersion() async {
    String _version;
    try {
      _version = await platform.invokeMethod("getVersion");
      setState(() {
        version = _version;
      });
      getReaders();
    } catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("เกิดข้อผิดพลาด"),
              content: Text('${e.toString()}'),
              actions: <Widget>[
                FlatButton(
                    child: Text('ตกลง'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    })
              ],
            );
          });
    }
  }

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
            isPass = _isPass ? 2 : 3;
          });
        } else {
          setState(() {
            isPass = 3;
          });
        }
      } else {
        Fluttertoast.showToast(
            msg: "เชื่อมต่อ Health pass api ไม่ได้",
            //   msg: "Error code: ${response.statusCode}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // print(e);
      Fluttertoast.showToast(
          // msg: "ไม่สามารถเช็คข้อมูลกับ Health pass api ได้",
          msg: "${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future getReaders() async {
    setState(() {
      isLoading = true;
    });
    try {
      var _readerName = await platform.invokeMethod("getReaders");
      setState(() {
        isLoading = false;
      });
      if (_readerName != null) {
        setState(() {
          readerName = _readerName;
          ctrlReaderName.text = _readerName;
        });

        setReader();
      } else {
        setState(() {
          ctrlReaderName.text = "";
          readerName = "";
        });
        Fluttertoast.showToast(
            msg: "ไม่พบเครื่องอ่านบัตร",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "ไม่พบเครื่องอ่านบัตร",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        isLoading = false;
        readerName = "";
      });
      print(e);
    }
  }

  Future readData() async {
    try {
      var data = await platform.invokeMethod("read");
      setState(() {
        isLoading = false;
      });
      if (data != null) {
        List _data = [];
        _data = data.split("#");

        if (_data.length > 0) {
          String _cid = _data[0];

          var str = _data[0];
          if (str != null && str.length >= 3) {
            str = str.substring(0, str.length - 3);
          }

          if (_cid.isNotEmpty) {
            getHealthStatus(_cid);
          }

          var __cid = "${str}XXX";
          //

          setState(() {
            cid = __cid;
            firstName = _data[2];
          });
        }
      } else {
        Fluttertoast.showToast(
            msg: "ไม่พบข้อมูลบัตร กรุณาเสียบบัตรและอ่านใหม่อีกครั้ง",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  Future setReader() async {
    if (readerName.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      try {
        await platform.invokeMethod("setReader", readerName);
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        Fluttertoast.showToast(
            msg: "ไม่สามารถเลือกเครื่องอ่านได้",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          isLoading = false;
        });
        print(e);
      }
    } else {
      Fluttertoast.showToast(
          msg: "ไม่พบเครื่องอ่านบัตร",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void checkPermission() async {
    bool isError = false;

    Map<Permission, PermissionStatus> statuses = await [
      // Permission.location,
      Permission.storage,
      Permission.bluetooth,
    ].request();

    if (statuses[Permission.bluetooth] == null) {
      isError = true;
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("ไม่สามารถเข้าถึง Bluetooth ได้"),
              content: const Text('กรุณาให้สิทธิ์การเข้าถึง Bluetooth'),
              actions: <Widget>[
                FlatButton(
                    child: Text('ตกลง'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    })
              ],
            );
          });
    }

    if (statuses[Permission.storage] == null) {
      isError = true;
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("ไม่สามารถเข้าถึง storage ได้"),
              content: const Text('กรุณาให้สิทธิ์การเข้าถึง storage'),
              actions: <Widget>[
                FlatButton(
                    child: Text('ตกลง'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    })
              ],
            );
          });
    }

    if (!isError) {
      getReaderVersion();
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
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Text(
                                "2.1 ผู้รับบริการได้รับการฉีดวัคซีนครบตามสูตร หรือตั้งแต่ 2 เข็มขึ้นไป",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            Text(
                                "2.2 ผู้รับบริการเคยได้รับเชื้อไวรัสโควิด-19 และรักษาหาย แต่ไม่เกิน 180 วัน นับจากวันที่ติดเชื้อ",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            Text(
                                "2.3 ผู้รับบริการมีผลการตรวจไม่พบเชื้อไวรัสโควิด-19 (ผลเป็นลบ) ภายในระยะเวลา 7 วัน",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12))
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
  void initState() {
    checkPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // iconTheme: IconThemeData(color: Color(0xff011c10)),
        elevation: 0,
        // backgroundColor: Colors.white,
        title: Text(
          "Thai Stop Covid+",
          // style: TextStyle(color: Color(0xff011c10)),
        ),
        actions: [
          IconButton(
              onPressed: () {
                getReaders();
              },
              icon: Icon(
                Icons.usb_rounded,
                color: readerName.isEmpty ? Colors.red : Colors.green,
              ))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/images/banner.png'))),
                child: Stack(children: <Widget>[
                  // Positioned(
                  //     bottom: 12.0,
                  //     left: 16.0,
                  //     child: Container(
                  //       padding: EdgeInsets.only(left: 10, right: 10),
                  //       decoration: BoxDecoration(color: Colors.white60),
                  //       child: Text("COVID FREE BY MOPH",
                  //           style: TextStyle(
                  //               color: Colors.black,
                  //               fontSize: 18,
                  //               fontWeight: FontWeight.w500)),
                  //     )),
                ])),
            SizedBox(
              height: 8,
            ),
            ListTile(
              enabled: false,
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => ScanPage()));
              },
              leading: Icon(Icons.person_search),
              title: Text(
                "สแกนบัตรประชาชน",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("ตรวจสอบสถานะ Covid free"),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ScanQrcodePage()));
              },
              enabled: true,
              leading: Icon(Icons.qr_code),
              title: Text("สแกนคิวอาร์โค้ด",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("สแกนคิวอาร์โค้ดหมอพร้อม/Thai Stop Covid+"),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SearchByCidPage()));
              },
              enabled: true,
              leading: Icon(Icons.credit_card),
              title: Text("ค้นหาจากเลขบัตร",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("ตรวจสอบข้อมูลจากเลขบัตรประชาชน"),
            ),
            ListTile(
              enabled: false,
              leading: Icon(Icons.person),
              title: Text("ข้อมูลส่วนตัว",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("แก้ไขข้อมูลส่วนตัว/รหัสผ่าน"),
            ),
            Divider(),
            ListTile(
              onTap: () async {
                await helper.deleteStorage("token");
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              trailing: Icon(
                Icons.exit_to_app,
                color: Colors.red,
              ),
              title: Text("ออกจากระบบ"),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(""),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '© 2021 ICT@MOPH',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'version 1.0.0 (20210921)',
                        style: TextStyle(color: Colors.grey),
                      ),
                      // Text(
                      //   'ศูนย์เทคโนโลยีสารสนเทศและการสื่อสาร',
                      //   style: TextStyle(color: Colors.grey),
                      // ),
                      Text(
                        'โดย กระทรวงสาธารณสุข',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            isLoading
                ? LinearProgressIndicator(
                    minHeight: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                    backgroundColor: Colors.pink[100],
                  )
                : Container(),
            TextFormField(
              controller: ctrlReaderName,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(0)),
                prefixIcon: Icon(Icons.scanner),
                fillColor: Colors.indigo[50],
                filled: true,
                hintText: "เครื่องอ่านบัตร...",
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                // labelText: 'เครื่องอ่านบัตร',
              ),
            ),
            // Row(
            //   children: [Text("เครื่องอ่านบัตร: $readerName")],
            // ),
            // SizedBox(
            //   height: 20,
            // ),

            Expanded(
                child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
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
                  // Text(
                  //   'เลขบัตร $cardData',
                  //   style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  // ),

                  firstName.isNotEmpty
                      ? Text(
                          '$firstName',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        )
                      : Container(),
                  cid.isNotEmpty
                      ? Text(
                          '($cid)',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.grey),
                        )
                      : Container(),
                  SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(fontSize: 18),
                      elevation: 0,
                      primary: Colors.pink,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    onPressed: ctrlReaderName.text.isNotEmpty && !isLoading
                        ? () {
                            setState(() {
                              isPass = 1;
                              isLoading = true;
                              cid = "";
                              firstName = "";
                            });
                            readData();
                          }
                        : null,
                    child: Text(
                      'อ่านบัตรประชาชน',
                      style: TextStyle(fontFamily: "Prompt"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 18),
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                          ),
                          onPressed: () {
                            showCondition();
                          },
                          child: const Text(
                            'เกณฑ์การพิจารณา',
                            style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Kanit"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     if (ctrlReaderName.text.isNotEmpty) {
      //       readData();
      //     } else {
      //       Fluttertoast.showToast(
      //           msg: "ไม่พบเครื่องอ่านบัตร",
      //           toastLength: Toast.LENGTH_LONG,
      //           gravity: ToastGravity.BOTTOM,
      //           timeInSecForIosWeb: 1,
      //           backgroundColor: Colors.red,
      //           textColor: Colors.white,
      //           fontSize: 16.0);
      //     }
      //   },
      //   tooltip: 'Read data',
      //   backgroundColor: Colors.pink,
      //   child: Icon(Icons.scanner),
      // ),
    );
  }
}
