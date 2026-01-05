import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static AudioService? _instance;
  final AudioPlayer _player = AudioPlayer();

  AudioService._();

  static AudioService get instance {
    _instance ??= AudioService._();
    return _instance!;
  }

  Future<void> playWhisper() async {
    try {
      await _player.play(AssetSource('audio/whisper.mp3'));
    } catch (e) {
      // Audio might not be available, fail silently
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
