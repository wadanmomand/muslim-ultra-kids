import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob for Muslim Ultra Kids — Google Play Families Policy compliant.
///
/// Rules enforced here (locked 2026-10-12):
/// - ageRestrictedTreatment = YES (child-directed + under age of consent)
/// - maxAdContentRating = G (Families Self-Certified ads only)
/// - Banner on map/home screens + rewarded for bonus rewards ONLY
/// - NO interstitials inside the lesson flow, NO ads in parent dashboard
///
/// Real ad unit IDs are injected with --dart-define at release build time;
/// TEST ids are used otherwise (never ship test ids to production).
class KidsAds {
  static const String _bannerTestId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _rewardedTestId =
      'ca-app-pub-3940256099942544/5224354917';

  static String get bannerAdUnitId =>
      const String.fromEnvironment('ADMOB_BANNER_ID', defaultValue: _bannerTestId);
  static String get rewardedAdUnitId =>
      const String.fromEnvironment('ADMOB_REWARDED_ID', defaultValue: _rewardedTestId);

  static bool get usingTestIds =>
      bannerAdUnitId == _bannerTestId || rewardedAdUnitId == _rewardedTestId;

  /// Call once at app start, before loading any ad.
  static Future<void> initialize() async {
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.g,
        ageRestrictedTreatment: AgeRestrictedTreatment.child,
      ),
    );
    await MobileAds.instance.initialize();
  }

  /// Creates a banner ad sized for the map/home screen footer.
  static BannerAd createBanner({required void Function() onLoaded}) {
    return BannerAd(
      size: AdSize.banner,
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('KidsAds banner failed: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  /// Shows a rewarded ad for bonus rewards (e.g. bonus stars). Calls
  /// [onRewarded] only when the user actually earns the reward.
  static void showRewarded({required void Function() onRewarded}) {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (a) => a.dispose(),
            onAdFailedToShowFullScreenContent: (a, _) => a.dispose(),
          );
          ad.show(onUserEarnedReward: (_, _) => onRewarded());
        },
        onAdFailedToLoad: (error) =>
            debugPrint('KidsAds rewarded failed: $error'),
      ),
    );
  }
}
