import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../services/haptic_service.dart';
import '../widgets/animated_background.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  final Map<String, bool> _sealedCategories = {};
  bool _isLoading = true;
  int _sealedCount = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    )..forward();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _loadSealedStatus();
  }

  Future<void> _loadSealedStatus() async {
    final storage = await StorageService.getInstance();
    int count = 0;
    for (final category in AppCategories.all) {
      final isSealed = await storage.isSubmitted(category);
      _sealedCategories[category] = isSealed;
      if (isSealed) count++;
    }
    setState(() {
      _sealedCount = count;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectCategory(String category) {
    if (_sealedCategories[category] == true) {
      HapticService.instance.heavyImpact();
      _showSealedDialog(category);
      return;
    }
    
    HapticService.instance.lightImpact();
    Navigator.pushNamed(context, '/write', arguments: category);
  }

  void _showSealedDialog(String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.voidSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.pulse, width: 1),
        ),
        title: Row(
          children: [
            const Icon(Icons.lock, color: AppColors.pulse, size: 24),
            const SizedBox(width: 12),
            Text(
              'SEALED FOREVER',
              style: AppTypography.headlineSmall.copyWith(color: AppColors.pulse),
            ),
          ],
        ),
        content: Text(
          'You already sealed your $category truth.\n\nThere are no second chances.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'I UNDERSTAND',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: AnimatedBackground(
        showParticles: true,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              children: [
                _buildHeader(),
                _buildWarningBanner(),
                Expanded(child: _buildCategoryGrid()),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHOOSE YOUR TRUTH',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '$_sealedCount of ${AppCategories.all.length} sealed',
                style: AppTypography.caption.copyWith(
                  color: _sealedCount > 0 ? AppColors.sacred : AppColors.textMuted,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/global'),
                icon: const Icon(Icons.public_rounded),
                color: AppColors.textSecondary,
                tooltip: 'Global Wall',
              ),
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/wall'),
                icon: const Icon(Icons.grid_view_rounded),
                color: AppColors.textSecondary,
              ),
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/about'),
                icon: const Icon(Icons.info_outline_rounded),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.pulse.withOpacity(0.05 + (_pulseController.value * 0.05)),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: AppColors.pulse.withOpacity(0.2 + (_pulseController.value * 0.2)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.pulse.withOpacity(0.6 + (_pulseController.value * 0.4)),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'ONE CHANCE PER CATEGORY • NO EDITS • NO DELETES',
                style: AppTypography.caption.copyWith(
                  color: AppColors.pulse.withOpacity(0.6 + (_pulseController.value * 0.4)),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryGrid() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.sacred, strokeWidth: 1),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.4,
      ),
      itemCount: AppCategories.all.length,
      itemBuilder: (context, index) {
        final category = AppCategories.all[index];
        return _buildCategoryCard(category, index);
      },
    );
  }

  Widget _buildCategoryCard(String category, int index) {
    final isSealed = _sealedCategories[category] ?? false;
    final color = AppColors.categoryColors[category] ?? AppColors.sacred;
    final icon = AppCategories.icons[category] ?? Icons.lock;
    final tagline = AppCategories.taglines[category] ?? '';

    return GestureDetector(
      onTap: () => _selectCategory(category),
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        decoration: BoxDecoration(
          color: isSealed 
              ? AppColors.voidDeep 
              : AppColors.frost.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSealed 
                ? color.withOpacity(0.5) 
                : color.withOpacity(0.3),
            width: isSealed ? 2 : 1,
          ),
          boxShadow: isSealed 
              ? AppShadows.glow(color, intensity: 0.3) 
              : null,
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm + 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSealed 
                          ? color.withOpacity(0.2) 
                          : AppColors.voidSurface,
                      border: Border.all(
                        color: isSealed ? color : AppColors.frostBorder,
                      ),
                    ),
                    child: Icon(
                      isSealed ? Icons.lock : icon,
                      color: isSealed ? color : AppColors.textSecondary,
                      size: 14,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Category name
                  Text(
                    category.toUpperCase(),
                    style: AppTypography.labelMedium.copyWith(
                      color: isSealed ? color : AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                  
                  // Tagline or sealed status
                  Text(
                    isSealed ? 'SEALED' : tagline,
                    style: AppTypography.caption.copyWith(
                      color: isSealed ? color.withOpacity(0.7) : AppColors.textMuted,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Sealed glow overlay
            if (isSealed)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1,
                      colors: [
                        color.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/why'),
        child: Text(
          'WHY LIMITED?',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
