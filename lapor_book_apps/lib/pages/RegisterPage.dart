import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lapor_book_apps/components/input_widget.dart';
import 'package:lapor_book_apps/components/styles.dart';
import 'package:lapor_book_apps/components/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lapor_book_apps/pages/dashboard/ProfilePage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return RegisterStatePage();
  }
}

class RegisterStatePage extends State<RegisterPage> {
  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isHide = true;
  bool isHide2 = true;

  String? nama;
  String? email;
  String? noHp;

  final TextEditingController _password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Regiser",
                      style: headerStyle(level: 1),
                    ),
                    Container(
                      child: const Text(
                        'Create your profile to start your journey',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            children: [
                              InputLayout(
                                  'Nama',
                                  TextFormField(
                                    onChanged: (String value) => setState(() {
                                      nama = value;
                                    }),
                                    validator: notEmptyValidator,
                                    decoration:
                                        customInputDecoration("Nama Lengkap"),
                                  )),
                              InputLayout(
                                  'Email',
                                  TextFormField(
                                    onChanged: (String value) => setState(() {
                                      email = value;
                                    }),
                                    validator: notEmptyValidator,
                                    decoration: customInputDecoration(
                                        "email@email.com"),
                                  )),
                              InputLayout(
                                  'No. Handphone',
                                  TextFormField(
                                    onChanged: (String value) => setState(() {
                                      noHp = value;
                                    }),
                                    validator: notEmptyValidator,
                                    decoration:
                                        customInputDecoration("+62 89xxxxxxxx"),
                                  )),
                              InputLayout(
                                  'Password',
                                  TextFormField(
                                    controller: _password,
                                    validator: notEmptyValidator,
                                    obscureText: isHide,
                                    decoration: customInputDecoration(
                                      "",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                            isHide
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.grey),
                                        onPressed: () {
                                          setState(() {
                                            isHide = !isHide;
                                          });
                                        },
                                      ),
                                    ),
                                  )),
                              InputLayout(
                                  'Konfirmasi Password',
                                  TextFormField(
                                    validator: (value) =>
                                        passConfirmationValidator(
                                            value, _password),
                                    obscureText: isHide2,
                                    decoration: customInputDecoration(
                                      "Konfirmasi Password",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                            isHide2
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.grey),
                                        onPressed: () {
                                          setState(() {
                                            isHide2 = !isHide2;
                                          });
                                        },
                                      ),
                                    ),
                                  )),
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                width: double.infinity,
                                child: FilledButton(
                                  style: buttonStyle,
                                  child: Text(
                                    'Register',
                                    style: headerStyle(level: 2),
                                  ),
                                  onPressed: () {
                                    if (_formkey.currentState!.validate()) {
                                      register();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sudah punya akun? '),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            'Login disini',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  // void register() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     CollectionReference akunCollection = _db.collection('akun');

  //     final pass = _password.text;
  //     await _auth.createUserWithEmailAndPassword(email: email!, password: pass);

  //     final docId = akunCollection.doc().id;
  //     await akunCollection.doc(docId).set({
  //       'uid': _auth.currentUser!.uid,
  //       'nama': nama,
  //       'email': email,
  //       'noHp': noHp,
  //       'docId': docId,
  //       'role': 'user',
  //     });

  //     Navigator.pushNamedAndRemoveUntil(
  //         context, '/login', ModalRoute.withName('/login'));
  //   } catch (e) {
  //     final snackbar = SnackBar(content: Text(e.toString()));
  //     ScaffoldMessenger.of(context).showSnackBar(snackbar);
  //     print(e);
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  void register() async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference akunCollection = _db.collection('akun');

      final password = _password.text;
      await _auth.createUserWithEmailAndPassword(
          email: email!, password: password);

      final docId = akunCollection.doc().id;
      await akunCollection.doc(docId).set({
        'uid': _auth.currentUser!.uid,
        'profile': '',
        'nama': nama,
        'email': email,
        'noHP': noHp,
        'docId': docId,
        'role': 'user',
      });

      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('/login'));
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}