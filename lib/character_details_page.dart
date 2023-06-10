import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'model.dart';

class CharacterDetails extends StatefulWidget {
  const CharacterDetails({super.key, required this.characterId});

  @override
  State<CharacterDetails> createState() => _CharacterDetailsState();

  final String characterId;
}

class _CharacterDetailsState extends State<CharacterDetails> {
  Results? _characterDetail;
  Dio networkManager =
      Dio(BaseOptions(baseUrl: "https://rickandmortyapi.com/api/character/"));
  bool isLoading = false;

  void isLoadingCircular() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  Future<void> fetchData() async {
    isLoadingCircular();
    final response = await networkManager.get(widget.characterId);
    if (response.statusCode == HttpStatus.ok) {
      final characterDetail = response.data;
      _characterDetail = Results.fromJson(characterDetail);
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
        title: Text(_characterDetail?.name.toString() ?? ""),
      ),
    );
  }
}
