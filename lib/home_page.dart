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
  final TextEditingController _controller = TextEditingController();
  List<Results> filterCharacterList = [];
  List<Results>? _exampleCharacters;
  List<Results>? _allCharacters;

  Dio networkManager =
      Dio(BaseOptions(baseUrl: "https://rickandmortyapi.com/api/"));

  bool isLoading = false;
  bool isDownloading = false;

  void isLoadingCircular() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  Future<void> fetchData() async {
    isLoadingCircular();
    final response = await networkManager.get('character');
    if (response.statusCode == HttpStatus.ok) {
      final charactersList = response.data["results"];
      if (charactersList is List) {
        _exampleCharacters =
            charactersList.map((e) => Results.fromJson(e)).toList();
      }
    }
    isLoadingCircular();
  }

  Future<void> fetchDataWithNamed() async {
    List<Results> charactersList = [];
    final response = await networkManager.get('character');
    if (response.statusCode == HttpStatus.ok) {
      final responseData = response.data["info"];
      Info info = Info.fromJson(responseData);
      int? count = info.count;
      for (int i = 1; i <= (count ?? 0); i++) {
        final response = await networkManager.get('character/$i');
        if (response.statusCode == HttpStatus.ok) {
          Results characterModel = Results.fromJson(response.data);
          charactersList.add(characterModel);
        }
      }
    }
    setState(() {
      isDownloading = !isDownloading;
      _allCharacters = charactersList;
    });
  }

  void filter(String name) {
    if (_allCharacters != null) {
      setState(() {
        filterCharacterList = _allCharacters!
            .where(
                (data) => data.name!.toLowerCase().contains(name.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchDataWithNamed();
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
        child: Column(
          children: [
            SizedBox(
              height: 75,
              child: TextField(
                keyboardType: TextInputType.name,
                enabled: isDownloading,
                controller: _controller,
                onChanged: (value) => filter(value),
                decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrangeAccent)),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrangeAccent)),
                    border: const OutlineInputBorder(),
                    hintText: isDownloading
                        ? "Now you can search for characters !"
                        : "Please Wait ..."),
              ),
            ),
            _controller.text.isEmpty
                ? Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: _exampleCharacters?.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CharacterDetails(
                                  characterModel: Results(
                                      name: _exampleCharacters?[index].name,
                                      status: _exampleCharacters?[index].status,
                                      image: _exampleCharacters?[index].image,
                                      gender: _exampleCharacters?[index].gender,
                                      origin: _exampleCharacters?[index].origin,
                                      episode:
                                          _exampleCharacters?[index].episode),
                                ),
                              ));
                            },
                            child: _exampleCharactersCardWidget(
                                index: index, characters: _exampleCharacters));
                      },
                    ),
                  )
                : Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: filterCharacterList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CharacterDetails(
                                  characterModel: Results(
                                      name: filterCharacterList[index].name,
                                      status: filterCharacterList[index].status,
                                      image: filterCharacterList[index].image,
                                      gender: filterCharacterList[index].gender,
                                      origin: filterCharacterList[index].origin,
                                      episode:
                                          filterCharacterList[index].episode),
                                ),
                              ));
                            },
                            child: _exampleCharactersCardWidget(
                                index: index, characters: filterCharacterList));
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _exampleCharactersCardWidget extends StatelessWidget {
  const _exampleCharactersCardWidget({
    required int index,
    required List<Results>? characters,
  })  : _exampleCharacters = characters,
        _index = index;

  final List<Results>? _exampleCharacters;
  final int _index;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Hero(
            tag: _exampleCharacters?[_index].name ?? "",
            child: Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                      image: NetworkImage(
                          _exampleCharacters?[_index].image ?? ""))),
            ),
          ),
          Text(
            _exampleCharacters?[_index].name ?? "",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.deepOrangeAccent, fontWeight: FontWeight.w800),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_exampleCharacters?[_index].gender == "Male")
                const Icon(Icons.male_outlined),
              if (_exampleCharacters?[_index].gender == "Female")
                const Icon(Icons.female_outlined),
              if (_exampleCharacters?[_index].gender == "unknown")
                const Icon(Icons.question_mark_outlined),
              Text(
                _exampleCharacters?[_index].gender ?? "",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.deepOrangeAccent,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_exampleCharacters?[_index].status == "Alive")
                SizedBox(
                    height: 15,
                    child: Image.asset('assets/icons/greendot.png')),
              if (_exampleCharacters?[_index].status == "Dead")
                SizedBox(
                    height: 15, child: Image.asset('assets/icons/reddot.png')),
              if (_exampleCharacters?[_index].status == "unknown")
                SizedBox(
                    height: 15,
                    child: Image.asset('assets/icons/blackdot.png')),
              Text(
                _exampleCharacters?[_index].status ?? "",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.deepOrangeAccent,
                    fontWeight: FontWeight.w200,
                    fontStyle: FontStyle.italic),
              ),
            ],
          )
        ],
      ),
    );
  }
}
