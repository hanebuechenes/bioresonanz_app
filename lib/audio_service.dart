import 'dart:typed_data';
import 'dart:math';
import 'utils/wav_utils.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _playerLeft = AudioPlayer();
  final AudioPlayer _playerRight = AudioPlayer();

  double volume = 0.5;

  // Ton generieren
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

  // Stereo-Playback
  Future<void> playStereo(double freqL, double freqR, {double seconds = 2.0}) async {
    final toneL = generateWav(generateTone(freqL, seconds));
    final toneR = generateWav(generateTone(freqR, seconds));

    await _playerLeft.play(BytesSource(toneL), volume: volume, mode: PlayerMode.lowLatency, balance: -1.0);
    await _playerRight.play(BytesSource(toneR), volume: volume, mode: PlayerMode.lowLatency, balance: 1.0);
  }

  // Sweep-Generator
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
    await _playerLeft.play(BytesSource(wavData), volume: volume);
  }

  Future<void> stopAll() async {
    await _playerLeft.stop();
    await _playerRight.stop();
  }

  void dispose() {
    _playerLeft.dispose();
    _playerRight.dispose();
  }
}
