import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../model/Product.dart';
import '../service/api_service.dart';
import 'edit_product.dart';
import 'detail_product.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await ApiService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menghapus produk...')),
      );

      try {
        await ApiService.deleteProduct(product.id);
        setState(() {
          _products.removeWhere((p) => p.id == product.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil dihapus'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
        );
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
        title: const Text('Daftar Produk'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProducts,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _products.isEmpty
                  ? const Center(child: Text('Belum Ada Produk'))
                  : RefreshIndicator(
                      onRefresh: _fetchProducts,
                      child: ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Card(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  child: ListTile(
    onTap: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailProductScreen(
            product: product,
          ),
        ),
      );

      _fetchProducts();
    },

    leading: ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: Image.network(
    ApiService.getImageUrl(product.image),
    width: 50,
    height: 50,
    fit: BoxFit.cover,

    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;

      return const SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    },

    errorBuilder: (context, error, stackTrace) {
      print("ERROR IMAGE : $error");
      print(ApiService.getImageUrl(product.image));

      return const Icon(
        Icons.broken_image,
        color: Colors.red,
        size: 40,
      );
    },
  ),
),

    title: Text(
      product.name,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),

    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatPrice(product.price),
          style: const TextStyle(color: Colors.green),
        ),
        Text(
          product.stockStatus,
          style: TextStyle(color: product.stockColor),
        ),
      ],
    ),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                    children: [

    IconButton(
      icon: const Icon(
        Icons.edit,
        color: Colors.blue,
      ),
      onPressed: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditProductScreen(
              product: product,
            ),
          ),
        ).then((_) => _fetchProducts());

      },
    ),

    IconButton(
      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
      onPressed: () => _deleteProduct(product),
    ),

  ],
),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}