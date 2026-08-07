import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:puldapii/config/cubit/new_cubit/new_cubit.dart';
import 'package:puldapii/models/new_model.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';

class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage({super.key, required this.newsId});

  final int newsId;

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasFetched) {
      return;
    }

    _hasFetched = true;

    context.read<NewsCubit>().fetchNewsDetail(widget.newsId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SecondaryHeader(
            title: 'Detail Berita',
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),

          Expanded(
            child: GradientPage(
              child: BlocBuilder<NewsCubit, NewsState>(
                buildWhen: (previous, current) {
                  return previous.detailStatus != current.detailStatus ||
                      previous.selectedNews != current.selectedNews ||
                      previous.detailMessage != current.detailMessage;
                },
                builder: (context, state) {
                  if (state.detailStatus == NewsDetailStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.detailStatus == NewsDetailStatus.failure) {
                    return _buildError(context, state.detailMessage);
                  }

                  final news = state.selectedNews;

                  if (news == null) {
                    return _buildEmpty();
                  }

                  return _buildContent(news);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 12),
            Text(
              message ?? 'Gagal memuat detail berita.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<NewsCubit>().fetchNewsDetail(widget.newsId);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(child: Text('Detail berita tidak ditemukan.'));
  }

  Widget _buildContent(NewsModel news) {
    final date = news.createdAt ?? news.updatedAt;

    final formattedDate = date == null
        ? '-'
        : DateFormat('dd MMMM yyyy', 'id_ID').format(date.toLocal());

    final image = news.image?.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null && image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image,
                width: double.infinity,
                height: 210,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _imagePlaceholder();
                },
              ),
            )
          else
            _imagePlaceholder(),

          const SizedBox(height: 16),

          Text(
            news.title.isNotEmpty ? news.title : 'Judul berita',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.35,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (news.category.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(24, 100, 80, 0.09),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    news.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(24, 100, 80, 1),
                    ),
                  ),
                ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 15,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (news.description.trim().isNotEmpty)
            Html(
              data: news.description,
              style: {
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(14),
                  lineHeight: LineHeight.number(1.7),
                  color: Colors.black87,
                ),
                'p': Style(
                  margin: Margins.only(bottom: 14),
                  lineHeight: LineHeight.number(1.7),
                ),
                'br': Style(margin: Margins.only(bottom: 8)),
                'h1': Style(
                  margin: Margins.only(top: 18, bottom: 10),
                  fontSize: FontSize(24),
                  fontWeight: FontWeight.bold,
                  lineHeight: LineHeight.number(1.3),
                ),
                'h2': Style(
                  margin: Margins.only(top: 18, bottom: 10),
                  fontSize: FontSize(21),
                  fontWeight: FontWeight.bold,
                  lineHeight: LineHeight.number(1.3),
                ),
                'h3': Style(
                  margin: Margins.only(top: 16, bottom: 8),
                  fontSize: FontSize(18),
                  fontWeight: FontWeight.bold,
                  lineHeight: LineHeight.number(1.3),
                ),
                'ul': Style(
                  margin: Margins.only(bottom: 14),
                  padding: HtmlPaddings.only(left: 20),
                ),
                'ol': Style(
                  margin: Margins.only(bottom: 14),
                  padding: HtmlPaddings.only(left: 20),
                ),
                'li': Style(
                  margin: Margins.only(bottom: 6),
                  lineHeight: LineHeight.number(1.6),
                ),
                'img': Style(margin: Margins.only(top: 12, bottom: 12)),
              },
            )
          else
            const Text(
              'Deskripsi berita belum tersedia.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 210,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.broken_image_outlined,
        size: 42,
        color: Colors.grey,
      ),
    );
  }
}
