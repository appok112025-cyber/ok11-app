import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/site_content.dart';
import 'package:ok11/app/services/api_service.dart';

class SiteContentRepository {
  final _apiService = Get.find<ApiService>();

  Future<AboutContent> getAboutContent() async {
    debugPrint('📥 SiteContentRepository.getAboutContent()');
    try {
      final response = await _apiService.get('/site-content/about');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json != null) {
          final data = json['data'] as Map<String, dynamic>?;
          if (data != null) {
            return AboutContent.fromJson(data);
          }
        }
        debugPrint('✅ SiteContentRepository.getAboutContent: Success');
        return AboutContent(content: null, links: []);
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
    debugPrint('📥 SiteContentRepository.getPointsContent()');
    try {
      final response = await _apiService.get('/site-content/points');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json != null) {
          final data = json['data'] as Map<String, dynamic>?;
          if (data != null) {
            return PointsContent.fromJson(data);
          }
        }
        debugPrint('✅ SiteContentRepository.getPointsContent: Success');
        return PointsContent(content: null, items: []);
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
    debugPrint('📥 SiteContentRepository.getTermsContent()');
    try {
      final response = await _apiService.get('/site-content/terms');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final json = decoded is Map ? Map<String, dynamic>.from(decoded) : null;
        if (json != null) {
          final data = json['data'] as Map<String, dynamic>?;
          if (data != null) {
            return TermsContent.fromJson(data);
          }
        }
        debugPrint('✅ SiteContentRepository.getTermsContent: Success');
        return TermsContent(content: null, items: []);
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
            return result;
          }
        }
        debugPrint('✅ SiteContentRepository.getFAQs: 0 FAQs (empty)');
        return [];
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
