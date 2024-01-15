import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_book_apps/components/like_button.dart';
import 'package:lapor_book_apps/components/status_dialog.dart';
import 'package:lapor_book_apps/components/styles.dart';
import 'package:lapor_book_apps/models/akun.dart';
import 'package:lapor_book_apps/models/laporan.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isLoading = false;
  String? status;
  bool isLiked = false;
  TextEditingController commentController = TextEditingController();
  List<String> comments = [];

  Future launch(String uri) async {
    if (uri == '') return;
    if (!await launchUrl(Uri.parse(uri))) {
      throw Exception('Tidak dapat memanggil : $uri');
    }
  }

  void statusDialog(Laporan laporan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatusDialog(
          laporan: laporan,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Laporan laporan = arguments['laporan'];
    Akun akun = arguments['akun'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Detail Laporan', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (akun.role == 'admin')
                        Container(
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                status = laporan.status;
                              });
                              statusDialog(laporan);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Ubah Status'),
                          ),
                        ),
                      Text(
                        laporan.judul,
                        style: headerStyle(level: 3),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                laporan.gambar != ''
                                    ? Image.network(laporan.gambar!)
                                    : Image.asset('assets/images/emperor.jpg'),
                                LikeButton(
                                  isLiked: isLiked,
                                  onTap: () async {
                                    if (!isLiked) {
                                      setState(() {
                                        saveLikeData(laporan.docId);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          laporan.status == 'Posted'
                              ? textStatus(
                                  'Posted', Colors.yellow, Colors.black)
                              : laporan.status == 'Process'
                                  ? textStatus(
                                      'Process', Colors.green, Colors.white)
                                  : textStatus(
                                      'Done', Colors.blue, Colors.white),
                          textStatus(
                              laporan.instansi, Colors.white, Colors.black),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Center(child: Text('Nama Pelapor')),
                        subtitle: Center(
                          child: Text(laporan.nama),
                        ),
                        trailing: const SizedBox(width: 45),
                      ),
                      ListTile(
                        leading: const Icon(Icons.date_range),
                        title: const Center(child: Text('Tanggal Laporan')),
                        subtitle: Center(
                            child: Text(DateFormat('dd MMMM yyyy')
                                .format(laporan.tanggal))),
                        trailing: IconButton(
                          icon: const Icon(Icons.location_on),
                          onPressed: () {
                            launch(laporan.maps);
                          },
                        ),
                      ),
                      const SizedBox(height: 50),
                      Text(
                        'Deskripsi Laporan',
                        style: headerStyle(level: 3),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(laporan.deskripsi ?? ''),
                      ),

                      // Bagian untuk menampilkan dan menambahkan komentar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Komentar',
                            style: headerStyle(level: 3),
                          ),
                          const SizedBox(height: 10),
                          // FutureBuilder<List<Komentar>>(
                          //   future: getCommentsData(laporan.docId),
                          //   builder: (context, snapshot) {
                          //     if (snapshot.connectionState ==
                          //         ConnectionState.waiting) {
                          //       return CircularProgressIndicator();
                          //     } else if (snapshot.hasError) {
                          //       return Text('Error: ${snapshot.error}');
                          //     } else if (!snapshot.hasData ||
                          //         snapshot.data!.isEmpty) {
                          //       return Text('Tidak ada komentar.');
                          //     } else {
                          //       // Menampilkan daftar komentar
                          //       return Column(
                          //         children: (snapshot.data as List<Komentar>)
                          //             .map((comment) => ListTile(
                          //                   title: Text(comment.nama),
                          //                   subtitle: Text(comment.isi),
                          //                   trailing: Text(
                          //                       DateFormat('dd MMM yyyy HH:mm')
                          //                           .format(comment.waktu)),
                          //                 ))
                          //             .toList(),
                          //       );
                          //     }
                          //   },
                          // ),
                          FutureBuilder<List<Komentar>>(
                            future: getCommentsData(laporan.docId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Text('Tidak ada komentar.');
                              } else {
                                // Menampilkan daftar komentar
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    Komentar comment = snapshot.data![index];
                                    return ListTile(
                                      title: Text(comment.nama),
                                      subtitle: Text(comment.isi),
                                      trailing: Text(
                                        DateFormat('dd MMM yyyy HH:mm')
                                            .format(comment.waktu),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: commentController,
                                  decoration: const InputDecoration(
                                    hintText: 'Tambahkan komentar...',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () async {
                                  setState(() {
                                    addComment(laporan.docId);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

//   @override
// void initState() {
//   super.initState();
//   // Panggil fungsi untuk mengambil data komentar pada saat widget dibuat
//   getCommentsData();
// }

  Container textStatus(String text, var bgcolor, var textcolor) {
    return Container(
      width: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgcolor,
        border: Border.all(width: 1, color: primaryColor),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: TextStyle(color: textcolor),
      ),
    );
  }

  Future<void> saveLikeData(String docId) async {
    try {
      CollectionReference laporanCollection =
          FirebaseFirestore.instance.collection('laporan');

      final String uid = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot likeDoc =
          await laporanCollection.doc(docId).collection('likes').doc(uid).get();

      if (!likeDoc.exists) {
        await laporanCollection.doc(docId).collection('likes').doc(uid).set({
          'timestamp': FieldValue.serverTimestamp(),
        });

        await laporanCollection.doc(docId).update({
          'like': FieldValue.increment(1),
        });
      }
      if (likeDoc.exists) {
        setState(() {
          isLiked = true;
        });
      }
    } catch (e) {
      print('Error saving like data: $e');
    }
  }

  Future<void> addComment(String docId) async {
    try {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      Akun akun = arguments['akun'];
      CollectionReference laporanCollection =
          FirebaseFirestore.instance.collection('laporan');

      String commentText = commentController.text.trim();

      // Membuat ID unik untuk setiap komentar
      String commentId = DateTime.now().toIso8601String() + Random().nextInt(10000000).toString();

      await laporanCollection
          .doc(docId)
          .collection('comments')
          .doc(commentId)
          .set({
        'uid_akun': akun.uid,
        'nama': akun.nama,
        'comment': commentText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar berhasil ditambahkan'),
        ),
      );

      // Clear the comment text field after successful addition
      commentController.clear();
    } catch (e) {
      print('Error adding comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Gagal menambahkan komentar.'),
        ),
      );
    }
  }

  // Future<List<Komentar>> getCommentsData(String docId) async {
  //   try {
  //     // Ganti 'docId' dengan parameter yang sesuai
  //     QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
  //         .collection('laporan')
  //         .doc(docId)
  //         .collection('comments')
  //         .get();

  //     // Dapatkan data komentar
  //     List<Komentar> comments = commentSnapshot.docs.map((doc) {
  //       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //       return Komentar(
  //         nama: data['nama'] ?? '',
  //         isi: data['comment'] ?? '',
  //         waktu: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  //       );
  //     }).toList();

  //     return comments;
  //   } catch (e) {
  //     print('Error getting comments data: $e');
  //     return [];
  //   }
  // }

  // Future<List<Komentar>> getCommentsData(String docId) async {
  //   try {
  //     // Ganti 'docId' dengan parameter yang sesuai
  //     QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
  //         .collection('laporan')
  //         .doc(docId)
  //         .collection('comments')
  //         .orderBy('timestamp', descending: false)
  //         .get();

  //     // Dapatkan data komentar
  //     List<Komentar> comments = commentSnapshot.docs.map((doc) {
  //       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //       return Komentar(
  //         nama: data['nama'] ?? '',
  //         isi: data['comment'] ?? '',
  //         waktu: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  //       );
  //     }).toList();

  //     // Urutkan komentar berdasarkan waktu (tercepat ke terbaru)
  //     comments.sort((a, b) => a.waktu.compareTo(b.waktu));

  //     return comments;
  //   } catch (e) {
  //     print('Error getting comments data: $e');
  //     return [];
  //   }
  // }

  Future<List<Komentar>> getCommentsData(String docId) async {
    try {
      // Ganti 'docId' dengan parameter yang sesuai
      QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
          .collection('laporan')
          .doc(docId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      // Dapatkan data komentar
      List<Komentar> comments = commentSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Komentar(
          nama: data['nama'] ?? '',
          isi: data['comment'] ?? '',
          waktu: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      return comments;
    } catch (e) {
      print('Error getting comments data: $e');
      return [];
    }
  }
}
