class SocialLink {
  final String title;
  final String url;

  SocialLink({required this.title, required this.url});

  factory SocialLink.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return SocialLink(title: '', url: '');
    }
    return SocialLink(
      title: (json['title'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
    );
  }
}

class PointItem {
  final String title;
  final String description;

  PointItem({required this.title, required this.description});

  factory PointItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PointItem(title: '', description: '');
    }
    return PointItem(
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
    );
  }
}

class TermItem {
  final String title;
  final String description;

  TermItem({required this.title, required this.description});

  factory TermItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return TermItem(title: '', description: '');
    }
    return TermItem(
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final int? order;

  FAQItem({required this.question, required this.answer, this.order});

  factory FAQItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return FAQItem(question: '', answer: '');
    }
    return FAQItem(
      question: (json['question'] as String?) ?? '',
      answer: (json['answer'] as String?) ?? '',
      order: json['order'] as int?,
    );
  }
}

class AboutContent {
  final String? content;
  final List<SocialLink> links;

  AboutContent({this.content, required this.links});

  factory AboutContent.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AboutContent(content: null, links: []);
    }
    return AboutContent(
      content: json['content'] as String?,
      links:
          (json['links'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (link) => SocialLink.fromJson(Map<String, dynamic>.from(link)),
              )
              .toList() ??
          [],
    );
  }
}

class PointsContent {
  final String? content;
  final List<PointItem> items;

  PointsContent({this.content, required this.items});

  factory PointsContent.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PointsContent(content: null, items: []);
    }
    return PointsContent(
      content: json['content'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (item) => PointItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList() ??
          [],
    );
  }
}

class TermsContent {
  final String? content;
  final List<TermItem> items;

  TermsContent({this.content, required this.items});

  factory TermsContent.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return TermsContent(content: null, items: []);
    }
    return TermsContent(
      content: json['content'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((item) => TermItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
    );
  }
}
