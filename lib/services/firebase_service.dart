import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseFirestore? _firestore;
  static bool _initialized = false;
  
  // Base count to start with (reasonable for new app)
  static const int _baseCount = 523;
  
  FirebaseService._();
  
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }
  
  bool get isInitialized => _initialized;
  
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firestore = FirebaseFirestore.instance;
      _initialized = true;
      
      // Ensure counter document exists
      await _ensureCounterExists();
    } catch (e) {
      debugPrint('Firebase init error: $e');
      // App continues to work offline with fallback count
    }
  }
  
  Future<void> _ensureCounterExists() async {
    if (_firestore == null) return;
    
    final counterDoc = _firestore!.collection('stats').doc('global');
    final snapshot = await counterDoc.get();
    
    if (!snapshot.exists) {
      await counterDoc.set({
        'sealedCount': _baseCount,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
  
  /// Get the global sealed count
  Future<int> getGlobalSealedCount() async {
    if (!_initialized || _firestore == null) {
      return _baseCount; // Fallback if offline
    }
    
    try {
      final doc = await _firestore!.collection('stats').doc('global').get();
      if (doc.exists) {
        return doc.data()?['sealedCount'] ?? _baseCount;
      }
      return _baseCount;
    } catch (e) {
      debugPrint('Error getting count: $e');
      return _baseCount;
    }
  }
  
  /// Increment the global counter and store the sealed message
  Future<void> sealTruth({
    required String category,
    required String message,
    String? deviceId,
  }) async {
    if (!_initialized || _firestore == null) return;
    
    try {
      final batch = _firestore!.batch();
      
      // Increment global counter
      final counterRef = _firestore!.collection('stats').doc('global');
      batch.update(counterRef, {
        'sealedCount': FieldValue.increment(1),
        'lastSealedAt': FieldValue.serverTimestamp(),
      });
      
      // Store the sealed message (anonymous)
      final messageRef = _firestore!.collection('sealed_truths').doc();
      batch.set(messageRef, {
        'category': category,
        'message': message,
        'sealedAt': FieldValue.serverTimestamp(),
        'deviceId': deviceId, // Optional, for user's own retrieval
      });
      
      await batch.commit();
    } catch (e) {
      debugPrint('Error sealing truth: $e');
    }
  }
  
  /// Get recent sealed truths (for potential "wall" feature)
  Future<List<SealedTruth>> getRecentTruths({int limit = 20}) async {
    if (!_initialized || _firestore == null) return [];
    
    try {
      final snapshot = await _firestore!
          .collection('sealed_truths')
          .orderBy('sealedAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SealedTruth(
          id: doc.id,
          category: data['category'] ?? '',
          message: data['message'] ?? '',
          sealedAt: (data['sealedAt'] as Timestamp?)?.toDate(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting truths: $e');
      return [];
    }
  }
}

class SealedTruth {
  final String id;
  final String category;
  final String message;
  final DateTime? sealedAt;
  
  SealedTruth({
    required this.id,
    required this.category,
    required this.message,
    this.sealedAt,
  });
}
