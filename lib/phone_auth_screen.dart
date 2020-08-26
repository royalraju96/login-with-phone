import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phone_login_firebase/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

class PhoneScreen extends StatefulWidget {
  @override
  _PhoneScreenState createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _codeController = TextEditingController();
  final _phoneController = TextEditingController();

  String id;

  // ignore: missing_return
  Future<bool> loginUser(String phone, BuildContext context) async {
    await Firebase.initializeApp();
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          Navigator.of(context).pop();
          UserCredential result = await _auth.signInWithCredential(credential);
          User user = result.user;

          if (user != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(
                          user: user,
                        )));
          } else {
            print("error");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e);
        },
        codeSent: (String verificationId, [int forceRecendingToken]) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text("Please enter the code"),
                  content: Column(
                    children: [
                      TextField(
                        controller: _codeController,
                      ),
                    ],
                  ),
                  actions: [
                    FlatButton(
                      child: Text("Confirm"),
                      color: Colors.red,
                      onPressed: () async {
                        //final smsCode = _codeController.text.trim;
                        AuthCredential credential =
                            PhoneAuthProvider.credential(
                                verificationId: verificationId,
                                smsCode: _codeController.text.trim());
                        UserCredential result =
                            await _auth.signInWithCredential(credential);

                        User user = result.user;

                        if (user != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen(
                                        user: user,
                                      )));
                        } else {
                          print("error");
                        }
                      },
                    ),
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          print(verificationId);
          print("Timeout");
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(32),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Login",
                style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 36,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[200])),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey[300])),
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: "Mobile Number"),
                controller: _phoneController,
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                width: double.infinity,
                child: FlatButton(
                  child: Text("LOGIN"),
                  textColor: Colors.white,
                  padding: EdgeInsets.all(16),
                  onPressed: () {
                    final phone = _phoneController.text.trim();

                    loginUser(phone, context);
                  },
                  color: Colors.blue,
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
