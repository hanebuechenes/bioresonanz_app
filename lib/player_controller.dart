import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class PlayerController {
  final AudioPlayer _player = AudioPlayer();

  // Looping
  bool loopStereo = false;
  bool loopSweep = false;

  // --- Stereo ---
  Future<void> playStereo(double freqL, double freqR, {double duration = 2.0}) async {
    final wavData = _generateStereoWav(freqL, freqR, duration);
    await _player.play(BytesSource(wavData));
  }

  // --- Sweep ---
  Future<void> playSweep(double startFreq, double endFreq, double duration) async {
    final wavData = _generateSweepWav(startFreq, endFreq, duration);
    await _player.play(BytesSource(wavData));
  }

  Future<void> stop() async {
    await _player.stop();
  }

  // --- WAV-Erzeugung ---
  Uint8List _generateStereoWav(double freqL, double freqR, double duration) {
    final sampleRate = 44100;
    final numSamples = (duration * sampleRate).toInt();
    final buffer = Float32List(numSamples * 2);

    for (int i = 0; i < numSamples; i++) {
      buffer[i * 2] = sin(2 * pi * freqL * i / sampleRate);
      buffer[i * 2 + 1] = sin(2 * pi * freqR * i / sampleRate);
    }
    return _float32ToWav(buffer, sampleRate);
  }

  Uint8List _generateSweepWav(double startFreq, double endFreq, double duration) {
    final sampleRate = 44100;
    final numSamples = (duration * sampleRate).toInt();
    final buffer = Float32List(numSamples);

    for (int i = 0; i < numSamples; i++) {
      double t = i / sampleRate;
      double freq = startFreq + (endFreq - startFreq) * t / duration;
      buffer[i] = sin(2 * pi * freq * t);
    }
    return _float32ToWav(buffer, sampleRate);
  }

  Uint8List _float32ToWav(Float32List samples, int sampleRate) {
    final byteData = ByteData(44 + samples.length * 2);
    int offset = 0;

    void writeString(String s) {
      for (var c in s.codeUnits) byteData.setUint8(offset++, c);
    }

    void writeUint32(int v) {
      byteData.setUint32(offset, v, Endian.little);
      offset += 4;
    }

    void writeUint16(int v) {
      byteData.setUint16(offset, v, Endian.little);
      offset += 2;
    }

    writeString('RIFF');
    writeUint32(36 + samples.length * 2);
    writeString('WAVE');
    writeString('fmt ');
    writeUint32(16);
    writeUint16(1); // PCM
    writeUint16(2); // stereo
    writeUint32(sampleRate);
    writeUint32(sampleRate * 2 * 2);
    writeUint16(4);
    writeUint16(16);
    writeString('data');
    writeUint32(samples.length * 2);

    for (var s in samples) {
      int val = (s * 32767).clamp(-32768, 32767).toInt();
      byteData.setInt16(offset, val, Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }
}
