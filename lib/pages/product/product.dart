import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/cubit/product_cubit/product_cubit.dart';
import 'package:puldapii/models/product_model.dart';
import 'package:puldapii/pages/product/pages/product_detail.dart';
import 'package:puldapii/utils/services/product/product_service.dart';
import 'package:puldapii/utils/widget/header.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/helper/format_rupiah.dart';
import 'package:puldapii/utils/widget/widget_floating_pager.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  static const int _perPage = 8;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProductCubit(service: ProductService())
            ..getProducts(perPage: _perPage, page: 1),
      child: const _ProductView(perPage: _perPage),
    );
  }
}

class _ProductView extends StatefulWidget {
  final int perPage;

  const _ProductView({required this.perPage});

  @override
  State<_ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<_ProductView> {
  bool _showPager = false;

  final List<String> filters = const ['Semua', 'Buku Islam', 'Media Dakwah'];

  final List<String> sortFilters = const ['Terbaru', 'Rekomendasi'];

  final List<int> flexMap = const [2, 3, 4];

  void _setShowPager(bool value) {
    if (!mounted || _showPager == value) return;

    setState(() {
      _showPager = value;
    });
  }

  void _showDevelopmentDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Fitur sedang dalam tahap pengembangan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            onChatTap: () {
              _showDevelopmentDialog(context);
            },
          ),

          Expanded(
            child: GradientPage(
              child: BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  final int selectedFilter = state is ProductSuccess
                      ? state.selectedFilter
                      : 0;

                  final int selectedSort = state is ProductSuccess
                      ? state.selectedSort
                      : 0;

                  final List<ProductModel> products = state is ProductSuccess
                      ? state.products
                      : [];

                  final bool isLoading =
                      state is ProductInitial || state is ProductLoading;

                  final int page = state is ProductSuccess ? state.page : 1;

                  final bool hasNextPage = state is ProductSuccess
                      ? state.hasNextPage
                      : false;

                  // Pager hanya dibutuhkan jika terdapat halaman
                  // sebelumnya atau halaman berikutnya.
                  final bool hasPagination = page > 1 || hasNextPage;

                  final bool shouldShowPager =
                      products.isNotEmpty && hasPagination && _showPager;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: hasPagination && products.isNotEmpty
                                ? () {
                                    _setShowPager(!_showPager);
                                  }
                                : null,
                            child: NotificationListener<UserScrollNotification>(
                              onNotification: (notification) {
                                if (!hasPagination || products.isEmpty) {
                                  return false;
                                }

                                if (notification.metrics.axis !=
                                    Axis.vertical) {
                                  return false;
                                }

                                if (notification.direction ==
                                    ScrollDirection.reverse) {
                                  // Scroll ke bawah: pager muncul.
                                  _setShowPager(true);
                                } else if (notification.direction ==
                                    ScrollDirection.forward) {
                                  // Scroll ke atas: pager disembunyikan.
                                  _setShowPager(false);
                                }

                                return false;
                              },
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    // Memaksa area konten minimal setinggi
                                    // layar agar pager tidak ikut naik.
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Column(
                                    children: [
                                      _searchBar(),

                                      const SizedBox(height: 10),

                                      _filterBar(
                                        context: context,
                                        selectedFilter: selectedFilter,
                                      ),

                                      const SizedBox(height: 10),

                                      _sortBar(
                                        context: context,
                                        selectedSort: selectedSort,
                                      ),

                                      const SizedBox(height: 16),

                                      if (isLoading && products.isEmpty)
                                        const Padding(
                                          padding: EdgeInsets.all(24),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      else if (state is ProductFailure)
                                        _errorView(
                                          context: context,
                                          message: state.message,
                                        )
                                      else if (state is ProductSuccess)
                                        _productGrid(
                                          context: context,
                                          products: products,
                                        ),

                                      // Memberikan ruang agar produk terakhir
                                      // tidak tertutup floating pager.
                                      SizedBox(
                                        height: hasPagination ? 120 : 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          FloatingPager(
                            showPager: shouldShowPager,
                            page: page,
                            isLoading: isLoading,
                            hasNextPage: hasNextPage,
                            onPageChanged: (newPage) {
                              context.read<ProductCubit>().getProducts(
                                perPage: widget.perPage,
                                page: newPage,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            icon: Icon(Icons.search, size: 18, color: Colors.grey.shade600),
            hintText: 'Cari buku, produk dakwah...',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _filterBar({
    required BuildContext context,
    required int selectedFilter,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16),
        width: MediaQuery.of(context).size.width * 0.75,
        height: 30,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(229, 230, 234, 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: List.generate(filters.length, (index) {
            final bool isActive = selectedFilter == index;

            return Flexible(
              flex: flexMap[index],
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  context.read<ProductCubit>().changeFilter(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color.fromRGBO(90, 178, 173, 1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    filters[index],
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive
                          ? Colors.white
                          : const Color.fromRGBO(80, 83, 88, 1),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _sortBar({required BuildContext context, required int selectedSort}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: List.generate(sortFilters.length, (index) {
            final bool isActive = selectedSort == index;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  context.read<ProductCubit>().changeSort(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color.fromRGBO(90, 178, 173, 1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      sortFilters[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _errorView({required BuildContext context, required String message}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 44),

          const SizedBox(height: 10),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {
              context.read<ProductCubit>().getProducts(
                perPage: widget.perPage,
                page: 1,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(90, 178, 173, 1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _productGrid({
    required BuildContext context,
    required List<ProductModel> products,
  }) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Produk belum tersedia.',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(6),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        mainAxisExtent: 250,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return _buildProductCard(
          context: context,
          product: product,
          itemImg: product.imageUrl ?? '',
          itemTitle: product.name,
          itemPrice: formatRupiah(product.price),
          itemDetail: product.description,
        );
      },
    );
  }

  Widget _buildProductCard({
    required BuildContext context,
    required ProductModel product,
    required String itemImg,
    required String itemTitle,
    required String itemPrice,
    String? itemDetail,
  }) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(productId: product.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 125,
                    width: double.infinity,
                    color: Colors.white,
                    child: itemImg.trim().isEmpty
                        ? Image.asset(
                            'assets/images/product_default.png',
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            itemImg,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) {
                                return child;
                              }

                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stack) {
                              debugPrint('IMAGE ERROR: $itemImg -> $error');

                              return Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey.shade400,
                              );
                            },
                          ),
                  ),

                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      height: 18,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Baru',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      wordSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.85),
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 4),

                  SizedBox(
                    height: 28,
                    child: Text(
                      itemDetail ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.withOpacity(0.85),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    itemPrice,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
