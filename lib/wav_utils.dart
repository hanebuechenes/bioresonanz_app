import 'dart:typed_data';
import 'dart:math';

/// WAV Header erzeugen
Uint8List generateWav(Uint8List samples, {int sampleRate = 44100}) {
  final byteRate = sampleRate * 2; // 16-bit mono
  final blockAlign = 2;
  final wavHeader = BytesBuilder();

  // "RIFF"
  wavHeader.add('RIFF'.codeUnits);
  wavHeader.add(_int32ToBytes(36 + samples.length));
  wavHeader.add('WAVE'.codeUnits);

  // "fmt "
  wavHeader.add('fmt '.codeUnits);
  wavHeader.add(_int32ToBytes(16)); // Subchunk1Size
  wavHeader.add(_int16ToBytes(1)); // PCM
  wavHeader.add(_int16ToBytes(1)); // Mono
  wavHeader.add(_int32ToBytes(sampleRate));
  wavHeader.add(_int32ToBytes(byteRate));
  wavHeader.add(_int16ToBytes(blockAlign));
  wavHeader.add(_int16ToBytes(16)); // Bits per sample

  // "data"
  wavHeader.add('data'.codeUnits);
  wavHeader.add(_int32ToBytes(samples.length));
  wavHeader.add(samples);

  return wavHeader.toBytes();
}

Uint8List _int16ToBytes(int value) =>
    Uint8List(2)..buffer.asByteData().setInt16(0, value, Endian.little);
Uint8List _int32ToBytes(int value) =>
    Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.little);

/// Ein einfacher Ton
Uint8List generateTone(double freq, double duration, {int sampleRate = 44100}) {
  final length = (sampleRate * duration).round();
  final buffer = Int16List(length);
  for (int i = 0; i < length; i++) {
    buffer[i] = (32767 * sin(2 * pi * freq * i / sampleRate)).toInt();
  }
  return Uint8List.view(buffer.buffer);
}

/// Ein Sweep von startFreq bis endFreq über [duration] Sekunden
Uint8List generateSweep(double startFreq, double endFreq, double duration, {int sampleRate = 44100}) {
  final length = (sampleRate * duration).round();
  final buffer = Int16List(length);

  for (int i = 0; i < length; i++) {
    final t = i / sampleRate;
    final freq = startFreq + (endFreq - startFreq) * (t / duration);
    buffer[i] = (32767 * sin(2 * pi * freq * t)).toInt();
  }

  return Uint8List.view(buffer.buffer);
}
