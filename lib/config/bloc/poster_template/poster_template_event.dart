part of 'poster_template_bloc.dart';

abstract class PosterTemplateEvent {}

class FetchPosterTemplates extends PosterTemplateEvent {
  final String? search;
  final int? posterCategoryId;
  final String? type;
  final int perPage;
  final int page;

  FetchPosterTemplates({
    this.search,
    this.posterCategoryId,
    this.type,
    this.perPage = 10,
    this.page = 1,
  });
}

class FetchPosterTemplateBanners extends PosterTemplateEvent {}

class FetchPosterTemplateFeatured extends PosterTemplateEvent {}

class FetchPosterTemplateDetail extends PosterTemplateEvent {
  final int id;

  FetchPosterTemplateDetail(this.id);
}

class CreatePosterTemplate extends PosterTemplateEvent {
  final String token;
  final String title;
  final File image;
  final List<int> categoryIds;
  final bool isBanner;
  final int bannerOrder;
  final bool isFeatured;
  final String status;

  CreatePosterTemplate({
    required this.token,
    required this.title,
    required this.image,
    this.categoryIds = const [],
    this.isBanner = false,
    this.bannerOrder = 0,
    this.isFeatured = false,
    this.status = 'published',
  });
}

class UpdatePosterTemplate extends PosterTemplateEvent {
  final String token;
  final int id;
  final String title;
  final File? image;
  final List<int> categoryIds;
  final bool isBanner;
  final int bannerOrder;
  final bool isFeatured;
  final String status;

  UpdatePosterTemplate({
    required this.token,
    required this.id,
    required this.title,
    this.image,
    this.categoryIds = const [],
    this.isBanner = false,
    this.bannerOrder = 0,
    this.isFeatured = false,
    this.status = 'published',
  });
}

class DeletePosterTemplate extends PosterTemplateEvent {
  final String token;
  final int id;

  DeletePosterTemplate({required this.token, required this.id});
}

class FetchPosterTemplateHomeData extends PosterTemplateEvent {}
