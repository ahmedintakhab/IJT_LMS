import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/api_constant.dart';

class LocationDataService {
  Future<List<Map<String, dynamic>>> fetchCountries(SharedPreferences prefs) async {
    const cacheKey = 'cached_countries';
    final cachedData = prefs.getString(cacheKey);

    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(json.decode(cachedData));
    }

    try {
      final response = await http.get(Uri.parse('${ApiConstant.baseUrl}countries'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final countries = List<Map<String, dynamic>>.from(data['data']);
          await prefs.setString(cacheKey, json.encode(countries));
          return countries;
        }
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> fetchProvinces(String countryId, SharedPreferences prefs) async {
    final cacheKey = 'cached_provinces_$countryId';
    final cachedData = prefs.getString(cacheKey);

    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(json.decode(cachedData));
    }

    try {
      final response = await http.get(Uri.parse('${ApiConstant.baseUrl}provinces/$countryId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final provinces = List<Map<String, dynamic>>.from(data['data']);
          await prefs.setString(cacheKey, json.encode(provinces));
          return provinces;
        }
      }
    } catch (e) {
      print('Error fetching provinces: $e');
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> fetchDistricts(String provinceId, SharedPreferences prefs) async {
    final cacheKey = 'cached_districts_$provinceId';
    final cachedData = prefs.getString(cacheKey);

    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(json.decode(cachedData));
    }

    try {
      final response = await http.get(Uri.parse('${ApiConstant.baseUrl}districts/$provinceId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final districts = List<Map<String, dynamic>>.from(data['data']);
          await prefs.setString(cacheKey, json.encode(districts));
          return districts;
        }
      }
    } catch (e) {
      print('Error fetching districts: $e');
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> fetchCities(String districtId, SharedPreferences prefs) async {
    final cacheKey = 'cached_cities_$districtId';
    final cachedData = prefs.getString(cacheKey);

    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(json.decode(cachedData));
    }

    try {
      final response = await http.get(Uri.parse('${ApiConstant.baseUrl}cities/$districtId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final cities = List<Map<String, dynamic>>.from(data['data']);
          await prefs.setString(cacheKey, json.encode(cities));
          return cities;
        }
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> fetchMuqams(String provinceId, SharedPreferences prefs) async {
    final cacheKey = 'cached_muqams_$provinceId';
    final cachedData = prefs.getString(cacheKey);

    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(json.decode(cachedData));
    }

    try {
      final response = await http.get(Uri.parse('${ApiConstant.baseUrl}muqams_by_province/$provinceId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final muqams = List<Map<String, dynamic>>.from(data['data']);
          await prefs.setString(cacheKey, json.encode(muqams));
          return muqams;
        }
      }
    } catch (e) {
      print('Error fetching muqams: $e');
    }

    return [];
  }

  // New method to pre-load all data
  Future<void> preloadAllData(SharedPreferences prefs) async {
    // Fetch and cache countries
    final countriesList = await fetchCountries(prefs);

    // Fetch and cache provinces for each country
    for (var country in countriesList) {
      final countryId = country['id'].toString();
      await fetchProvinces(countryId, prefs);
    }

    // Optionally, fetch districts, cities, and muqams for all provinces and districts
    // This might be too resource-intensive, so we'll fetch them on-demand in onChanged
  }
}