import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lapor_book_apps/components/styles.dart';
import 'package:lapor_book_apps/models/akun.dart';

class Profile extends StatefulWidget {
  final Akun akun;
  const Profile({super.key, required this.akun});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  ImagePicker picker = ImagePicker();
  XFile? file;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                uploadDialog(context);
              },
              child: CircleAvatar(
                radius: 80,
                backgroundColor: primaryColor,
                child: ClipOval(
                    child: FutureBuilder<String>(
                  future: getImageUrlFromFirestore(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        // Handle error state
                        return Image.asset('assets/images/emperor.jpg',
                            width: 180, height: 180);
                      }

                      String? imageUrl = snapshot.data;

                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        // 'profile' field exists and has a valid URL
                        return Image.network(imageUrl, width: 160, height: 160);
                      } else {
                        // 'profile' field does not exist or is empty
                        // Set the 'profile' field to a default URL or handle it as needed
                        // Note: This is just an example; you should replace 'default_image_url'
                        // with your actual default image URL or handle it according to your logic.
                        return Image.asset('assets/images/emperor.jpg',
                            width: 180, height: 180);
                      }
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else {
                      return Image.asset('assets/images/emperor.jpg',
                          width: 180, height: 180);
                    }
                  },
                )),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              widget.akun.nama,
              style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
            ),
            Text(
              widget.akun.role,
              style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: primaryColor),
                ), // Sudut border
              ),
              child: Text(
                widget.akun.noHP,
                style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: primaryColor),
                ), // Sudut border
              ),
              child: Text(
                widget.akun.email,
                style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            SizedBox(
              height: 35,
            ),
            Container(
              width: double.infinity,
              child: FilledButton(
                style: buttonStyle,
                onPressed: () {
                  keluar(context);
                },
                child: Text('Logout',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
            SizedBox(
              height: 35,
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> uploadDialog(BuildContext context) {
    CollectionReference akunCollection = _firestore.collection('akun');

    return showDialog(
      context: context,
      builder: (BuildContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Pilih sumber'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          XFile? upload = await picker.pickImage(
                              source: ImageSource.camera);

                          setState(() {
                            file = upload;
                          });
                        },
                        child: const Text('Camera'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          XFile? upload = await picker.pickImage(
                              source: ImageSource.gallery);

                          setState(() {
                            file = upload;
                          });
                        },
                        child: const Text('Gallery'),
                      ),
                    ],
                  ),
                  if (file != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            String url = await uploadImage();

                            await akunCollection
                                // .doc(_auth.currentUser!.uid)
                                .doc(widget.akun.docId)
                                .update({'profile': url});
                            Navigator.of(context).pop();
                          },
                          child: const Text('Save'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              file = null;
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('Abort'),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String> uploadImage() async {
    if (file == null) return '';

    String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      Reference dirUpload =
          _storage.ref().child('profile/${_auth.currentUser!.uid}');
      Reference storedDir = dirUpload.child(uniqueFilename);

      await storedDir.putFile(File(file!.path));

      return await storedDir.getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  Future<String> getImageUrlFromFirestore() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('akun')
        .doc(widget.akun.docId)
        .get();

    String? profileUrl = snapshot['profile'];

    if (profileUrl != null && profileUrl.isNotEmpty) {
      return profileUrl;
    } else {
      // Jika profil kosong atau tidak ada, kembalikan URL gambar default
      return '';
    }
  }

  void keluar(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', ModalRoute.withName('/login'));
  }
}