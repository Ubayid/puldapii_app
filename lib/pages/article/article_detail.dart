import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:puldapii/models/article_model.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';

class ArticleDetail extends StatelessWidget {
  const ArticleDetail({super.key, required this.article});

  final ArticleModel article;

  String _parseHtmlToPlainText(String? htmlString) {
    if (htmlString == null || htmlString.trim().isEmpty) return '';

    final unescape = HtmlUnescape();
    final decoded = unescape.convert(htmlString);
    final doc = html_parser.parse(decoded);

    return (doc.body?.text ?? '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(article.date);

    final contentTitle = _parseHtmlToPlainText(article.title);
    final contentHtml = article.contentHtml ?? '';

    return Scaffold(
      body: Column(
        children: [
          SecondaryHeader(
            title: "Detail Artikel",
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
          Expanded(
            child: GradientPage(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          article.imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 200,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.broken_image_outlined,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 16),

                    Text(
                      contentTitle.isNotEmpty
                          ? contentTitle
                          : 'Konten artikel belum tersedia.',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (article.categoryName.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(24, 100, 80, 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              article.categoryName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(24, 100, 80, 1),
                              ),
                            ),
                          ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (contentHtml.trim().isNotEmpty)
                      Html(
                        data: contentHtml,
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            fontSize: FontSize(14),
                            lineHeight: LineHeight.number(1.7),
                            color: Colors.black87,
                          ),
                          "p": Style(
                            margin: Margins.only(bottom: 14),
                            lineHeight: LineHeight.number(1.7),
                          ),
                          "br": Style(margin: Margins.only(bottom: 8)),
                          "h1": Style(
                            margin: Margins.only(top: 18, bottom: 10),
                            fontSize: FontSize(24),
                            fontWeight: FontWeight.bold,
                            lineHeight: LineHeight.number(1.3),
                          ),
                          "h2": Style(
                            margin: Margins.only(top: 18, bottom: 10),
                            fontSize: FontSize(21),
                            fontWeight: FontWeight.bold,
                            lineHeight: LineHeight.number(1.3),
                          ),
                          "h3": Style(
                            margin: Margins.only(top: 16, bottom: 8),
                            fontSize: FontSize(18),
                            fontWeight: FontWeight.bold,
                            lineHeight: LineHeight.number(1.3),
                          ),
                          "ul": Style(
                            margin: Margins.only(bottom: 14),
                            padding: HtmlPaddings.only(left: 20),
                          ),
                          "ol": Style(
                            margin: Margins.only(bottom: 14),
                            padding: HtmlPaddings.only(left: 20),
                          ),
                          "li": Style(
                            margin: Margins.only(bottom: 6),
                            lineHeight: LineHeight.number(1.6),
                          ),
                          "img": Style(
                            margin: Margins.only(top: 12, bottom: 12),
                          ),
                        },
                      )
                    else
                      const Text(
                        '-',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
