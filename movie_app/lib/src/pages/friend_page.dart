import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firebase.dart';

class FriendPage extends StatefulWidget {
  final String friendId;

  FriendPage({required this.friendId});

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  bool isFriend = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkFriendshipStatus();
  }

  Future<Map<String, dynamic>?> fetchFriendDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendId)
          .get();
      return snapshot.data();
    } catch (e) {
      print('Error fetching friend details: $e');
      return null;
    }
  }

  Future<void> checkFriendshipStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final friendsList = List<String>.from(userDoc.data()?['friends'] ?? []);
        setState(() {
          isFriend = friendsList.contains(widget.friendId);
          isLoading = false;
        });
      } catch (e) {
        print('Error checking friendship status: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> toggleFriendship() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (isFriend) {
        await removeFriend(widget.friendId);
      } else {
        await addFriend(widget.friendId);
      }
      setState(() {
        isFriend = !isFriend;
        isLoading = false;
      });
    } catch (e) {
      print('Error toggling friendship: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Friend's Profile"),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchFriendDetails(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final friendDetails = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile picture and button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.account_circle, size: 100),
                    isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: toggleFriendship,
                            child:
                                Text(isFriend ? 'Remove Friend' : 'Add Friend'),
                          ),
                  ],
                ),
                SizedBox(height: 20),
                // Username and Bio
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Username: ${friendDetails?['userName'] ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Bio: ${friendDetails?['userBio'] ?? 'N/A'}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
