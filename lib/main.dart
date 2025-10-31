import 'package:flutter/material.dart';
import 'player_controller.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BioresonanzApp(),
  ));
}

class BioresonanzApp extends StatefulWidget {
  const BioresonanzApp({super.key});

  @override
  State<BioresonanzApp> createState() => _BioresonanzAppState();
}

class _BioresonanzAppState extends State<BioresonanzApp> {
  final PlayerController _controller = PlayerController();

  bool isPlayingStereo = false;
  bool isPlayingSweep = false;

  double volume = 0.5;

  double freqLeft = 440.0;
  double freqRight = 440.0;

  double sweepStart = 100.0;
  double sweepEnd = 1000.0;
  double sweepDuration = 5.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: const Text("Bioresonanz Generator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Text("Lautstärke: ${(volume * 100).toStringAsFixed(0)}%",
                style: const TextStyle(color: Colors.white)),
            Slider(
              value: volume,
              min: 0,
              max: 1,
              onChanged: (v) => setState(() {
                volume = v;
                _controller.volume = volume;
              }),
            ),
            const SizedBox(height: 20),
            const Text("Linker Kanal", style: TextStyle(color: Colors.greenAccent)),
            Text("${freqLeft.toStringAsFixed(1)} Hz",
                style: const TextStyle(color: Colors.white)),
            Slider(
              value: freqLeft,
              min: 20,
              max: 20000,
              onChanged: (v) => setState(() => freqLeft = v),
            ),
            const SizedBox(height: 20),
            const Text("Rechter Kanal", style: TextStyle(color: Colors.greenAccent)),
            Text("${freqRight.toStringAsFixed(1)} Hz",
                style: const TextStyle(color: Colors.white)),
            Slider(
              value: freqRight,
              min: 20,
              max: 20000,
              onChanged: (v) => setState(() => freqRight = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlayingStereo ? Colors.red : Colors.green,
              ),
              icon: Icon(isPlayingStereo ? Icons.stop : Icons.play_arrow),
              label: Text(isPlayingStereo ? "Stop Stereo" : "Play Stereo"),
              onPressed: () async {
                if (!isPlayingStereo) {
                  setState(() => isPlayingStereo = true);
                  await _controller.playStereo(freqLeft, freqRight);
                  setState(() => isPlayingStereo = false);
                } else {
                  await _controller.stop();
                  setState(() => isPlayingStereo = false);
                }
              },
            ),
            const Divider(color: Colors.white, height: 40),
            const Text("Sweep Generator", style: TextStyle(color: Colors.greenAccent)),
            Text("Startfrequenz: ${sweepStart.toStringAsFixed(1)} Hz",
                style: const TextStyle(color: Colors.white)),
            Slider(
              value: sweepStart,
              min: 10,
              max: 10000,
              onChanged: (v) => setState(() => sweepStart = v),
            ),
            Text("Endfrequenz: ${sweepEnd.toStringAsFixed(1)} Hz",
                style: const TextStyle(color: Colors.white)),
            Slider(
              value: sweepEnd,
              min: 10,
              max: 10000,
              onChanged: (v) => setState(() => sweepEnd = v),
            ),
            Text("Dauer: ${sweepDuration.toStringAsFixed(1)} s",
                style: const TextStyle(color: Colors.white)),
            Slider(
              value: sweepDuration,
              min: 1,
              max: 30,
              onChanged: (v) => setState(() => sweepDuration = v),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.multitrack_audio),
              label: Text(isPlayingSweep ? "Stop Sweep" : "Start Sweep"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlayingSweep ? Colors.red : Colors.blue,
              ),
              onPressed: () async {
                if (!isPlayingSweep) {
                  setState(() => isPlayingSweep = true);
                  await _controller.playSweep(sweepStart, sweepEnd, sweepDuration);
                  setState(() => isPlayingSweep = false);
                } else {
                  await _controller.stop();
                  setState(() => isPlayingSweep = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
