import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puldapii/models/book_taawun_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';
import 'package:puldapii/utils/services/home/book_taawun_service.dart';

part 'book_taawun_event.dart';
part 'book_taawun_state.dart';

class BookTaawunBloc extends Bloc<BookTaawunEvent, BookTaawunState> {
  final BookTaawunService service;

  BookTaawunBloc({required this.service}) : super(const BookTaawunState()) {
    on<BookTaawunInitialized>(_onInitialized);
    on<BookTaawunLoaded>(_onLoaded);
    on<BookTaawunRefreshed>(_onRefreshed);
    on<BookTaawunPageChanged>(_onPageChanged);
    on<BookTaawunSearchChanged>(_onSearchChanged);
    on<BookTaawunStatusChanged>(_onStatusChanged);
    on<BookTaawunActiveBooksLoaded>(_onActiveBooksLoaded);
    on<BookTaawunDetailLoaded>(_onDetailLoaded);
    on<BookTaawunCreated>(_onCreated);
    on<BookTaawunUpdated>(_onUpdated);
    on<BookTaawunCancelled>(_onCancelled);
    on<BookTaawunMessageCleared>(_onMessageCleared);
  }

  Future<void> _onInitialized(
    BookTaawunInitialized event,
    Emitter<BookTaawunState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        isBooksLoading: event.loadBooks,
        statusFilter: event.status,
        search: event.search,
        page: event.page,
        perPage: event.perPage,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    try {
      final response = await service.getTaawuns(
        status: event.status,
        search: event.search,
        page: event.page,
        perPage: event.perPage,
      );

      final pagination = BookTaawunPaginationModel.fromJson(response);

      List<BookTaawunBookModel> activeBooks = state.activeBooks;

      if (event.loadBooks) {
        final booksResponse = await service.getActiveBooks();
        activeBooks = _extractBookList(booksResponse);
      }

      emit(
        state.copyWith(
          isLoading: false,
          isBooksLoading: false,
          taawuns: pagination.data,
          activeBooks: activeBooks,
          page: pagination.currentPage,
          perPage: pagination.perPage,
          lastPage: pagination.lastPage,
          total: pagination.total,
          from: pagination.from,
          to: pagination.to,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isBooksLoading: false,
          errorMessage: _cleanException(e),
        ),
      );
    }
  }

  Future<void> _onLoaded(
    BookTaawunLoaded event,
    Emitter<BookTaawunState> emit,
  ) async {
    await _loadTaawuns(
      emit,
      page: event.page,
      status: event.status,
      search: event.search,
      perPage: event.perPage,
    );
  }

  Future<void> _onRefreshed(
    BookTaawunRefreshed event,
    Emitter<BookTaawunState> emit,
  ) async {
    await _loadTaawuns(
      emit,
      page: state.page,
      status: state.statusFilter,
      search: state.search,
      perPage: state.perPage,
    );
  }

  Future<void> _onPageChanged(
    BookTaawunPageChanged event,
    Emitter<BookTaawunState> emit,
  ) async {
    await _loadTaawuns(
      emit,
      page: event.page,
      status: state.statusFilter,
      search: state.search,
      perPage: state.perPage,
    );
  }

  Future<void> _onSearchChanged(
    BookTaawunSearchChanged event,
    Emitter<BookTaawunState> emit,
  ) async {
    await _loadTaawuns(
      emit,
      page: 1,
      status: state.statusFilter,
      search: event.search,
      perPage: state.perPage,
    );
  }

  Future<void> _onStatusChanged(
    BookTaawunStatusChanged event,
    Emitter<BookTaawunState> emit,
  ) async {
    await _loadTaawuns(
      emit,
      page: 1,
      status: event.status,
      search: state.search,
      perPage: state.perPage,
    );
  }

  Future<void> _onActiveBooksLoaded(
    BookTaawunActiveBooksLoaded event,
    Emitter<BookTaawunState> emit,
  ) async {
    emit(state.copyWith(isBooksLoading: true, clearErrorMessage: true));

    try {
      final response = await service.getActiveBooks();

      emit(
        state.copyWith(
          isBooksLoading: false,
          activeBooks: _extractBookList(response),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isBooksLoading: false, errorMessage: _cleanException(e)),
      );
    }
  }

  Future<void> _onDetailLoaded(
    BookTaawunDetailLoaded event,
    Emitter<BookTaawunState> emit,
  ) async {
    emit(state.copyWith(isDetailLoading: true, clearErrorMessage: true));

    try {
      final response = await service.getTaawunDetail(event.id);

      emit(
        state.copyWith(
          isDetailLoading: false,
          selectedTaawun: _extractTaawunDetail(response),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isDetailLoading: false,
          errorMessage: _cleanException(e),
        ),
      );
    }
  }

  Future<void> _onCreated(
    BookTaawunCreated event,
    Emitter<BookTaawunState> emit,
  ) async {
    await _runAction(
      emit,
      action: () {
        return service.createTaawun(
          bookId: event.bookId,
          donorName: event.donorName,
          donorWhatsapp: event.donorWhatsapp,
          donorEmail: event.donorEmail,
          amount: event.amount,
        );
      },
      successMessage: 'Data taawun berhasil dibuat.',
    );
  }

  Future<void> _onUpdated(
    BookTaawunUpdated event,
    Emitter<BookTaawunState> emit,
  ) async {
    await _runAction(
      emit,
      action: () {
        return service.updateTaawun(
          id: event.id,
          bookId: event.bookId,
          donorName: event.donorName,
          donorWhatsapp: event.donorWhatsapp,
          donorEmail: event.donorEmail,
          amount: event.amount,
          paymentProof: event.paymentProof,
          removePaymentProof: event.removePaymentProof,
        );
      },
      successMessage: 'Data taawun berhasil diperbarui.',
    );
  }

  Future<void> _onCancelled(
    BookTaawunCancelled event,
    Emitter<BookTaawunState> emit,
  ) async {
    await _runAction(
      emit,
      action: () => service.cancelTaawun(event.id),
      successMessage: 'Data taawun berhasil dibatalkan.',
    );
  }

  void _onMessageCleared(
    BookTaawunMessageCleared event,
    Emitter<BookTaawunState> emit,
  ) {
    emit(state.copyWith(clearErrorMessage: true, clearSuccessMessage: true));
  }

  Future<void> _loadTaawuns(
    Emitter<BookTaawunState> emit, {
    required int page,
    required String status,
    required String search,
    required int perPage,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      emit(
        state.copyWith(
          isLoading: true,
          page: page,
          statusFilter: status,
          search: search,
          perPage: perPage,
          clearErrorMessage: true,
          clearSuccessMessage: true,
        ),
      );
    }

    try {
      final response = await service.getTaawuns(
        status: status,
        search: search,
        page: page,
        perPage: perPage,
      );

      final pagination = BookTaawunPaginationModel.fromJson(response);

      emit(
        state.copyWith(
          isLoading: false,
          taawuns: pagination.data,
          page: pagination.currentPage,
          perPage: pagination.perPage,
          lastPage: pagination.lastPage,
          total: pagination.total,
          from: pagination.from,
          to: pagination.to,
          statusFilter: status,
          search: search,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _cleanException(e)));
    }
  }

  Future<void> _runAction(
    Emitter<BookTaawunState> emit, {
    required Future<Map<String, dynamic>> Function() action,
    required String successMessage,
  }) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    try {
      final response = await action();

      final message = response['message']?.toString() ?? successMessage;

      emit(state.copyWith(isSubmitting: false, successMessage: message));

      await _loadTaawuns(
        emit,
        page: state.page,
        status: state.statusFilter,
        search: state.search,
        perPage: state.perPage,
        showLoading: false,
      );
    } catch (e) {
      emit(
        state.copyWith(isSubmitting: false, errorMessage: _cleanException(e)),
      );
    }
  }

  static BookTaawunModel? _extractTaawunDetail(Map<String, dynamic> response) {
    final data = response['data'];

    if (data is Map) {
      return BookTaawunModel.fromJson(Map<String, dynamic>.from(data));
    }

    return null;
  }

  static List<BookTaawunBookModel> _extractBookList(
    Map<String, dynamic> response,
  ) {
    dynamic source = response['data'];

    if (source is Map && source['data'] is List) {
      source = source['data'];
    }

    if (source is! List && response['books'] is List) {
      source = response['books'];
    }

    if (source is List) {
      return source
          .where((item) => item is Map)
          .map(
            (item) => BookTaawunBookModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    return [];
  }

  static String _cleanException(Object error) {
    if (error is ApiFailure) {
      return error.message;
    }

    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
