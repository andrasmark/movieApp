import 'package:flutter/material.dart';

import 'package:movie_app/src/models/actor_model.dart';
import 'package:movie_app/src/pages/actor_details_page.dart';

import 'package:cached_network_image/cached_network_image.dart';

class ActorCardWidget extends StatelessWidget {
  final Actor actor;

  const ActorCardWidget({Key? key, required this.actor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to actor details page via actorID
        Navigator.pushNamed(
          context,
          ActorDetailsPage.id,
          arguments: actor.id,
        );
      },
        child: Card(
          margin: const EdgeInsets.only(right: 10),
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ACTOR PROFILE
                AspectRatio(
                  aspectRatio: 2 / 3,
                  child: CachedNetworkImage(
                    imageUrl: actor.profilePath.isNotEmpty
                        ? 'https://image.tmdb.org/t/p/w500${actor.profilePath}'
                        : 'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                  ),
                ),
                const SizedBox(height: 10),
                // ACTOR NAME
                Text(
                  actor.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                // CHARACTER NAME
                Text(
                  actor.character,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        )
    );
  }
}
