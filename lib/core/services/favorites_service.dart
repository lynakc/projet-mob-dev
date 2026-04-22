import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  final _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // Ajouter favori
  Future<void> addFavorite(String title) async {
    await _db
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .doc(title) // id = title (simple)
        .set({
      "title": title,
    });
  }

  // Supprimer favori
  Future<void> removeFavorite(String title) async {
    await _db
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .doc(title)
        .delete();
  }

  // Vérifier si favori
  Stream<bool> isFavorite(String title) {
    return _db
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .doc(title)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<QuerySnapshot> getFavorites() {
    return _db
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .snapshots();
  }
}