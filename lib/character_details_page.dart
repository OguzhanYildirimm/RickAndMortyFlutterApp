import 'dart:io';

import 'package:demo_application/episode_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'model.dart';

class CharacterDetails extends StatefulWidget {
  CharacterDetails({super.key, required this.characterModel});

  @override
  State<CharacterDetails> createState() => _CharacterDetailsState();

  Results characterModel = Results();
}

class _CharacterDetailsState extends State<CharacterDetails> {
  Dio networkManager = Dio();
  List<EpisodeModel>? _episodeModelList;
  bool isLoading = false;

  void isLoadingCircular() {
    isLoading = !isLoading;
  }

  Future<void> getEpisodes(List<String> episodeUrl) async {
    isLoadingCircular();
    List<EpisodeModel> episodeModelList = [];

    for (String url in episodeUrl) {
      final response = await networkManager.get(url);

      if (response.statusCode == HttpStatus.ok) {
        EpisodeModel episodeModel = EpisodeModel.fromJson(response.data);
        episodeModelList.add(episodeModel);
      }
    }
    setState(() {
      _episodeModelList = episodeModelList;
    });
    isLoadingCircular();
  }

  @override
  void initState() {
    super.initState();
    getEpisodes(widget.characterModel.episode ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.characterModel.name ?? "",
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _detailsWidget(context),
            const Divider(
              thickness: 2.5,
              color: Colors.black,
            ),
            SizedBox(
              height: 30,
              child: Text(
                "Episode(s) of the character.",
                textAlign: TextAlign.start,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _episodeModelList?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 5,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepOrangeAccent,
                        child: Text(
                          _episodeModelList?[index].id.toString() ?? "",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      trailing: Text(
                        _episodeModelList?[index].episode ?? "",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w300),
                      ),
                      title: Text(
                        _episodeModelList?[index].name ?? "",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _episodeModelList?[index].airDate ?? "",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.black54),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _detailsWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CharacterImage(
            widget: widget,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  _detailsCustomWidget(context, "assets/icons/gender.png",
                      "Gender", widget.characterModel.gender ?? ""),
                  const SizedBox(
                    width: 50,
                  ),
                  _detailsCustomWidget(context, "assets/icons/pulse-line.png",
                      "Status", widget.characterModel.status ?? "")
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  _detailsCustomWidget(
                      context,
                      "assets/icons/home.png",
                      "Origin",
                      widget.characterModel.origin?.name?.split(" ").first ??
                          ""),
                  const SizedBox(
                    width: 50,
                  ),
                  _detailsCustomWidget(
                      context,
                      "assets/icons/location.png",
                      "Location",
                      widget.characterModel.location?.name?.split(" ").first ??
                          "")
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  SizedBox _detailsCustomWidget(BuildContext context, String iconString,
      String detailName, String detailInfo) {
    return SizedBox(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 5,
            child: Image.asset(
              iconString,
              height: 30,
            ),
          ),
          Text(
            detailName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.deepOrangeAccent,
                fontWeight: FontWeight.w800,
                fontSize: 16),
          ),
          Text(
            detailInfo,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12),
          )
        ],
      ),
    );
  }
}

class _CharacterImage extends StatelessWidget {
  const _CharacterImage({
    required this.widget,
  });

  final CharacterDetails widget;
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.characterModel.name ?? "",
      child: Container(
        height: 190,
        width: 190,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            image: DecorationImage(
                image: NetworkImage(widget.characterModel.image ?? ""))),
      ),
    );
  }
}
