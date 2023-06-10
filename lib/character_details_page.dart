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
        child: Center(
          child: Column(
            children: [
              _CharacterImage(
                widget: widget,
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(widget.characterModel.gender ?? ""),
                    Text(widget.characterModel.status ?? ""),
                    Text(
                      widget.characterModel.origin?.name ?? "",
                      textAlign: TextAlign.center,
                    ),
                    Text(widget.characterModel.gender ?? "")
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : _CharacterAppearsInEpisode(
                      episodeModelList: _episodeModelList),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterAppearsInEpisode extends StatelessWidget {
  const _CharacterAppearsInEpisode({
    required List<EpisodeModel>? episodeModelList,
  }) : _episodeModelList = episodeModelList;

  final List<EpisodeModel>? _episodeModelList;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: _episodeModelList?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          return Card(
              elevation: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(_episodeModelList?[index].episode ?? ""),
                ],
              ));
        },
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
        height: 150,
        width: 150,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
                image: NetworkImage(widget.characterModel.image ?? ""))),
      ),
    );
  }
}
