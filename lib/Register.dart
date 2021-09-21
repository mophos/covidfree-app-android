import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'ConfirmRegister.dart';
import 'Helper.dart';
import 'Loading.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'Api.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Api api = Api();
  Helper helper = Helper();

  final _formKey = GlobalKey<FormState>();

  // form controllers
  TextEditingController ctrlCid = TextEditingController();
  TextEditingController ctrlLaser = TextEditingController();
  TextEditingController ctrlFirstname = TextEditingController();
  TextEditingController ctrlLastName = TextEditingController();
  TextEditingController ctrlDob = TextEditingController();
  TextEditingController ctrlPhone = TextEditingController();

  late DateTime dob;

  bool isAccept = false;

  // ลงทะเบียน
  Future register(String cid, String laser, String firstName, String lastName,
      String dob, String phone) async {
    try {
      context.loaderOverlay.show(widget: Loading());
      Response rs =
          await api.register(cid, laser, firstName, lastName, dob, phone);
      context.loaderOverlay.hide();
      if (rs.statusCode == 200) {
        var data = rs.data;

        // print(data);
        if (data["ok"]) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ConfirmRegisterPage(
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
          // centerTitle: true,
          elevation: 0,
          // backgroundColor: Colors.white,
          title: Text(
            "ลงทะเบียน",
          ),
        ),
        body: ListView(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  "ข้อมูลการลงทะเบียน",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          maxLength: 13,
                          controller: ctrlCid,
                          validator: (value) {
                            if (value == null || value.isEmpty || value.length != 13) {
                              return "ระบุเลขบัตรประชาชน";
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              labelText: "เลขบัตรประชาชน",
                              filled: true,
                              counterText: "",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              fillColor: Colors.grey[100],
                              // labelStyle: TextStyle(fontSize: 18),
                              prefixIcon: Icon(Icons.credit_card)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.characters,
                          controller: ctrlLaser,
                          maxLength: 12,
                          validator: (value) {
                            if (value == null || value.isEmpty || value.length != 12) {
                              return "ระบุเลขรหัสหลังบัตร";
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              filled: true,
                              counterText: "",
                              labelText: "รหัสหลังบัตรประชาชน",
                              fillColor: Colors.grey[100],
                              // labelStyle: TextStyle(fontSize: 18),
                              prefixIcon: Icon(Icons.keyboard)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          maxLength: 30,
                          controller: ctrlFirstname,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "ระบุชื่อ";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.grey[100],
                            counterText: "",
                            // labelStyle: TextStyle(fontSize: 18),
                            labelText: "ชื่อ",
                            prefixIcon: Icon(Icons.edit),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          maxLength: 30,
                          controller: ctrlLastName,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "ระบุนามสกุล";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.grey[100],
                              counterText: "",
                              // labelStyle: TextStyle(fontSize: 18),
                              labelText: "สกุล",
                              prefixIcon: Icon(Icons.edit)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: ctrlDob,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "ระบุวันเกิด";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () async {
                               DateTime? _date = await showRoundedDatePicker(
                                  // context,
                                  fontFamily: "Kanit",
                                  firstDate: DateTime(DateTime.now().year - 120),
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime.now(),
                                  // maximumYear: new DateTime.now().year,
                                  // minimumYear: 1900,
                                  // textColor: Colors.white,
                                  background: Colors.indigo,
                                  era: EraMode.BUDDHIST_YEAR,
                                  // borderRadius: 16,
                                  theme: ThemeData(primarySwatch: Colors.indigo),
                                  // initialDatePickerMode:
                                  //     MaterialDa,
                                  // onDateTimeChanged: (newDateTime) {
                                  //   setState(() {
                                  //     dob = newDateTime;
                                  //     ctrlDob.text =
                                  //         helper.toThaiDate(newDateTime);
                                  //   });
                                  // }
                                  context: context,
                                );

                               setState(() {
                                 dob = _date!;
                                 ctrlDob.text =
                                         helper.toThaiDate(_date);
                               });
                              },
                            ),
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                            fillColor: Colors.grey[100],
                            filled: true,
                            // labelStyle: TextStyle(fontSize: 18),
                            labelText: "วันเกิด",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          controller: ctrlPhone,
                          validator: (value) {
                            if (value == null || value.isEmpty || value.length != 10) {
                              return "ระบุเบอร์โทรศัพท์";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.grey[100],
                              counterText: "",
                              // labelStyle: TextStyle(fontSize: 18),
                              labelText: "เบอร์โทร",
                              prefixIcon: Icon(Icons.phone)),
                        ),
                      ),
                      // CheckboxListTile(
                      //   title: const Text('ยอมรับเงื่อนไข'),
                      //   value: isAccept,
                      //   onChanged: (bool? value) {
                      //     setState(() {
                      //       isAccept = value!;
                      //     });
                      //   },
                      //   // secondary: const Icon(Icons.hourglass_empty),
                      // )
                    ],
                  )),
            )
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          // elevation: 0,
          child: Container(
            padding: EdgeInsets.all(10),
            height: 80,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(fontSize: 18),
                      elevation: 0,
                      primary: Color(0xff1a237e),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    ),
                    onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              String _cid = ctrlCid.text;
                              String _laser = ctrlLaser.text.toUpperCase();
                              String _firstName = ctrlFirstname.text;
                              String _lastName = ctrlLastName.text;
                              String _phone = ctrlPhone.text;
                              String _dob = helper.toStringThaiDate(dob);

                              register(_cid, _laser, _firstName, _lastName,
                                  _dob, _phone);
                            } else {
                              helper.toastInfo("กรุณาระบุข้อมูลให้ครบ");
                            }
                          },
                    child: Text(
                      'ลงทะเบียน',
                      style: TextStyle(fontFamily: "Kanit"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
