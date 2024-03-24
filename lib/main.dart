import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class Music {
  final String name;
  final String url;

  Music({required this.name, required this.url});

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      name: json['name'],
      url: json['url'],
    );
  }
}

class MusicService {
  static Future<List<Music>> fetchMusic() async {
    final response = await http.get(Uri.parse('../musicPlayer/songs_list.php'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      // print(data.toString());
      return data.map((json) => Music.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load music');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Server Music Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MusicPlayerScreen();
  }
}

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  MusicPlayerScreenState createState() => MusicPlayerScreenState();
}

class MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late AudioPlayer _audioPlayer;
  late List<Music> _musicList;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    // MusicService.apiUrl = '../musicPlayer';
    _musicList = [];
    _loadMusic();
  }

  Future<void> _loadMusic() async {
    try {
      final musicList = await MusicService.fetchMusic();
      setState(() {
        _musicList = musicList;
      });
    } catch (e) {
      print('Failed to load music: $e');
    }
  }

  Future<void> _playMusic(String url) async {
    String tmp = '../musicPlayer/$url';
    print(tmp);
    await _audioPlayer.setUrl(tmp);
    await _audioPlayer.play();
  }

  void _playNextMusic() {
    if (_currentIndex < _musicList.length - 1) {
      _currentIndex++;
      _playMusic(_musicList[_currentIndex].url);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('음악 세상'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _playNextMusic,
              child: const Text('다음 곡'),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _musicList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(_musicList[index].name),
                      onTap: () {
                        print(_musicList[index].url);
                        _playMusic(_musicList[index].url);
                      });
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 2,
                    color: Colors.blueAccent,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _playNextMusic,
        child: const Icon(Icons.skip_next),
      ),
    );
  }
}
