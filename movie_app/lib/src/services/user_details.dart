// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
//
// class GetUserDetails extends StatelessWidget {
//   final String documentId;
//
//   GetUserDetails({required this.documentId});
//   @override
//   Widget build(BuildContext context) {
//     //get the collection
//     CollectionReference users = FirebaseFirestore.instance.collection('users');
//
//     return FutureBuilder<DocumentSnapshot>(
//         future: users.doc(documentId).get(),
//         builder: ((context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             Map<String, String> data =
//                 snapshot.data!.data() as Map<String, String>;
//             return Text('Username: ${data['userName']}');
//           }
//           return Text('Loading..,');
//         }));
//   }
// }
