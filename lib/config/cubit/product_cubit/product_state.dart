part of 'product_cubit.dart';

sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

final class ProductInitial extends ProductState {
  const ProductInitial();
}

final class ProductLoading extends ProductState {
  const ProductLoading();
}

final class ProductSuccess extends ProductState {
  final List<ProductModel> products;
  final int selectedFilter;
  final int selectedSort;

  final int page;
  final int perPage;
  final bool hasNextPage;

  const ProductSuccess({
    required this.products,
    this.selectedFilter = 0,
    this.selectedSort = 0,
    this.page = 1,
    this.perPage = 8,
    this.hasNextPage = false,
  });

  ProductSuccess copyWith({
    List<ProductModel>? products,
    int? selectedFilter,
    int? selectedSort,
    int? page,
    int? perPage,
    bool? hasNextPage,
  }) {
    return ProductSuccess(
      products: products ?? this.products,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedSort: selectedSort ?? this.selectedSort,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }

  @override
  List<Object?> get props => [
    products,
    selectedFilter,
    selectedSort,
    page,
    perPage,
    hasNextPage,
  ];
}

final class ProductFailure extends ProductState {
  final String message;

  const ProductFailure(this.message);

  @override
  List<Object?> get props => [message];
}

final class ProductDetailLoading extends ProductState {
  const ProductDetailLoading();
}

final class ProductDetailSuccess extends ProductState {
  final ProductModel product;

  const ProductDetailSuccess(this.product);

  @override
  List<Object?> get props => [product];
}

final class ProductDetailFailure extends ProductState {
  final String message;

  const ProductDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}
