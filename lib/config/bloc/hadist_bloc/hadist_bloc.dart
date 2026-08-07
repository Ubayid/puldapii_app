import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:puldapii/models/hadist_model.dart';
import 'package:puldapii/models/paginated.dart';
import 'package:puldapii/utils/services/home/hadist_service.dart';

part 'hadist_event.dart';
part 'hadist_state.dart';

class HadistBloc extends Bloc<HadistEvent, HadistState> {
  final HadistService service;

  HadistBloc(this.service) : super(HadistInitial()) {
    on<FetchHadistBooks>(_onFetchHadistBooks);
    on<FetchHadistList>(_onFetchHadistList);
    on<ChangeHadistBook>(_onChangeHadistBook);
    on<UpdateHadistSearch>(_onUpdateHadistSearch);
    on<ChangeHadistPage>(_onChangeHadistPage);
  }

  Future<void> _onFetchHadistBooks(
    FetchHadistBooks event,
    Emitter<HadistState> emit,
  ) async {
    emit(HadistLoading());

    try {
      final books = await service.getBooks();

      if (books.isEmpty) {
        emit(HadistError('Daftar kitab kosong'));
        return;
      }

      final sortedBooks = _sortBooks(books);
      final selectedBook = sortedBooks.first;

      final hadistData = await service.getHadist(
        book: selectedBook,
        page: 1,
        perPage: event.perPage,
      );

      emit(
        HadistLoaded(
          books: sortedBooks,
          selectedBook: selectedBook,
          data: hadistData,
          query: '',
        ),
      );
    } catch (e) {
      emit(HadistError(_cleanError(e)));
    }
  }

  Future<void> _onFetchHadistList(
    FetchHadistList event,
    Emitter<HadistState> emit,
  ) async {
    final previousBooks = state is HadistLoaded
        ? (state as HadistLoaded).books
        : <String>[];

    emit(HadistLoading());

    try {
      final books = previousBooks.isNotEmpty
          ? List<String>.from(previousBooks)
          : await service.getBooks();

      final sortedBooks = _sortBooks(books);

      final hadistData = await service.getHadist(
        book: event.book,
        page: event.page,
        perPage: event.perPage,
        query: event.query,
      );

      emit(
        HadistLoaded(
          books: sortedBooks,
          selectedBook: event.book,
          data: hadistData,
          query: event.query,
        ),
      );
    } catch (e) {
      emit(HadistError(_cleanError(e)));
    }
  }

  Future<void> _onChangeHadistBook(
    ChangeHadistBook event,
    Emitter<HadistState> emit,
  ) async {
    if (state is! HadistLoaded) return;

    final current = state as HadistLoaded;

    add(
      FetchHadistList(
        book: event.book,
        page: 1,
        perPage: current.data.perPage,
        query: '',
      ),
    );
  }

  Future<void> _onUpdateHadistSearch(
    UpdateHadistSearch event,
    Emitter<HadistState> emit,
  ) async {
    if (state is! HadistLoaded) return;

    final current = state as HadistLoaded;

    add(
      FetchHadistList(
        book: current.selectedBook,
        page: 1,
        perPage: current.data.perPage,
        query: event.query,
      ),
    );
  }

  Future<void> _onChangeHadistPage(
    ChangeHadistPage event,
    Emitter<HadistState> emit,
  ) async {
    if (state is! HadistLoaded) return;

    final current = state as HadistLoaded;

    add(
      FetchHadistList(
        book: current.selectedBook,
        page: event.page,
        perPage: current.data.perPage,
        query: current.query,
      ),
    );
  }

  int _bookPriority(String book) {
    final value = book.toLowerCase();

    if (value.startsWith('shahih')) return 0;
    if (value.startsWith('sunan')) return 1;
    if (value.startsWith('musnad')) return 2;

    return 3;
  }

  List<String> _sortBooks(List<String> books) {
    final sorted = List<String>.from(books);

    sorted.sort((a, b) {
      final priorityCompare = _bookPriority(a).compareTo(_bookPriority(b));

      if (priorityCompare != 0) {
        return priorityCompare;
      }

      return a.toLowerCase().compareTo(b.toLowerCase());
    });

    return sorted;
  }

  String _cleanError(Object e) {
    return e
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiFailure: ', '')
        .trim();
  }
}
