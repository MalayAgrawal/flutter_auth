import 'dart:ui';

import 'package:chat/prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _otpContrller = TextEditingController();
  String verId = '';
  String uid = '';
  String? _name;
  String _number = '', errorMsg = "Verification Failed";
  bool otpWidget = false,
      loadingScreen = true,
      warningSign = false,
      invaldOtp = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void verifyNumber() async {
    setState(() {
      otpWidget = true;
    });
    await Firebase.initializeApp();
    print(_number);

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _number,
        verificationCompleted: (credential) async {
          setState(() {
            _otpContrller.text = credential.smsCode.toString();
          });
          await FirebaseAuth.instance.signInWithCredential(credential);
          await firestore.collection("Users").doc(_number).set({
            "name": _name,
            "number": _number,
          });

          MyShredPrefsN.addNumber("Key", _number);
          //Navigate to final page
          // Navigator.pop(context);
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => ProfileNav()),
          // );
        },
        verificationFailed: (data) {
          print(data);
          setState(() {
            errorMsg = data.code.toString();
            otpWidget = false;
            loadingScreen = true;
            warningSign = true;
          });
        },
        codeSent: (verificationId, code) {
          setState(() {
            verId = verificationId;
            loadingScreen = false;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {
          verId = verificationId;
        });
  }

  verifyOtp() async {
    setState(() {
      loadingScreen = true;
    });
    print("\n\n\nAutoverify");
    final cred = PhoneAuthProvider.credential(
        verificationId: verId, smsCode: _otpContrller.text);
    try {
      await FirebaseAuth.instance.signInWithCredential(cred);
      await firestore.collection("Users").doc(_number).set({
        "name": _name,
        "number": _number,
      });

      MyShredPrefsN.addNumber("Key", _number);
      setState(() {
        otpWidget = false;
        errorMsg = "Sucess";
        warningSign = true;
      });
      //New Page Nav
      // Navigator.pop(context);
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => ProfileNav()),
      // );
    } catch (e) {
      setState(() {
        loadingScreen = false;
        invaldOtp = true;
      });
    }
  }

  backButtonControl() {
    if (otpWidget) {
      setState(() {
        otpWidget = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    Firebase.initializeApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return backButtonControl();
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height - 10,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 70,
                        ),
                        Row(
                          children: [
                            Text(
                              "+91",
                              style: GoogleFonts.ibmPlexSerif(
                                  fontSize: 18, letterSpacing: 2),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Expanded(
                              child: TextFormField(
                                style: GoogleFonts.ibmPlexSerif(
                                    fontSize: 18, letterSpacing: 2),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "  Phone Number",
                                  hintStyle: GoogleFonts.ibmPlexSerif(
                                      fontSize: 16, letterSpacing: 1),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Can not be empty";
                                  }
                                  if (value.length != 10) {
                                    return "Phone number cannot be less then 10 digits";
                                  }
                                },
                                onSaved: (value) {
                                  _number = value!;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          style: GoogleFonts.ibmPlexSerif(
                              fontSize: 18, letterSpacing: 2),
                          decoration: InputDecoration(
                            hintText: "  Full Name",
                            hintStyle: GoogleFonts.ibmPlexSerif(
                                fontSize: 16, letterSpacing: 1),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Can not be empty";
                            }
                          },
                          onSaved: (value) {
                            _name = value;
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        warningSign
                            ? Text(
                                errorMsg,
                                style: TextStyle(color: Colors.red),
                              )
                            : Container(),
                        warningSign
                            ? SizedBox(
                                height: 30,
                              )
                            : Container(),
                        GestureDetector(
                          onTap: () {
                            validator();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[400]!,
                                  offset: Offset(0, 2), //(x,y)
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                            width: MediaQuery.of(context).size.width - 60,
                            height: 40,
                            child: Center(
                                child: Text(
                              "Sign Up",
                              style: GoogleFonts.ibmPlexSerif(
                                  fontSize: 17, letterSpacing: 4),
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              otpWidget ? _buildPopupDialog(context) : Container()
            ],
          ),
        ),
      ),
    );
  }

  validator() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    _number = "+91" + _number;
    verifyNumber();
  }

  Widget _buildPopupDialog(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white.withOpacity(0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            height: 300,
            width: 300,
            child: loadingScreen
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Enter OTP Sent On",
                        style: GoogleFonts.ibmPlexSerif(fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        _number,
                        style: GoogleFonts.ibmPlexSerif(fontSize: 16),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 220,
                        child: TextField(
                          style: GoogleFonts.ibmPlexSerif(
                              letterSpacing: 6, fontSize: 18),
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          controller: _otpContrller,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      invaldOtp
                          ? Text(
                              "Invalid OTP",
                              style: TextStyle(color: Colors.red),
                            )
                          : Container(),
                      SizedBox(
                        height: 20,
                      ),
                      TextButton(
                          onPressed: verifyOtp,
                          child: Container(
                              padding: EdgeInsets.all(6),
                              width: 220,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Text(
                                  "Verify",
                                  style: GoogleFonts.ibmPlexSerif(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ))),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
