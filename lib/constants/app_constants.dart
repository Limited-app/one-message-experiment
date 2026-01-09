import 'package:flutter/material.dart';

// =============================================================================
// FOMO-INDUCING DESIGN SYSTEM
// =============================================================================

class AppColors {
  static const Color void_ = Color(0xFF000000);
  static const Color voidDeep = Color(0xFF050508);
  static const Color voidSurface = Color(0xFF0A0A0F);
  
  static const Color pulse = Color(0xFFFF2D55);
  static const Color pulseDim = Color(0xFF8B1E35);
  static const Color pulseGlow = Color(0x40FF2D55);
  
  static const Color sacred = Color(0xFFFFD700);
  static const Color sacredDim = Color(0xFFB8860B);
  static const Color sacredGlow = Color(0x40FFD700);
  
  static const Color frost = Color(0xFF1A1A24);
  static const Color frostBorder = Color(0xFF2A2A3A);
  static const Color frostLight = Color(0xFF3A3A4A);
  
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFF8A8A9A);
  static const Color textMuted = Color(0xFF4A4A5A);
  static const Color textWarning = Color(0xFFFF6B6B);
  
  static const Map<String, Color> categoryColors = {
    'Confess': Color(0xFFFF2D55),
    'Forgive': Color(0xFF34C759),
    'Remember': Color(0xFF5856D6),
    'Promise': Color(0xFFFFD700),
    'Regret': Color(0xFF8B0000),
    'Gratitude': Color(0xFFFF9500),
    'Fear': Color(0xFF1C1C1E),
    'Hope': Color(0xFF00D4FF),
    'Goodbye': Color(0xFF6B7280),
    'Love': Color(0xFFFF375F),
  };
  
  static const LinearGradient voidGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [voidDeep, void_, voidDeep],
  );
}

class AppTypography {
  static const String _fontFamily = 'SF Pro Display';
  
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 56,
    fontWeight: FontWeight.w200,
    letterSpacing: -2,
    height: 1.0,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w300,
    letterSpacing: -1,
    height: 1.1,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle counter = TextStyle(
    fontFamily: 'SF Mono',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    color: AppColors.sacred,
  );
  
  static const TextStyle counterLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 4,
    color: AppColors.textMuted,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle warning = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 2,
    color: AppColors.pulse,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.6,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 3,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 2,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 1,
    color: AppColors.textMuted,
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
  static const double huge = 96;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}

class AppShadows {
  static List<BoxShadow> glow(Color color, {double intensity = 0.5}) {
    return [
      BoxShadow(
        color: color.withOpacity(intensity * 0.6),
        blurRadius: 30,
        spreadRadius: 5,
      ),
      BoxShadow(
        color: color.withOpacity(intensity * 0.3),
        blurRadius: 60,
        spreadRadius: 10,
      ),
    ];
  }
  
  static List<BoxShadow> pulseGlow(double animValue) {
    return [
      BoxShadow(
        color: AppColors.pulse.withOpacity(0.3 + (animValue * 0.3)),
        blurRadius: 20 + (animValue * 20),
        spreadRadius: 2 + (animValue * 5),
      ),
    ];
  }
}

class AppAnimations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration dramatic = Duration(milliseconds: 1200);
  static const Duration ritual = Duration(milliseconds: 2000);
  
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve dramatic_ = Curves.easeInOutCubic;
}

class AppCategories {
  static const List<String> free = ['Confess', 'Remember', 'Gratitude', 'Hope', 'Forgive', 'Promise', 'Regret', 'Fear', 'Goodbye', 'Love'];
  static const List<String> premium = []; // All categories now free for viral growth
  static const List<String> all = [...free];
  
  static const Map<String, IconData> icons = {
    'Confess': Icons.privacy_tip_rounded,
    'Forgive': Icons.healing_rounded,
    'Remember': Icons.auto_awesome_rounded,
    'Promise': Icons.handshake_rounded,
    'Regret': Icons.heart_broken_rounded,
    'Gratitude': Icons.favorite_rounded,
    'Fear': Icons.visibility_off_rounded,
    'Hope': Icons.wb_sunny_rounded,
    'Goodbye': Icons.waving_hand_rounded,
    'Love': Icons.favorite_border_rounded,
  };
  
  static const Map<String, String> taglines = {
    'Confess': 'What have you never told anyone?',
    'Forgive': 'Who deserves your peace?',
    'Remember': 'What moment haunts you?',
    'Promise': 'What will you swear to?',
    'Regret': 'What would you undo?',
    'Gratitude': 'Who changed your life?',
    'Fear': 'What keeps you up at night?',
    'Hope': 'What are you still waiting for?',
    'Goodbye': 'Who never heard your farewell?',
    'Love': 'Who will never know?',
  };
}

class RewardLines {
  static const List<String> all = [
    'The weight you carried is now the ground beneath you.',
    'Some truths don\'t need witnesses to be real.',
    'You just did what most never will.',
    'Sealed. Permanent. Free.',
    'The hardest words are the ones we finally say.',
    'You trusted yourself with the truth.',
    'This moment is now eternal.',
    'Courage isn\'t loud. It\'s this.',
    'What\'s locked can finally rest.',
    'You chose to remember. Forever.',
  ];
}

class DailyPrompts {
  static const List<String> all = [
    'What truth are you still hiding from yourself?',
    'If today was your last day to speak, what would you seal?',
    'Who deserves words you\'ve never given them?',
    'What would set you free if you finally said it?',
    'What are you pretending doesn\'t hurt?',
  ];
}

class AppStrings {
  static const String appName = 'LIMITED';
  static const String tagline = 'One truth. One chance. Forever.';
  static const String shareMessage = 'I just locked my truth forever.\n\nYou only get one chance.\n\nLIMITED.';
  static const String inviteMessage = 'Some things can only be said once.';
  static const String warningOnce = 'YOU ONLY GET ONE CHANCE';
  static const String warningForever = 'THIS CANNOT BE UNDONE';
  static const String warningFinal = 'ONCE SEALED, LOCKED FOREVER';
  static const String warningLeave = 'Most people close this screen once before they\'re ready.';
}
