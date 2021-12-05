import 'dart:async';
import 'dart:convert';

import 'package:chuckapi/app_theme.dart';
import 'package:chuckapi/config.dart';
import 'package:chuckapi/theme.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

import 'package:chuckapi/joke.dart';

void main() {
  setPathUrlStrategy();
  runApp(const MyHomePage());
}

Future<Joke> fetchJoke() async {
  final response = await http.get(
    Uri.parse('https://api.chucknorris.io/jokes/random'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Joke.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Joke> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchJoke();
    _loadStart();
    currentTheme.addListener(() {
      setState(() {});
    });
  }

  _loadStart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    MyTheme.isDark = (prefs.getBool('isDark') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChuckAPI',
      darkTheme: darkTheme(), // dark theme
      theme: lightTheme(), // light theme
      themeMode: currentTheme.currentTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ChuckApi'),
          actions: [
            IconButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                currentTheme.switchTheme(prefs);
              },
              icon: const Icon(Icons.dark_mode),
            ),
          ],
        ),
        body: Center(
          child: Center(
            child: FutureBuilder<Joke>(
              future: futureAlbum,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(snapshot.data!.value),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            setState(() {
              futureAlbum = fetchJoke();
            });
          },
          tooltip: 'Next Joke',
          child: const Icon(Icons.refresh_outlined),
        ),
      ),
    );
  }
}
