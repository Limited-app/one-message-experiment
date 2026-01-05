import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/firebase_service.dart';
import '../widgets/animated_background.dart';

class GlobalWallScreen extends StatefulWidget {
  const GlobalWallScreen({super.key});

  @override
  State<GlobalWallScreen> createState() => _GlobalWallScreenState();
}

class _GlobalWallScreenState extends State<GlobalWallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  List<SealedTruth> _truths = [];
  bool _isLoading = true;
  int _globalCount = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _loadTruths();
  }

  Future<void> _loadTruths() async {
    final truths = await FirebaseService.instance.getRecentTruths(limit: 50);
    final count = await FirebaseService.instance.getGlobalSealedCount();
    if (mounted) {
      setState(() {
        _truths = truths;
        _globalCount = count;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    : _truths.isEmpty
                        ? _buildEmpty()
                        : _buildList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GLOBAL WALL', style: AppTypography.headlineLarge.copyWith(letterSpacing: 4)),
                    Text('$_globalCount truths sealed worldwide', style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Info banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.frost.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.frostBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.public_rounded, color: AppColors.textMuted, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Anonymous truths from people around the world',
                    style: AppTypography.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: _truths.length,
      itemBuilder: (context, index) => _buildTruthCard(_truths[index], index),
    );
  }

  Widget _buildTruthCard(SealedTruth truth, int index) {
    final color = AppColors.categoryColors[truth.category] ?? AppColors.sacred;
    final timeAgo = truth.sealedAt != null ? _formatTime(truth.sealedAt!) : 'Recently';
    
    // Show only first part of message (teaser)
    final teaser = truth.message.length > 100 
        ? '${truth.message.substring(0, 100)}...' 
        : truth.message;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.frost.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(Icons.lock, color: color, size: 14),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                truth.category.toUpperCase(),
                style: AppTypography.labelMedium.copyWith(color: color),
              ),
              const Spacer(),
              Text(
                timeAgo,
                style: AppTypography.caption.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Message teaser
          Text(
            teaser,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Footer
          Row(
            children: [
              Icon(Icons.lock, color: color.withOpacity(0.4), size: 10),
              const SizedBox(width: 4),
              Text(
                'SEALED FOREVER',
                style: AppTypography.caption.copyWith(
                  color: color.withOpacity(0.5),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
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
            child: const Icon(Icons.public_off_rounded, color: AppColors.textMuted, size: 32),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('No truths yet', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Be the first to seal one.', style: AppTypography.bodyMedium),
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
    if (d.inMinutes > 0) return '${d.inMinutes}m ago';
    return 'Just now';
  }
}
