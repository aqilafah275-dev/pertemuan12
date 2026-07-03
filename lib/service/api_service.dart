import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../model/Product.dart';

class ApiService {
 static const String baseUrl = 'http://localhost:8000/api';
static const String storageUrl = 'http://localhost:8000/storage';

  static String getImageUrl(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return '';
  }

  return '$storageUrl/$imagePath';
}

  // GET ALL PRODUCTS
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is List) {
          return decoded.map((json) => Product.fromJson(json)).toList();
        } else if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('data') && decoded['data'] is List) {
            return (decoded['data'] as List).map((json) => Product.fromJson(json)).toList();
          } else if (decoded.containsKey('products') && decoded['products'] is List) {
            return (decoded['products'] as List).map((json) => Product.fromJson(json)).toList();
          } else if (decoded.containsKey('result') && decoded['result'] is List) {
            return (decoded['result'] as List).map((json) => Product.fromJson(json)).toList();
          } else {
            return [Product.fromJson(decoded)];
          }
        } else {
          throw Exception('Format response tidak dikenali');
        }
      } else {
        throw Exception('Gagal memuat produk: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getProducts: $e');
      throw Exception('Error: $e');
    }
  }

  // GET PRODUCT BY ID
  static Future<Product> getProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          return Product.fromJson(decoded['data']);
        }
        return Product.fromJson(decoded);
      } else {
        throw Exception('Produk tidak ditemukan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // REDUCE STOCK
  static Future<Product> reduceStock(int productId, int quantity) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/products/$productId/reduce-stock'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'quantity': quantity}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          return Product.fromJson(decoded['data']);
        }
        return Product.fromJson(decoded);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Stok tidak mencukupi');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // DELETE PRODUCT
  static Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal menghapus produk');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // CREATE PRODUCT
  static Future<Product> createProduct({
    required String name,
    required String descriptions,
    required int price,
    required int stock,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'descriptions': descriptions,
          'price': price,
          'stock': stock,
        }),
      );

      if (response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          return Product.fromJson(decoded['data']);
        }
        return Product.fromJson(decoded);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal membuat produk');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // UPDATE PRODUCT (MULTIPART)
  static Future<Product> updateProduct({
    required int id,
    String? name,
    String? descriptions,
    int? price,
    int? stock,
    File? imageFile,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products/$id'));
      request.fields['_method'] = 'PUT';

      if (name != null) request.fields['name'] = name;
      if (descriptions != null) request.fields['descriptions'] = descriptions;
      if (price != null) request.fields['price'] = price.toString();
      if (stock != null) request.fields['stock'] = stock.toString();

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          return Product.fromJson(decoded['data']);
        }
        return Product.fromJson(decoded);
      } else {
        throw Exception('Gagal memperbarui produk');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // UPLOAD IMAGE SEPARATELY
  static Future<String> uploadImage(int productId, File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products/$productId/upload-image'));
      request.headers['Accept'] = 'application/json';

      var multipartFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['image_url'] ?? '';
      } else {
        throw Exception('Upload gambar gagal');
      }
    } catch (e) {
      throw Exception('Error upload gambar: $e');
    }
  }
}