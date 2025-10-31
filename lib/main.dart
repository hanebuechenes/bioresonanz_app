import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FrequencyGeneratorApp(),
  ));
}

class FrequencyGeneratorApp extends StatefulWidget {
  const FrequencyGeneratorApp({super.key});

  @override
  State<FrequencyGeneratorApp> createState() => _FrequencyGeneratorAppState();
}

class _FrequencyGeneratorAppState extends State<FrequencyGeneratorApp> {
  final playerLeft = AudioPlayer();
  final playerRight = AudioPlayer();
  bool isPlaying = false;

  double freqLeft = 440.0;
  double freqRight = 440.0;
  double volume = 0.5;

  double sweepStart = 100.0;
  double sweepEnd = 1000.0;
  double sweepDuration = 5.0;

  // Generiert 16-Bit PCM-Daten
  Uint8List generateTone(double freq, double seconds) {
    const sampleRate = 44100;
    final samples = (sampleRate * seconds).toInt();
    final buffer = BytesBuilder();

    for (int i = 0; i < samples; i++) {
      final sample = sin(2 * pi * freq * i / sampleRate);
      final intSample = (sample * 32767).toInt();
      buffer.addByte(intSample & 0xFF);
      buffer.addByte((intSample >> 8) & 0xFF);
    }
    return buffer.toBytes();
  }

  // PCM zu WAV konvertieren (Linux-kompatibel)
  Uint8List generateWav(Uint8List pcmData) {
    final header = BytesBuilder();
    final int dataLength = pcmData.length;
    final int fileSize = 36 + dataLength;

    header.add(utf8.encode('RIFF'));
    header.add(_intToBytesLE(fileSize, 4));
    header.add(utf8.encode('WAVE'));
    header.add(utf8.encode('fmt '));
    header.add(_intToBytesLE(16, 4)); // Subchunk1Size
    header.add(_intToBytesLE(1, 2));  // AudioFormat PCM
    header.add(_intToBytesLE(1, 2));  // Channels
    header.add(_intToBytesLE(44100, 4)); // SampleRate
    header.add(_intToBytesLE(44100 * 2, 4)); // ByteRate
    header.add(_intToBytesLE(2, 2)); // BlockAlign
    header.add(_intToBytesLE(16, 2)); // BitsPerSample
    header.add(utf8.encode('data'));
    header.add(_intToBytesLE(dataLength, 4));
    header.add(pcmData);

    return header.toBytes();
  }

  List<int> _intToBytesLE(int value, int byteCount) {
    final bytes = <int>[];
    for (int i = 0; i < byteCount; i++) {
      bytes.add((value >> (8 * i)) & 0xFF);
    }
    return bytes;
  }

  Future<void> playToneStereo(double freqL, double freqR) async {
    final toneL = generateWav(generateTone(freqL, 2.0));
    final toneR = generateWav(generateTone(freqR, 2.0));

    await playerLeft.play(BytesSource(toneL), volume: volume, mode: PlayerMode.lowLatency, balance: -1.0);
    await playerRight.play(BytesSource(toneR), volume: volume, mode: PlayerMode.lowLatency, balance: 1.0);
  }

  Future<void> playSweep(double startFreq, double endFreq, double durationSec) async {
    const sampleRate = 44100;
    final samples = (sampleRate * durationSec).toInt();
    final buffer = BytesBuilder();

    for (int i = 0; i < samples; i++) {
      final t = i / samples;
      final currentFreq = startFreq + (endFreq - startFreq) * t;
      final sample = sin(2 * pi * currentFreq * i / sampleRate);
      final intSample = (sample * 32767).toInt();
      buffer.addByte(intSample & 0xFF);
      buffer.addByte((intSample >> 8) & 0xFF);
    }

    final wavData = generateWav(buffer.toBytes());
    await playerLeft.play(BytesSource(wavData), volume: volume);
  }

  @override
  void dispose() {
    playerLeft.dispose();
    playerRight.dispose();
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
              onChanged: (v) => setState(() => volume = v),
              min: 0,
              max: 1,
            ),
            const SizedBox(height: 20),
            const Text("Linker Kanal", style: TextStyle(color: Colors.greenAccent)),
            Text("${freqLeft.toStringAsFixed(1)} Hz",
                style: const TextStyle(color: Colors.white)),
            Slider(
              value: freqLeft,
              onChanged: (v) => setState(() => freqLeft = v),
              min: 20,
              max: 20000,
            ),
            const SizedBox(height: 20),
            const Text("Rechter Kanal", style: TextStyle(color: Colors.greenAccent)),
            Text("${freqRight.toStringAsFixed(1)} Hz",
                style: const TextStyle(color: Colors.white)),
            Slider(
              value: freqRight,
              onChanged: (v) => setState(() => freqRight = v),
              min: 20,
              max: 20000,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlaying ? Colors.red : Colors.green,
              ),
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(isPlaying ? "Stop" : "Play Stereo"),
              onPressed: () async {
                if (!isPlaying) {
                  setState(() => isPlaying = true);
                  await playToneStereo(freqLeft, freqRight);
                  setState(() => isPlaying = false);
                } else {
                  await playerLeft.stop();
                  await playerRight.stop();
                  setState(() => isPlaying = false);
                }
              },
            ),
            const Divider(color: Colors.white, height: 40),
            const Text("Sweep Generator", style: TextStyle(color: Colors.greenAccent)),
            Text("Startfrequenz: ${sweepStart.toStringAsFixed(1)} Hz",
                style: const TextStyle(color: Colors.white)),
            Slider(
              value: sweepStart,
              onChanged: (v) => setState(() => sweepStart = v),
              min: 10,
              max: 10000,
            ),
            Text("Endfrequenz: ${sweepEnd.toStringAsFixed(1)} Hz",
                style: const TextStyle(color: Colors.white)),
            Slider(
              value: sweepEnd,
              onChanged: (v) => setState(() => sweepEnd = v),
              min: 10,
              max: 10000,
            ),
            Text("Dauer: ${sweepDuration.toStringAsFixed(1)} s",
                style: const TextStyle(color: Colors.white)),
            Slider(
              value: sweepDuration,
              onChanged: (v) => setState(() => sweepDuration = v),
              min: 1,
              max: 30,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.multitrack_audio),
              label: const Text("Sweep starten"),
              onPressed: () async {
                await playSweep(sweepStart, sweepEnd, sweepDuration);
              },
            ),
          ],
        ),
      ),
    );
  }
}
