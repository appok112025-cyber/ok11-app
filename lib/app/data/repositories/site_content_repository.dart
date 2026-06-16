import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/site_content.dart';
import 'package:ok11/app/services/api_service.dart';

class SiteContentRepository {
  final _apiService = Get.find<ApiService>();

  // In-memory cache to prevent loading spinners on subsequent page visits
  static AboutContent? _cachedAbout;
  static PointsContent? _cachedPoints;
  static TermsContent? _cachedTerms;
  static List<FAQItem>? _cachedFAQs;

  Future<AboutContent> getAboutContent() async {
    if (_cachedAbout != null) {
      debugPrint('💾 SiteContentRepository: Returning About content from cache');
      return _cachedAbout!;
    }
    debugPrint('📥 SiteContentRepository.getAboutContent()');
    try {
      final response = await _apiService.get('/site-content/about');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json != null) {
          final data = json['data'] as Map<String, dynamic>?;
          if (data != null) {
            _cachedAbout = AboutContent.fromJson(data);
            return _cachedAbout!;
          }
        }
        debugPrint('✅ SiteContentRepository.getAboutContent: Success');
        _cachedAbout = AboutContent(content: null, links: []);
        return _cachedAbout!;
      } else {
        debugPrint(
          '❌ SiteContentRepository.getAboutContent: Status ${response.statusCode}',
        );
        throw Exception('Failed to load about content');
      }
    } catch (e) {
      debugPrint('❌ SiteContentRepository.getAboutContent error: $e');
      throw Exception('Failed to load about content: $e');
    }
  }

  Future<PointsContent> getPointsContent() async {
    if (_cachedPoints != null) {
      debugPrint('💾 SiteContentRepository: Returning Points content from cache');
      return _cachedPoints!;
    }
    debugPrint('📥 SiteContentRepository.getPointsContent()');
    try {
      final response = await _apiService.get('/site-content/points');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json != null) {
          final data = json['data'] as Map<String, dynamic>?;
          if (data != null) {
            _cachedPoints = PointsContent.fromJson(data);
            return _cachedPoints!;
          }
        }
        debugPrint('✅ SiteContentRepository.getPointsContent: Success');
        _cachedPoints = PointsContent(content: null, items: []);
        return _cachedPoints!;
      } else {
        debugPrint(
          '❌ SiteContentRepository.getPointsContent: Status ${response.statusCode}',
        );
        throw Exception('Failed to load points content');
      }
    } catch (e) {
      debugPrint('❌ SiteContentRepository.getPointsContent error: $e');
      throw Exception('Failed to load points content: $e');
    }
  }

  Future<TermsContent> getTermsContent() async {
    if (_cachedTerms != null) {
      debugPrint('💾 SiteContentRepository: Returning Terms content from cache');
      return _cachedTerms!;
    }
    debugPrint('📥 SiteContentRepository.getTermsContent()');
    try {
      final response = await _apiService.get('/site-content/terms');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json != null) {
          final data = json['data'] as Map<String, dynamic>?;
          if (data != null) {
            _cachedTerms = TermsContent.fromJson(data);
            return _cachedTerms!;
          }
        }
        debugPrint('✅ SiteContentRepository.getTermsContent: Success');
        _cachedTerms = TermsContent(content: null, items: []);
        return _cachedTerms!;
      } else {
        debugPrint(
          '❌ SiteContentRepository.getTermsContent: Status ${response.statusCode}',
        );
        throw Exception('Failed to load terms content');
      }
    } catch (e) {
      debugPrint('❌ SiteContentRepository.getTermsContent error: $e');
      throw Exception('Failed to load terms content: $e');
    }
  }

  Future<List<FAQItem>> getFAQs() async {
    if (_cachedFAQs != null) {
      debugPrint('💾 SiteContentRepository: Returning FAQs from cache');
      return _cachedFAQs!;
    }
    debugPrint('📥 SiteContentRepository.getFAQs()');
    try {
      final response = await _apiService.get('/faqs');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json != null) {
          final data = json['data'] as List<dynamic>?;
          if (data != null) {
            final result = data
                .whereType<Map>()
                .map(
                  (item) => FAQItem.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList();
            debugPrint(
              '✅ SiteContentRepository.getFAQs: ${result.length} FAQs',
            );
            _cachedFAQs = result;
            return _cachedFAQs!;
          }
        }
        debugPrint('✅ SiteContentRepository.getFAQs: 0 FAQs (empty)');
        _cachedFAQs = [];
        return _cachedFAQs!;
      } else {
        debugPrint(
          '❌ SiteContentRepository.getFAQs: Status ${response.statusCode}',
        );
        throw Exception('Failed to load FAQs');
      }
    } catch (e) {
      debugPrint('❌ SiteContentRepository.getFAQs error: $e');
      throw Exception('Failed to load FAQs: $e');
    }
  }
}
