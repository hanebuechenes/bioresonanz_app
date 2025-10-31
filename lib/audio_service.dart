import 'dart:typed_data';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'wav_utils.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer(playerId: 'main');
  Uint8List? _currentBuffer;
  bool _loop = false;

  Future<void> playTone(double freq, double duration, {bool loop = false}) async {
    _loop = loop;
    final buffer = generateWav(generateTone(freq, duration));
    _currentBuffer = buffer;
    await _playBuffer();
  }

  Future<void> playSweep(double startFreq, double endFreq, double duration, {bool loop = false}) async {
    _loop = loop;
    final buffer = generateWav(generateSweep(startFreq, endFreq, duration));
    _currentBuffer = buffer;
    await _playBuffer();
  }

  Future<void> _playBuffer() async {
    if (_currentBuffer == null) return;

    // Temp-Datei schreiben
    final tempFile = await File('/tmp/bioresonanz.wav').writeAsBytes(_currentBuffer!);

    // Looping manuell, weil playBytes nicht mehr vorhanden
    do {
      await _player.play(DeviceFileSource(tempFile.path));
    } while (_loop);
  }

  Future<void> stop() async {
    _loop = false;
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
