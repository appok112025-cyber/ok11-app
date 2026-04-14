class HtmlUtils {
  static String stripHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return '';

    RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    String plainText = htmlString.replaceAll(exp, '');

    plainText = plainText
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");

    return plainText.trim();
  }

  static String? stripHtmlTagsNullable(String? htmlString) {
    if (htmlString == null || htmlString.isEmpty) return null;
    return stripHtmlTags(htmlString);
  }
}
