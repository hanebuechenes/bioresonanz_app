import 'package:flutter/material.dart';
import 'audio_service.dart';

void main() {
  runApp(const BioresonanzApp());
}

class BioresonanzApp extends StatelessWidget {
  const BioresonanzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bioresonanz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bioresonanz App')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isPlaying ? 'Wiedergabe läuft...' : 'Bereit zur Wiedergabe',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(_isPlaying ? 'Stop' : 'Play Tone'),
              onPressed: () async {
                if (_isPlaying) {
                  await AudioService.stop();
                } else {
                  await AudioService.playTone('assets/audio/intro.mp3');
                }
                setState(() => _isPlaying = !_isPlaying);
              },
            ),
          ],
        ),
      ),
    );
  }
}
