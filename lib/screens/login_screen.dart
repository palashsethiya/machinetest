import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:machinetest/screens/home_screen.dart';
import 'package:machinetest/service/api_service.dart';
import 'package:machinetest/utils/utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ApiService apiService = ApiService();
  final phoneNumber = TextEditingController();
  final otp = TextEditingController();
  bool isLoading = false;
  bool visible = false;
  String errorMessage = "", verificationOTPId = "";
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    Utils.isCheckDeviceRooted(context);
    apiService.callAPIUsingSSL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Container(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Login",
                      style: TextStyle(color: Colors.black87, fontSize: 36.0, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    TextFormField(
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.1),
                            hintText: "Mobile Number"),
                        controller: phoneNumber,
                        inputFormatters: [LengthLimitingTextInputFormatter(10), FilteringTextInputFormatter.digitsOnly],
                        keyboardType: TextInputType.phone),
                    const SizedBox(
                      height: 8.0,
                    ),
                    if (visible)
                      TextFormField(
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.1),
                              hintText: "Enter OTP"),
                          controller: otp,
                          inputFormatters: [LengthLimitingTextInputFormatter(6), FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number),
                    if (visible)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              final phone = phoneNumber.text.trim();

                              if (phone.length != 10) {
                                Utils.showAlertDialog(context, "Alert..!", "Please enter valid Phone Number");
                              } else {
                                otp.text = "";
                                errorMessage = "";
                                loginUser(phone, context);
                              }
                            },
                            child: const Text(
                              "Resend OTP",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: FractionallySizedBox(
                          widthFactor: 0.7,
                          child: ElevatedButton(
                            child: Text(!visible ? "Send OTP" : "Submit"),
                            onPressed: () {
                              if (visible) {
                                if (otp.text.trim().length != 6) {
                                  Utils.showAlertDialog(context, "Alert..!", "Please enter valid OTP");
                                } else {
                                  checkOTPValid();
                                }
                              } else {
                                final phone = phoneNumber.text.trim();

                                if (phone.length != 10) {
                                  Utils.showAlertDialog(context, "Alert..!", "Please enter valid Phone Number");
                                } else {
                                  loginUser(phone, context);
                                }
                              }
                            },
                          )),
                    )
                  ],
                ),
              )),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(backgroundColor: Colors.black12),
            )
        ],
      ),
    );
  }

  Future<bool?> loginUser(String phone, BuildContext context) async {
    setState(() {
      isLoading = true;
      visible = false;
    });

    auth.verifyPhoneNumber(
        phoneNumber: '+91$phone',
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          setState(() {
            isLoading = false;
          });

          Navigator.of(context).pop();

          UserCredential result = await auth.signInWithCredential(credential);

          User? user = result.user;

          if (user != null) {
            print("success");
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(
                          user: user,
                        )));
          } else {
            print("Error");
          }

          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (FirebaseAuthException exception) {
          setState(() {
            isLoading = false;
          });
          Utils.showAlertDialog(context, exception.code, exception.message!);
        },
        codeSent: (String? verificationId, [int? forceResendingToken]) {
          setState(() {
            isLoading = false;
            visible = true;
            verificationOTPId = verificationId!;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {
          setState(() {
            isLoading = false;
          });
        });
  }

  checkOTPValid() async {
    final code = otp.text.trim();
    AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationOTPId, smsCode: code);

    try {
      UserCredential result = await auth.signInWithCredential(credential);

      User? user = result.user;

      if (user != null) {
        print("Success");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                      user: user,
                    )));
      } else {
        print("Error");
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = "${e.code} : ${e.message!}";
      });
    } catch (e) {
      print(e);
      setState(() {
        errorMessage = "Something went wrong";
      });
    }
  }
}
