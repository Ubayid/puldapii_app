import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html_unescape/html_unescape.dart';
import 'package:puldapii/models/article_model.dart';
import 'package:puldapii/pages/article/article_detail.dart';

String htmlToPlainText(String html) {
  final unescape = HtmlUnescape();
  final decoded = unescape.convert(html);
  final doc = html_parser.parse(decoded);
  final text = doc.body?.text ?? '';
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.compact = false,
  });

  final ArticleModel article;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final excerpt = htmlToPlainText(article.excerptHtml!);
    final title = htmlToPlainText(article.title);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap:
          onTap ??
          () {
            debugPrint('CARD KEPENCET: ${article.title}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArticleDetail(article: article),
              ),
            );
          },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: article.imageUrl.isEmpty
                  ? Image.asset(
                      "assets/images/dakwahImgDefault.png",
                      width: compact ? 80 : 90,
                      height: compact ? 80 : 90,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      article.imageUrl,
                      width: compact ? 80 : 90,
                      height: compact ? 80 : 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        "assets/images/dakwahImgDefault.png",
                        width: compact ? 80 : 90,
                        height: compact ? 80 : 90,
                        fit: BoxFit.cover,
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          width: compact ? 80 : 90,
                          height: compact ? 80 : 90,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.categoryName.isNotEmpty) ...[
                    Text(
                      "| ${article.categoryName}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 9 : 9.5,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(24, 100, 80, 1),
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    title.isEmpty ? '-' : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 12.5 : 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    excerpt.isEmpty ? '-' : excerpt,
                    maxLines: compact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 9.5 : 10,
                      height: 1.4,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
