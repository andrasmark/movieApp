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

Future<void> addFriend(String friendUid) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'friends': FieldValue.arrayUnion([friendUid]),
      });
      print('Friend added successfully');
    } catch (e) {
      print('Error adding friend: $e');
    }
  }
}

Future<void> removeFriend(String friendUid) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'friends': FieldValue.arrayRemove([friendUid]),
      });
      print('Friend removed successfully');
    } catch (e) {
      print('Error removing friend: $e');
    }
  }
}

Future<List<Map<String, dynamic>?>> fetchFriends() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final friendUids = List<String>.from(snapshot.data()?['friends'] ?? []);
      final friends = await Future.wait(friendUids.map((uid) async {
        final friendSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final friendData = friendSnapshot.data();
        if (friendData != null) {
          friendData['uid'] = uid;
        }
        return friendData;
      }));
      return friends;
    } catch (e) {
      print('Error fetching friends: $e');
      return [];
    }
  }
  return [];
}

Future<List<Map<String, dynamic>?>> fetchRecommendedFriends() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  try {
    // Fetch the current user's friend list
    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final currentUserFriends =
        List<String>.from(currentUserDoc.data()?['friends'] ?? []);

    // Collect recommended friends
    final Set<String> recommendedFriendIds = {};
    for (String friendId in currentUserFriends) {
      final friendDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .get();
      final friendsOfFriend =
          List<String>.from(friendDoc.data()?['friends'] ?? []);

      // Exclude current user's friends and the user themselves
      for (String recommendedId in friendsOfFriend) {
        if (!currentUserFriends.contains(recommendedId) &&
            recommendedId != user.uid) {
          recommendedFriendIds.add(recommendedId);
        }
      }
    }

    // Fetch details of recommended friends
    final recommendedFriends = await Future.wait(recommendedFriendIds.map(
      (uid) async {
        final friendDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final friendData = friendDoc.data();
        if (friendData != null) {
          friendData['uid'] = uid;
        }
        return friendData;
      },
    ));
    return recommendedFriends;
  } catch (e) {
    print('Error fetching recommended friends: $e');
    return [];
  }
}

Future<List<Map<String, dynamic>?>> fetchUsersWithSameTaste() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  try {
    // Fetch the current user's rated movies
    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final currentUserRatings = currentUserDoc.data()?['ratedMovies'] ?? {};

    // Fetch the current user's friends
    final currentUserFriends =
        List<String>.from(currentUserDoc.data()?['friends'] ?? []);

    // Filter movies rated above 3 by the current user
    final highRatedMovies = currentUserRatings.entries
        .where((entry) => (entry.value is num) && (entry.value > 3))
        .map((entry) => entry.key)
        .toSet();

    print("Current User High Rated Movies: $highRatedMovies");

    if (highRatedMovies.isEmpty) return [];

    // Query all users
    final allUsers = await FirebaseFirestore.instance.collection('users').get();
    final similarUsers = <Map<String, dynamic>>[];

    for (var doc in allUsers.docs) {
      if (doc.id == user.uid) continue; // Skip the current user

      // Check if the user is already a friend
      if (currentUserFriends.contains(doc.id)) continue;

      final userRatings = doc.data()['ratedMovies'] ?? {};
      final userHighRatedMovies = userRatings.entries
          .where((entry) => (entry.value is num) && (entry.value > 3))
          .map((entry) => entry.key)
          .toSet();

      // Find intersection of high-rated movies
      final commonMovies = highRatedMovies.intersection(userHighRatedMovies);
      print('Common Movies for ${doc.id}: $commonMovies');

      if (commonMovies.isNotEmpty) {
        final userData = doc.data();
        userData['uid'] = doc.id;
        similarUsers.add(userData);
      }
    }

    print('Similar Users Found: ${similarUsers.length}');
    return similarUsers;
  } catch (e) {
    print('Error fetching users with similar ratings: $e');
    return [];
  }
}
