part of 'poster_template_bloc.dart';

abstract class PosterTemplateState {}

class PosterTemplateInitial extends PosterTemplateState {}

class PosterTemplateLoading extends PosterTemplateState {}

class PosterTemplateLoaded extends PosterTemplateState {
  final List<PosterTemplateModel> templates;

  PosterTemplateLoaded(this.templates);
}

class PosterTemplateDetailLoaded extends PosterTemplateState {
  final PosterTemplateModel template;

  PosterTemplateDetailLoaded(this.template);
}

class PosterTemplateActionSuccess extends PosterTemplateState {
  final String message;
  final PosterTemplateModel? template;

  PosterTemplateActionSuccess({required this.message, this.template});
}

class PosterTemplateDeleteSuccess extends PosterTemplateState {
  final String message;

  PosterTemplateDeleteSuccess(this.message);
}

class PosterTemplateError extends PosterTemplateState {
  final String message;

  PosterTemplateError(this.message);
}

class PosterTemplateHomeLoaded extends PosterTemplateState {
  final List<PosterTemplateModel> templates;
  final List<PosterCategoryModel> categories;

  PosterTemplateHomeLoaded({required this.templates, required this.categories});
}
