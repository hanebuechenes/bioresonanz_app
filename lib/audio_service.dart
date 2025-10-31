import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  /// Spielt eine Audiodatei aus den Assets ab
  static Future<void> playTone(String assetPath) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      print('Audio playback error: $e');
    }
  }

  /// Stoppt die Wiedergabe
  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      print('Stop error: $e');
    }
  }

  /// Gibt Ressourcen frei
  static Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (e) {
      print('Dispose error: $e');
    }
  }
}
