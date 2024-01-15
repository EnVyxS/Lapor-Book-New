// import 'package:flutter/material.dart';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super_key});

//   @override
//   State<StatefulWidget> createState() => _RegisterPage();
// }

// class _RegisterPage extends State<RegisterPage> {
//   final _formKey = GlobalKey<FormState>();

//   String? nama;
//   String? email;
//   String? noHP;
//   String? password;

//   @override
//   Widget build(BuildContext context) {
//     // throw UnimplementedError();
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: 80, width: double.infinity),
//               const Text(
//                 "Register",
//                 style: TextStyle(
//                   fontSize: 30,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               const Text(
//                 "Create ur profile to start ur journey",
//                 style: TextStyle(color: Colors.grey),
//               ),
//               const SizedBox(height: 20),
//               Container(
//                 child: Form(
//                     key: _formKey,
//                     child: Column(children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text("Name",
//                               style: TextStyle(
//                                   fontSize: 20, fontWeight: FontWeight.bold)),
//                           const SizedBox(height: 5),
//                           Container(
//                               child: TextFormField(
//                             onChanged: (value) {
//                               nama = value;
//                             },
//                             decoration: InputDecoration(
//                                 hintText: "Fullname",
//                                 floatingLabelBehavior:
//                                     FloatingLabelBehavior.never,
//                                 border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10))),
//                           ))
//                         ],
//                       ),
//                       //define imput component
//                       Text("Name"),
//                       Text("Email"),
//                       Text("No. HP"),
//                       Text("Password"),
//                       Text("Confirmation Password"),
//                       FilledButton(onPressed: () {}, child: Text('Register'))
//                     ])),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lapor_book_apps/components/input_widget.dart';
import 'package:lapor_book_apps/components/styles.dart';
import 'package:lapor_book_apps/components/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  void register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      CollectionReference akunCollection = _db.collection('akun');

      final pass = _password.text;
      await _auth.createUserWithEmailAndPassword(email: email!, password: pass);

      final docId = akunCollection.doc().id;
      await akunCollection.doc(docId).set({
        'profile': '', //masih error
        'uid': _auth.currentUser!.uid,
        'nama': nama,
        'email': email,
        'noHp': noHp,
        'docId': docId,
        'role': 'user',
      });

      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('login'));
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