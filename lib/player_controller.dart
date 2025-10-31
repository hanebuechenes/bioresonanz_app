import 'audio_service.dart';

class PlayerController {
  final AudioService _service = AudioService();

  double volume = 0.5;

  Future<void> playStereo(double left, double right) async {
    _service.volume = volume;
    await _service.playStereo(left, right);
  }

  Future<void> playSweep(double start, double end, double duration) async {
    _service.volume = volume;
    await _service.playSweep(start, end, duration);
  }

  Future<void> stop() async {
    await _service.stopAll();
  }

  void dispose() {
    _service.dispose();
  }
}
