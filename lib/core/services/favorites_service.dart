import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/audio_model.dart';

class FavoritesService {
  final _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  String generateId(AudioModel audio) {
    return audio.url.hashCode.toString();
  }

  Future<void> addFavorite(AudioModel audio) async {
    final id = generateId(audio);

    await _db
      .collection("users")
      .doc(uid)
      .collection("favorites")
      .doc(id)
      .set({
        "id": id,
        "titleAr": audio.titleAr,
        "titleEn": audio.titleEn,
        "url": audio.url,
        "reciter": audio.reciter,
    });
  }

  Future<void> removeFavorite(AudioModel audio) async {
    final id = generateId(audio);

    await _db
      .collection("users")
      .doc(uid)
      .collection("favorites")
      .doc(id)
      .delete();
  }

  Stream<bool> isFavorite(AudioModel audio) {
    final id = generateId(audio);

    return _db
      .collection("users")
      .doc(uid)
      .collection("favorites")
      .doc(id)
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