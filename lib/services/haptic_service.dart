import 'package:flutter/services.dart';

class HapticService {
  static HapticService? _instance;
  
  HapticService._();
  
  static HapticService get instance {
    _instance ??= HapticService._();
    return _instance!;
  }

  Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  Future<void> lockSequence() async {
    await heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await lightImpact();
  }

  Future<void> successSequence() async {
    await lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await mediumImpact();
  }

  Future<void> buttonTap() async {
    await selectionClick();
  }
}
