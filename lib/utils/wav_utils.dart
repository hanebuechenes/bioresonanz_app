import 'dart:typed_data';
import 'dart:convert';

// Wandelt PCM -> WAV (Linux/Android/iOS kompatibel)
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
