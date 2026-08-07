import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/cubit/product_cubit/product_cubit.dart';
import 'package:puldapii/models/product_model.dart';
import 'package:puldapii/utils/helper/format_rupiah.dart';
import 'package:puldapii/utils/services/product/product_service.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';

class ProductDetailPage extends StatelessWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  static const Color primary = Color.fromRGBO(90, 178, 173, 1);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProductCubit(service: ProductService())..getDetail(productId),
      child: Scaffold(
        body: Column(
          children: [
            SecondaryHeader(title: 'Detail Produk'),
            Expanded(
              child: GradientPage(
                child: BlocBuilder<ProductCubit, ProductState>(
                  builder: (context, state) {
                    if (state is ProductInitial ||
                        state is ProductDetailLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ProductDetailFailure) {
                      return _ErrorView(
                        message: state.message,
                        onRetry: () {
                          context.read<ProductCubit>().getDetail(productId);
                        },
                      );
                    }

                    if (state is ProductDetailSuccess) {
                      return _Content(product: state.product);
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final ProductModel product;

  const _Content({required this.product});

  static const Color primary = ProductDetailPage.primary;

  String dashIfEmpty(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  String resolveWebUrl(String url) {
    var u = url.trim();

    if (u.isEmpty) return u;

    return u.replaceFirst('http://127.0.0.1:8000', 'http://localhost:8000');
  }

  String get stockText {
    switch (product.stockStatus) {
      case 'habis':
        return 'Stok habis';
      case 'pre_order':
        return 'Pre-order';
      default:
        return 'Stok tersedia';
    }
  }

  Color get stockColor {
    switch (product.stockStatus) {
      case 'habis':
        return Colors.red;
      case 'pre_order':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveWebUrl(product.imageUrl ?? '');
    final advantages = product.advantages;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _productHeaderCard(imageUrl),
        const SizedBox(height: 10),
        _detailCard(advantages),
        const SizedBox(height: 10),
        _contactCard(),
        const SizedBox(height: 10),
        _purchaseNote(),
      ],
    );
  }

  Widget _productHeaderCard(String imageUrl) {
    return Card(
      elevation: 4,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 230,
              width: double.infinity,
              child: imageUrl.isEmpty
                  ? Image.asset(
                      'assets/images/product_default.png',
                      fit: BoxFit.contain,
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return Icon(
                          Icons.broken_image,
                          size: 58,
                          color: Colors.grey.shade400,
                        );
                      },
                    ),
            ),

            const SizedBox(height: 14),

            Text(
              product.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.85),
                height: 1.25,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              dashIfEmpty(product.description),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Text(
                    formatRupiah(product.price),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                _pill(
                  stockText,
                  color: stockColor.withOpacity(0.12),
                  textColor: stockColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard(List<String> advantages) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(Icons.info_outline, 'Informasi Produk'),
          const SizedBox(height: 12),

          _rowInfo('Kategori', product.category),
          _rowInfo('Kondisi', product.condition),
          _rowInfo('Pengiriman', product.shippingArea),
          _rowInfo('Pembayaran', product.paymentMethod),

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Keunggulan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          if (advantages.isEmpty)
            const Text(
              '-',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: advantages.map((item) {
                return _pill(
                  item,
                  color: primary.withOpacity(0.12),
                  textColor: primary,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _contactCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(Icons.support_agent_outlined, 'Kontak Penjual'),
          const SizedBox(height: 10),
          _contact(Icons.phone_in_talk_outlined, 'WhatsApp', product.whatsapp),
          _contact(Icons.email_outlined, 'Email', product.email),
          _contact(
            Icons.access_time_outlined,
            'Jam layanan',
            product.serviceHours,
          ),
        ],
      ),
    );
  }

  Widget _purchaseNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline, size: 18, color: primary),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Silahkan hubungi kontak penjual untuk melakukan pembelian',
              style: TextStyle(
                color: Color.fromRGBO(42, 48, 59, 1),
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      elevation: 4,
      color: Colors.white, // ini penting
      surfaceTintColor: Colors.white, // biar Material 3 tidak ngasih tint
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: double.infinity,
        color: Colors.white, // ini juga penting
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }

  Widget _title(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 19, color: primary),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _rowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              dashIfEmpty(value),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contact(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primary, size: 18),
          const SizedBox(width: 9),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              dashIfEmpty(value),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, {required Color color, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  static const Color primary = ProductDetailPage.primary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
