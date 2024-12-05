import 'package:flutter/material.dart';

import '../pages/friend_page.dart';
import '../services/firebase.dart';

class FriendsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>?>>(
      future: fetchFriends(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No friends found'));
        }

        final friends = snapshot.data!;
        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            final friendId = friend?['uid'];
            return ListTile(
              leading: Icon(Icons.account_circle),
              title: Text(
                friend?['userName'] ?? 'Unknown',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(friend?['userBio'] ?? ''),
              onTap: () {
                if (friendId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendPage(friendId: friendId),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
