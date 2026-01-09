import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../widgets/animated_background.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _totalLocked = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _loadStats();
  }

  Future<void> _loadStats() async {
    final storage = await StorageService.getInstance();
    _totalLocked = await storage.getTotalMessagesLocked();
    if (mounted) setState(() {});
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
        showAura: true,
        auraColor: AppColors.sacred,
        auraIntensity: 0.2,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                // Header
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
                    const Spacer(),
                    Text('ABOUT', style: AppTypography.labelMedium.copyWith(color: AppColors.textMuted)),
                    const SizedBox(width: 44),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Icon
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.sacred, width: 2),
                        boxShadow: AppShadows.glow(AppColors.sacred, intensity: 0.3 + (_pulseController.value * 0.2)),
                      ),
                      child: const Icon(Icons.lock_rounded, color: AppColors.sacred, size: 40),
                    );
                  },
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                Text('LIMITED', style: AppTypography.displayMedium.copyWith(letterSpacing: 8)),
                const SizedBox(height: AppSpacing.sm),
                Text('One truth. Sealed forever.', style: AppTypography.bodyMedium.copyWith(fontStyle: FontStyle.italic)),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Features
                _buildFeature(Icons.looks_one_rounded, 'ONE CHANCE', 'Each category can only be written once'),
                _buildFeature(Icons.lock_rounded, 'SEALED FOREVER', 'No edits. No deletes. Permanent.'),
                _buildFeature(Icons.all_inclusive_rounded, '10 CATEGORIES', 'Confess, Forgive, Remember, Love, and more'),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Stats
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.frost.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.frostBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('$_totalLocked', 'SEALED'),
                      Container(width: 1, height: 40, color: AppColors.frostBorder),
                      _buildStat('${AppCategories.all.length}', 'TOTAL'),
                      Container(width: 1, height: 40, color: AppColors.frostBorder),
                      _buildStat('∞', 'FOREVER'),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Share button
                GestureDetector(
                  onTap: () => Share.share(AppStrings.inviteMessage),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
                        decoration: BoxDecoration(
                          color: AppColors.sacred.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: AppColors.sacred, width: 2),
                          boxShadow: AppShadows.glow(AppColors.sacred, intensity: 0.2 + (_pulseController.value * 0.1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.share_rounded, color: AppColors.sacred, size: 20),
                            const SizedBox(width: 8),
                            Text('SHARE LIMITED', style: AppTypography.labelLarge.copyWith(color: AppColors.sacred, letterSpacing: 3)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                Text('Help others find their truth', style: AppTypography.caption),
                
                const SizedBox(height: AppSpacing.huge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.frost,
              border: Border.all(color: AppColors.frostBorder),
            ),
            child: Icon(icon, color: AppColors.sacred, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headlineSmall),
                Text(desc, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTypography.headlineLarge.copyWith(color: AppColors.sacred)),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
