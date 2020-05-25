import 'package:cloud_firestore/cloud_firestore.dart';

Stream<DocumentSnapshot> getDocument(DocumentReference document) =>
    document.snapshots();
