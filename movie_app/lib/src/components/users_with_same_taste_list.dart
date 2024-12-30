import 'package:flutter/material.dart';

import '../pages/friend_page.dart';
import '../services/firebase.dart';

class UsersWithSameTasteList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>?>>(
      future: fetchUsersWithSameTaste(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No recommended friends found'));
        }

        final recommendedFriends = snapshot.data!;
        return ListView.builder(
          itemCount: recommendedFriends.length,
          itemBuilder: (context, index) {
            final friend = recommendedFriends[index];
            final friendId = friend?['uid'];
            return ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(friend?['userName'] ?? 'Unknown'),
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
