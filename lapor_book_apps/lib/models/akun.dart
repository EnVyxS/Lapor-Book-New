class Akun {
  final String uid;
  final String docId;

  final String? profile; //masih error
  final String nama;
  final String noHP;
  final String email;
  final String role;

  Akun(
      {required this.profile,
      required this.uid,
      required this.docId,
      required this.nama,
      required this.noHP,
      required this.email,
      required this.role});
}
