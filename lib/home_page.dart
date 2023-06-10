import 'dart:io';

import 'package:demo_application/character_details_page.dart';
import 'package:demo_application/model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Results>? _characters;
  Dio networkManager =
      Dio(BaseOptions(baseUrl: "https://rickandmortyapi.com/api/"));
  bool isLoading = false;

  void isLoadingCircular() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  Future<void> fetchData() async {
    isLoadingCircular();
    final response = await networkManager.get('character');
    if (response.statusCode == HttpStatus.ok) {
      final characterList = response.data["results"];
      if (characterList is List) {
        _characters = characterList.map((e) => Results.fromJson(e)).toList();
      }
    }
    isLoadingCircular();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          isLoading
              ? const CircularProgressIndicator.adaptive()
              : const SizedBox.shrink()
        ],
        title: Text(
          'Rick And Morty Worlds',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: _characters?.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CharacterDetails(
                      characterId: _characters?[index].id.toString() ?? "",
                    ),
                  ));
                },
                child: _CharactersCardWidget(
                    index: index, characters: _characters));
          },
        ),
      ),
    );
  }
}

class _CharactersCardWidget extends StatelessWidget {
  const _CharactersCardWidget({
    required int index,
    required List<Results>? characters,
  })  : _characters = characters,
        _index = index;

  final List<Results>? _characters;
  final int _index;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: 75,
            width: 75,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                    image: NetworkImage(_characters?[_index].image ?? ""))),
          ),
          Text(
            _characters?[_index].name ?? "",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.deepOrangeAccent, fontWeight: FontWeight.w800),
          ),
          Text(
            _characters?[_index].gender ?? "",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.deepOrangeAccent, fontWeight: FontWeight.w400),
          ),
          Text(
            _characters?[_index].status ?? "",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.deepOrangeAccent,
                fontWeight: FontWeight.w200,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
