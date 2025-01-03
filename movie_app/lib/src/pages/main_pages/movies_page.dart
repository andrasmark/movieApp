import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/src/models/search_model.dart';
import 'package:movie_app/src/pages/main_pages/home_page.dart';
import 'package:movie_app/src/pages/main_pages/profile_page.dart';
import 'package:movie_app/src/pages/main_pages/social_page.dart';
import 'package:movie_app/src/pages/movie_details_page.dart';
import 'package:movie_app/src/services/api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../components/NavBar.dart';

class MoviesPage extends StatefulWidget {
  static String id = 'movies_page';

  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final int _selectedIndex = 1;
  TextEditingController searchController = TextEditingController();
  Api apiServices = Api();
  SearchModel? searchModel;

  void search(String query) {
    apiServices.getSearchResults(query).then((results) {
      setState(() {
        searchModel = results;
      });
    });
  }

  @override void dispose() {
    // TODO: implement dispose
    searchController.dispose();
    super.dispose();
  }

  void _onNavBarItemTapped(int index) {
    setState(() {
      // _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, HomePage.id);
          break;
        case 2:
          Navigator.pushReplacementNamed(context, SocialPage.id);
          break;
        case 3:
          Navigator.pushReplacementNamed(context, ProfilePage.id);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Movies'),
          titleTextStyle: const TextStyle(
            fontSize: 25,
            fontFamily: 'Moderustic',
            color: Colors.black,
          ),
        ),
        body: Column(
            children: [
              CupertinoSearchTextField(
                padding: const EdgeInsets.all(10),
                controller: searchController,
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                suffixIcon: const Icon(
                  Icons.cancel,
                  color: Colors.grey,
                ),
                style: const TextStyle(color: Colors.black),
                backgroundColor: Colors.grey.withOpacity(0.3),
                onChanged: (value) {
                  if (value.isEmpty) {} else {
                    search(searchController.text);
                  }
                },
              ),
              searchModel == null
                  ? const SizedBox.shrink()
                  : GridView.builder(
                shrinkWrap: true,
                itemCount: searchModel?.results.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 5,
                    childAspectRatio: 1.2 / 2
                ),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      CachedNetworkImage(
                          imageUrl: "$imageUrl${searchModel!.results[index]
                              .backdropPath}",
                          height: 170),
                      SizedBox(
                        width: 100,
                        child: Text(
                          searchModel!.results[index].originalTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      )

                    ],
                  );
                },
              ),
            ]
        ),
        bottomNavigationBar: NavBar(_selectedIndex, _onNavBarItemTapped),
      );
  }
}
