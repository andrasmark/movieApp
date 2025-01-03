import 'package:flutter/material.dart';

import 'package:movie_app/src/models/actor_details_model.dart';
import 'package:movie_app/src/models/movie_model.dart';
import 'package:movie_app/src/components/MovieCardWidget.dart';

import 'package:movie_app/src/services/api.dart';

class ActorDetailsPage extends StatefulWidget {
  static String id = 'actor_details_page';
  final int actorID;

  const ActorDetailsPage({Key? key, required this.actorID}) : super(key: key);

  @override
  State<ActorDetailsPage> createState() => _ActorDetailsPageState();
}

class _ActorDetailsPageState extends State<ActorDetailsPage> {
  late Future<ActorDetailsModel> actorDetails;
  late Future<List<Movie>> recentProjects;

  final Api api = Api();

  @override
  void initState() {
    super.initState();
    fetchActorData();
  }

  void fetchActorData() {
    actorDetails = api.getActorDetails(widget.actorID);
    recentProjects = api.getActorRecentProjects(widget.actorID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actor Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: actorDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final actor = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Actor Profile Image
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image(
                        image: actor.profilePath.isNotEmpty
                            ? NetworkImage('https://image.tmdb.org/t/p/w500${actor.profilePath}')
                            : const NetworkImage('https://via.placeholder.com/150'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Actor Name
                  Text(
                    actor.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  // Actor Biography
                  const Text(
                    'Biography',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    actor.biography.isNotEmpty
                        ? actor.biography
                        : 'Biography not available.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  // Recent Projects
                  const Text(
                    'Recent Projects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<Movie>>(
                    future: recentProjects,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text('Failed to load recent projects.'),
                        );
                      } else if (snapshot.hasData) {
                        final projects = snapshot.data!;
                        if (projects.isEmpty) {
                          return const Text('No recent projects available.');
                        }
                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: projects.length,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 15,
                            childAspectRatio: 2 / 3,
                          ),
                          itemBuilder: (context, index) {
                            return MovieCardWidget(movie: projects[index]);
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
