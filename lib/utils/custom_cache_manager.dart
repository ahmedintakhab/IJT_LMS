import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  static CacheManager instance = CacheManager(
    Config(
      'customCacheKey',
      stalePeriod: const Duration(hours: 12), // cache duration
      maxNrOfCacheObjects: 100, // limit
    ),
  );
}
