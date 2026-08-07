import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:puldapii/models/hadist_model.dart';
import 'package:puldapii/utils/services/home/hadist_service.dart';

part 'hadist_detail_event.dart';
part 'hadist_detail_state.dart';

class HadistDetailBloc extends Bloc<HadistDetailEvent, HadistDetailState> {
  final HadistService service;

  HadistDetailBloc(this.service) : super(HadistDetailInitial()) {
    on<FetchHadistDetail>(_onFetchHadistDetail);
  }

  Future<void> _onFetchHadistDetail(
    FetchHadistDetail event,
    Emitter<HadistDetailState> emit,
  ) async {
    emit(HadistDetailLoading());

    try {
      final hadist = await service.getHadistDetail(
        book: event.book,
        id: event.id,
      );

      emit(HadistDetailLoaded(book: event.book, hadist: hadist));
    } catch (e) {
      emit(HadistDetailError(_cleanError(e)));
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
