import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/board_catalog.dart';
import 'catalog_repository.dart';

/// The repository for Kanban board catalog using Google Firebase Cloud Firestore.
class CloudFirestoreCatalogRepository implements CatalogRepository {
  @override
  Future<BoardCatalog> load() {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((value) {
      if (value.data()!.containsKey('catalog')) {
        return BoardCatalog.fromJson(value.data()!['catalog']);
      }

      return BoardCatalog();
    });
  }

  @override
  Future<BoardCatalog> save(BoardCatalog catalog) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'catalog': catalog.toJson()});

    return catalog;
  }
}
