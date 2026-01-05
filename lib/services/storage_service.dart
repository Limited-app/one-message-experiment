import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service using SharedPreferences.
/// 
/// TODO: FIREBASE INTEGRATION
/// To swap to Firebase later:
/// 1. Create a DataRepository interface with the same methods
/// 2. Implement FirebaseStorageService that implements DataRepository
/// 3. Use dependency injection to swap implementations
/// 4. Add Firebase Auth for user identification
/// 5. Store messages in Firestore with user ID as document key
/// 
/// Example Firestore structure:
/// users/{userId}/messages/{category} -> { message, name, email, timestamp }
/// users/{userId}/settings -> { isPremium, ... }

abstract class DataRepository {
  Future<bool> isSubmitted(String category);
  Future<void> setSubmitted(String category, bool value);
  Future<void> saveMessage(String category, String message);
  Future<String?> getMessage(String category);
  Future<void> saveName(String category, String name);
  Future<String?> getName(String category);
  Future<void> saveReminderEmail(String category, String email);
  Future<String?> getReminderEmail(String category);
  Future<bool> isPremium();
  Future<void> setPremium(bool value);
  Future<bool> isOnboardingComplete();
  Future<void> setOnboardingComplete(bool value);
  Future<int> getStreak();
  Future<void> incrementStreak();
  Future<void> resetStreak();
  Future<DateTime?> getLastActiveDate();
  Future<void> setLastActiveDate(DateTime date);
  Future<int> getTotalMessagesLocked();
  Future<void> incrementTotalMessagesLocked();
  Future<DateTime?> getMessageTimestamp(String category);
  Future<void> setMessageTimestamp(String category, DateTime timestamp);
}

class StorageService implements DataRepository {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  SharedPreferences get _sp => _prefs!;

  @override
  Future<bool> isSubmitted(String category) async {
    return _sp.getBool('submitted_$category') ?? false;
  }

  @override
  Future<void> setSubmitted(String category, bool value) async {
    await _sp.setBool('submitted_$category', value);
  }

  @override
  Future<void> saveMessage(String category, String message) async {
    await _sp.setString('message_$category', message);
  }

  @override
  Future<String?> getMessage(String category) async {
    return _sp.getString('message_$category');
  }

  @override
  Future<void> saveName(String category, String name) async {
    await _sp.setString('name_$category', name);
  }

  @override
  Future<String?> getName(String category) async {
    return _sp.getString('name_$category');
  }

  @override
  Future<void> saveReminderEmail(String category, String email) async {
    await _sp.setString('reminder_$category', email);
  }

  @override
  Future<String?> getReminderEmail(String category) async {
    return _sp.getString('reminder_$category');
  }

  @override
  Future<bool> isPremium() async {
    return _sp.getBool('is_premium') ?? false;
  }

  @override
  Future<void> setPremium(bool value) async {
    await _sp.setBool('is_premium', value);
  }

  @override
  Future<bool> isOnboardingComplete() async {
    return _sp.getBool('onboarding_complete') ?? false;
  }

  @override
  Future<void> setOnboardingComplete(bool value) async {
    await _sp.setBool('onboarding_complete', value);
  }

  @override
  Future<int> getStreak() async {
    return _sp.getInt('streak') ?? 0;
  }

  @override
  Future<void> incrementStreak() async {
    final current = await getStreak();
    await _sp.setInt('streak', current + 1);
  }

  @override
  Future<void> resetStreak() async {
    await _sp.setInt('streak', 0);
  }

  @override
  Future<DateTime?> getLastActiveDate() async {
    final timestamp = _sp.getInt('last_active');
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  @override
  Future<void> setLastActiveDate(DateTime date) async {
    await _sp.setInt('last_active', date.millisecondsSinceEpoch);
  }

  @override
  Future<int> getTotalMessagesLocked() async {
    return _sp.getInt('total_messages') ?? 0;
  }

  @override
  Future<void> incrementTotalMessagesLocked() async {
    final current = await getTotalMessagesLocked();
    await _sp.setInt('total_messages', current + 1);
  }

  @override
  Future<DateTime?> getMessageTimestamp(String category) async {
    final timestamp = _sp.getInt('timestamp_$category');
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  @override
  Future<void> setMessageTimestamp(String category, DateTime timestamp) async {
    await _sp.setInt('timestamp_$category', timestamp.millisecondsSinceEpoch);
  }

  Future<bool> hasUsedSecondChance(String category) async {
    return _sp.getBool('second_chance_$category') ?? false;
  }

  Future<void> setUsedSecondChance(String category, bool value) async {
    await _sp.setBool('second_chance_$category', value);
  }

  Future<void> clearCategoryForSecondChance(String category) async {
    await _sp.remove('submitted_$category');
    await _sp.remove('message_$category');
    await _sp.remove('name_$category');
    await _sp.remove('timestamp_$category');
  }

  Future<void> saveFinalTruth(String message) async {
    await _sp.setString('final_truth', message);
    await _sp.setInt('final_truth_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Future<String?> getFinalTruth() async {
    return _sp.getString('final_truth');
  }

  Future<bool> isFinalTruthUsed() async {
    return _sp.getBool('final_truth_used') ?? false;
  }

  Future<void> setFinalTruthUsed(bool value) async {
    await _sp.setBool('final_truth_used', value);
  }

  Future<void> clearAllData() async {
    await _sp.clear();
  }

  Future<void> setReminderDate(DateTime date) async {
    await _sp.setInt('reminder_date', date.millisecondsSinceEpoch);
  }

  Future<DateTime?> getReminderDate() async {
    final timestamp = _sp.getInt('reminder_date');
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<bool> hasActiveReminder() async {
    final reminderDate = await getReminderDate();
    if (reminderDate == null) return false;
    return DateTime.now().isAfter(reminderDate);
  }
}
