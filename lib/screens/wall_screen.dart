import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../services/ads_service.dart';
import '../services/haptic_service.dart';
import '../widgets/animated_background.dart';

class WallScreen extends StatefulWidget {
  const WallScreen({super.key});

  @override
  State<WallScreen> createState() => _WallScreenState();
}

class _WallScreenState extends State<WallScreen> with SingleTickerProviderStateMixin {
  final Map<String, MessageData> _messages = {};
  bool _isLoading = true;
  BannerAd? _bannerAd;
  bool _isBannerReady = false;
  late AnimationController _pulseController;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _loadMessages();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    if (kIsWeb || !AdsService.instance.shouldShowAds) return;
    _bannerAd = AdsService.instance.createBannerAd(
      onAdLoaded: (ad) => setState(() => _isBannerReady = true),
      onAdFailedToLoad: (ad, error) => ad.dispose(),
    );
    _bannerAd?.load();
  }

  Future<void> _loadMessages() async {
    final storage = await StorageService.getInstance();
    for (final category in AppCategories.all) {
      if (await storage.isSubmitted(category)) {
        final message = await storage.getMessage(category);
        final timestamp = await storage.getMessageTimestamp(category);
        if (message != null) {
          _messages[category] = MessageData(message: message, timestamp: timestamp);
        }
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _share(String category, MessageData data) {
    HapticService.instance.mediumImpact();
    Share.share('"${data.message}"\n\nSealed forever in LIMITED.');
  }

  @override
  Widget build(BuildContext context) {
    final categories = _messages.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.void_,
      body: AnimatedBackground(
        showParticles: true,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.sacred, strokeWidth: 1))
                    : categories.isEmpty
                        ? _buildEmpty()
                        : _buildCards(categories),
              ),
              if (_isBannerReady && _bannerAd != null && !kIsWeb)
                SizedBox(height: 50, child: AdWidget(ad: _bannerAd!)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.frost,
                border: Border.all(color: AppColors.frostBorder),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textSecondary, size: 20),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('YOUR VAULT', style: AppTypography.headlineLarge.copyWith(letterSpacing: 4)),
              Text('${_messages.length} truths sealed', style: AppTypography.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCards(List<String> categories) {
    return PageView.builder(
      controller: _pageController,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final data = _messages[category]!;
        final color = AppColors.categoryColors[category] ?? AppColors.sacred;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.frost.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: color.withOpacity(0.4)),
            boxShadow: AppShadows.glow(color, intensity: 0.2),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.1),
                        border: Border.all(color: color.withOpacity(0.4)),
                      ),
                      child: Icon(Icons.lock, color: color, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.toUpperCase(), style: AppTypography.labelLarge.copyWith(color: color)),
                          if (data.timestamp != null)
                            Text(_formatTime(data.timestamp!), style: AppTypography.caption),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _share(category, data),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.frost,
                          border: Border.all(color: AppColors.frostBorder),
                        ),
                        child: Icon(Icons.share, color: color, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Message
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: SingleChildScrollView(
                    child: Text(
                      data.message,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary, height: 1.8),
                    ),
                  ),
                ),
              ),
              
              // Footer
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: color.withOpacity(0.4), size: 12),
                    const SizedBox(width: 4),
                    Text('SEALED FOREVER', style: AppTypography.caption.copyWith(color: color.withOpacity(0.6))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.frostBorder),
            ),
            child: const Icon(Icons.lock_open, color: AppColors.textMuted, size: 32),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('No truths sealed yet', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Your sealed messages appear here.', style: AppTypography.bodyMedium),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays > 365) return '${(d.inDays / 365).floor()}y ago';
    if (d.inDays > 30) return '${(d.inDays / 30).floor()}mo ago';
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    return 'Just now';
  }
}

class MessageData {
  final String message;
  final DateTime? timestamp;
  MessageData({required this.message, this.timestamp});
}
