import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../model/Product.dart';
import '../service/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _currentProduct;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  Future<void> _buyProduct() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Mengurangi stok sebanyak 1 via API Patch Laravel
      final updatedProduct = await ApiService.reduceStock(_currentProduct.id, 1);
      setState(() {
        _currentProduct = updatedProduct;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil membeli produk! Stok berkurang.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membeli: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _formatPrice(int price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentProduct.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true), // Mengembalikan status true agar halaman list refresh otomatis
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: ApiService.getImageUrl(_currentProduct.image),
                width: 250,
                height: 250,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 100),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(_currentProduct.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_formatPrice(_currentProduct.price), style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _currentProduct.stockColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _currentProduct.stockStatus,
              style: TextStyle(color: _currentProduct.stockColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Deskripsi Produk:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(_currentProduct.descriptions, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _isProcessing || _currentProduct.stock <= 0 ? null : _buyProduct,
            icon: const Icon(Icons.shopping_bag),
            label: Text(_isProcessing ? 'Memproses...' : 'Beli Sekarang (Kurangi Stok)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}