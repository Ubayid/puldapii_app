import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/models/poster_template_model.dart';
import 'package:puldapii/utils/services/home/poster_template_service.dart';

part 'poster_template_event.dart';
part 'poster_template_state.dart';

class PosterTemplateBloc
    extends Bloc<PosterTemplateEvent, PosterTemplateState> {
  final PosterTemplateService posterTemplateService;

  PosterTemplateBloc(this.posterTemplateService)
    : super(PosterTemplateInitial()) {
    on<FetchPosterTemplateHomeData>(_onFetchPosterTemplateHomeData);
    on<FetchPosterTemplates>(_onFetchPosterTemplates);
    on<FetchPosterTemplateDetail>(_onFetchPosterTemplateDetail);
    on<CreatePosterTemplate>(_onCreatePosterTemplate);
    on<UpdatePosterTemplate>(_onUpdatePosterTemplate);
    on<DeletePosterTemplate>(_onDeletePosterTemplate);
  }

  Future<void> _onFetchPosterTemplateHomeData(
    FetchPosterTemplateHomeData event,
    Emitter<PosterTemplateState> emit,
  ) async {
    emit(PosterTemplateLoading());

    try {
      final templates = await posterTemplateService.fetchPosterTemplates(
        perPage: 10,
      );

      final categories = await posterTemplateService.fetchPosterCategories();

      emit(
        PosterTemplateHomeLoaded(templates: templates, categories: categories),
      );
    } catch (e) {
      emit(PosterTemplateError(_cleanError(e)));
    }
  }

  Future<void> _onFetchPosterTemplates(
    FetchPosterTemplates event,
    Emitter<PosterTemplateState> emit,
  ) async {
    emit(PosterTemplateLoading());

    try {
      final templates = await posterTemplateService.fetchPosterTemplates(
        search: event.search,
        posterCategoryId: event.posterCategoryId,
        perPage: event.perPage,
        page: event.page,
      );

      emit(PosterTemplateLoaded(templates));
    } catch (e) {
      emit(PosterTemplateError(_cleanError(e)));
    }
  }

  Future<void> _onFetchPosterTemplateDetail(
    FetchPosterTemplateDetail event,
    Emitter<PosterTemplateState> emit,
  ) async {
    emit(PosterTemplateLoading());

    try {
      final template = await posterTemplateService.fetchPosterTemplateDetail(
        event.id,
      );

      emit(PosterTemplateDetailLoaded(template));
    } catch (e) {
      emit(PosterTemplateError(_cleanError(e)));
    }
  }

  Future<void> _onCreatePosterTemplate(
    CreatePosterTemplate event,
    Emitter<PosterTemplateState> emit,
  ) async {
    emit(PosterTemplateLoading());

    try {
      final template = await posterTemplateService.createPosterTemplate(
        token: event.token,
        title: event.title,
        image: event.image,
        categoryIds: event.categoryIds,
        status: event.status,
      );

      emit(
        PosterTemplateActionSuccess(
          message: 'Template poster berhasil ditambahkan',
          template: template,
        ),
      );
    } catch (e) {
      emit(PosterTemplateError(_cleanError(e)));
    }
  }

  Future<void> _onUpdatePosterTemplate(
    UpdatePosterTemplate event,
    Emitter<PosterTemplateState> emit,
  ) async {
    emit(PosterTemplateLoading());

    try {
      final template = await posterTemplateService.updatePosterTemplate(
        token: event.token,
        id: event.id,
        title: event.title,
        image: event.image,
        categoryIds: event.categoryIds,
        status: event.status,
      );

      emit(
        PosterTemplateActionSuccess(
          message: 'Template poster berhasil diperbarui',
          template: template,
        ),
      );
    } catch (e) {
      emit(PosterTemplateError(_cleanError(e)));
    }
  }

  Future<void> _onDeletePosterTemplate(
    DeletePosterTemplate event,
    Emitter<PosterTemplateState> emit,
  ) async {
    emit(PosterTemplateLoading());

    try {
      await posterTemplateService.deletePosterTemplate(
        token: event.token,
        id: event.id,
      );

      emit(PosterTemplateDeleteSuccess('Template poster berhasil dihapus'));
    } catch (e) {
      emit(PosterTemplateError(_cleanError(e)));
    }
  }

  String _cleanError(Object e) {
    return e
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiFailure: ', '')
        .trim();
  }
}
