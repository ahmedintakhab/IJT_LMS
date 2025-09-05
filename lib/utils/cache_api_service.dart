import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/custom_cache_manager.dart'; // import custom manager

Future<dynamic> fetchDataWithCache(String url, {Map<String, String>? headers}) async {
  final fileInfo = await CustomCacheManager.instance.getFileFromCache(url);

  if (fileInfo != null && fileInfo.file != null) {
    final isExpired = fileInfo.validTill.isBefore(DateTime.now());

    if (!isExpired) {
      print('✅ Loaded from Cache');
      final cachedData = await fileInfo.file.readAsString();
      return jsonDecode(cachedData);
    } else {
      print('⚠️ Cache expired, fetching new data');
    }
  }

  // Either no cache or expired
  print('🌐 Fetching from API');
  final response = await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode == 200) {
    await CustomCacheManager.instance.putFile(
      url,
      response.bodyBytes,
      fileExtension: 'json',
    );
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load API data: ${response.statusCode}');
  }
}
