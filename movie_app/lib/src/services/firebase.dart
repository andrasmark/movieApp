import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addUserDetails(String userName, String userBio) async {
  await FirebaseFirestore.instance
      .collection('users')
      .add({'userName': userName, 'userBio': userBio});
}

Future<void> updateUserDetails(
    String userId, String userName, String userBio) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'userName': userName,
      'userBio': userBio,
    });
    print('User details updated successfully');
  } catch (e) {
    print('Failed to update user details: $e');
  }
}

final user = FirebaseAuth.instance.currentUser;
List<String> docIDs = [];

Future getIds() async {
  await FirebaseFirestore.instance.collection('users').get().then(
        (snapshot) => snapshot.docs.forEach(
          (document) {
            print(document.reference);
            docIDs.add(document.reference.id);
          },
        ),
      );
}
