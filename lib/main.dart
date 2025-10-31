import 'package:flutter/material.dart';
import 'audio_service.dart';

void main() {
  runApp(BioResonanzApp());
}

class BioResonanzApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bioresonanz App',
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioService _audioService = AudioService();

  // Single Tone
  double _frequency = 440;
  double _duration = 1.0;
  bool _loopTone = false;

  // Sweep
  double _sweepStart = 400;
  double _sweepEnd = 800;
  double _sweepDuration = 5.0;
  bool _loopSweep = false;

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _updateTone() {
    _audioService.playTone(_frequency, _duration, loop: _loopTone);
  }

  void _updateSweep() {
    _audioService.playSweep(_sweepStart, _sweepEnd, _sweepDuration, loop: _loopSweep);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bioresonanz App')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Einfacher Ton', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildSlider('Frequenz (Hz)', 20, 2000, _frequency, (v) {
              setState(() => _frequency = v);
              _updateTone();
            }),
            _buildSlider('Dauer (s)', 0.1, 10, _duration, (v) {
              setState(() => _duration = v);
              _updateTone();
            }),
            Row(
              children: [
                Checkbox(
                  value: _loopTone,
                  onChanged: (v) {
                    setState(() => _loopTone = v ?? false);
                    _updateTone();
                  },
                ),
                Text('Looping')
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _audioService.stop(),
              child: Text('Stop'),
            ),
            Divider(height: 40),
            Text('Sweep', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildSlider('Start-Frequenz (Hz)', 20, 2000, _sweepStart, (v) {
              setState(() => _sweepStart = v);
              _updateSweep();
            }),
            _buildSlider('End-Frequenz (Hz)', 20, 2000, _sweepEnd, (v) {
              setState(() => _sweepEnd = v);
              _updateSweep();
            }),
            _buildSlider('Dauer (s)', 0.1, 20, _sweepDuration, (v) {
              setState(() => _sweepDuration = v);
              _updateSweep();
            }),
            Row(
              children: [
                Checkbox(
                  value: _loopSweep,
                  onChanged: (v) {
                    setState(() => _loopSweep = v ?? false);
                    _updateSweep();
                  },
                ),
                Text('Looping')
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double min, double max, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}'),
        Slider(
          min: min,
          max: max,
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
