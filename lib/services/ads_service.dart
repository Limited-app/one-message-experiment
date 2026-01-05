import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static AdsService? _instance;
  
  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialReady = false;
  bool _adsDisabled = false;
  bool _firstRunComplete = false;

  AdsService._();

  static AdsService get instance {
    _instance ??= AdsService._();
    return _instance!;
  }

  static const String _bannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _bannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String _interstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _interstitialAdUnitIdIOS = 'ca-app-pub-3940256099942544/4411468910';

  String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _bannerAdUnitIdAndroid;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _bannerAdUnitIdIOS;
    }
    return _bannerAdUnitIdAndroid;
  }

  String get interstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _interstitialAdUnitIdAndroid;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _interstitialAdUnitIdIOS;
    }
    return _interstitialAdUnitIdAndroid;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    if (kIsWeb) {
      _isInitialized = true;
      _adsDisabled = true;
      return;
    }
    
    await MobileAds.instance.initialize();
    _isInitialized = true;
    
    _loadInterstitialAd();
  }

  void setAdsDisabled(bool disabled) {
    _adsDisabled = disabled;
  }

  bool get adsDisabled => _adsDisabled;

  void markFirstRunComplete() {
    _firstRunComplete = true;
  }

  bool get shouldShowAds => _firstRunComplete && !_adsDisabled && !kIsWeb;

  BannerAd? createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    if (kIsWeb) return null;
    
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  void _loadInterstitialAd() {
    if (_adsDisabled || kIsWeb) return;
    
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialReady = false;
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialReady = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialReady = false;
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (!shouldShowAds) return;
    
    if (_isInterstitialReady && _interstitialAd != null) {
      await _interstitialAd!.show();
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
