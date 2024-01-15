import 'package:flutter/material.dart';
import '../components/input_widget.dart';
import '../components/styles.dart';
import '../components/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  bool isHide = true;

  bool _isLoading = false;

  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
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
                      const SizedBox(height: 40),
                      const Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        child: const Text(
                          'Login to your account',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            children: [
                              InputLayout(
                                  'Email',
                                  TextFormField(
                                    onChanged: (String value) => setState(() {
                                      email = value;
                                    }),
                                    validator: notEmptyValidator,
                                    decoration: customInputDecoration(
                                        "email@gmail.com"),
                                  )),
                              InputLayout(
                                  'Password',
                                  TextFormField(
                                    onChanged: (String value) => setState(() {
                                      password = value;
                                    }),
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
                              Container(
                                margin: EdgeInsets.only(
                                  top: 20,
                                ),
                                width: double.infinity,
                                child: FilledButton(
                                    style: buttonStyle,
                                    child: Text(
                                      'Login',
                                      style: headerStyle(level: 3, dark: false),
                                    ),
                                    onPressed: () {
                                      if (_formkey.currentState!.validate()) {
                                        login();
                                      }
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Belum punya akun? '),
                          InkWell(
                            onTap: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: const Text(
                              'Daftar disini',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Column(children: [
                        Container(
                          child: Image.asset('assets/images/secure.jpg'),
                          width: 280,
                          height: 280,
                        ),
                      ])
                    ],
                  ),
                )),
    );
  }

  void login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
          email: email!, password: password!);

      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', ModalRoute.withName('/dashboard'));
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
