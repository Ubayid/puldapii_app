import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:puldapii/models/product_model.dart';
import 'package:puldapii/utils/helper/api_helper.dart';
import 'package:puldapii/utils/services/product/product_service.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductService service;

  static const int defaultPerPage = 8;

  ProductCubit({required this.service}) : super(const ProductInitial());

  Future<void> getProducts({int perPage = defaultPerPage, int page = 1}) async {
    emit(const ProductLoading());

    try {
      final products = await service.getList(perPage: perPage, page: page);

      emit(
        ProductSuccess(
          products: products,
          selectedFilter: 0,
          selectedSort: 0,
          page: page,
          perPage: perPage,
          hasNextPage: products.length >= perPage,
        ),
      );
    } catch (e) {
      emit(ProductFailure(_errorMessage(e)));
    }
  }

  Future<void> refreshProducts() async {
    final currentState = state;

    final int currentPerPage = currentState is ProductSuccess
        ? currentState.perPage
        : defaultPerPage;

    final int currentPage = currentState is ProductSuccess
        ? currentState.page
        : 1;

    try {
      final products = await service.getList(
        perPage: currentPerPage,
        page: currentPage,
      );

      if (currentState is ProductSuccess) {
        emit(
          currentState.copyWith(
            products: products,
            page: currentPage,
            perPage: currentPerPage,
            hasNextPage: products.length >= currentPerPage,
          ),
        );
      } else {
        emit(
          ProductSuccess(
            products: products,
            page: currentPage,
            perPage: currentPerPage,
            hasNextPage: products.length >= currentPerPage,
          ),
        );
      }
    } catch (e) {
      emit(ProductFailure(_errorMessage(e)));
    }
  }

  Future<void> getDetail(int id) async {
    emit(const ProductDetailLoading());

    try {
      final product = await service.getDetail(id);

      emit(ProductDetailSuccess(product));
    } catch (e) {
      emit(ProductDetailFailure(_errorMessage(e)));
    }
  }

  Future<void> refreshDetail(int id) async {
    try {
      final product = await service.getDetail(id);

      emit(ProductDetailSuccess(product));
    } catch (e) {
      emit(ProductDetailFailure(_errorMessage(e)));
    }
  }

  void changeFilter(int index) {
    final currentState = state;

    if (currentState is ProductSuccess) {
      emit(currentState.copyWith(selectedFilter: index));
    }
  }

  void changeSort(int index) {
    final currentState = state;

    if (currentState is ProductSuccess) {
      emit(currentState.copyWith(selectedSort: index));
    }
  }
}

String _errorMessage(Object error) {
  if (error is ApiFailure) {
    return error.message;
  }

  return 'Terjadi kesalahan. Silakan coba lagi.';
}
