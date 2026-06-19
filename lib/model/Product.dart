import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final String descriptions;
  final int price;
  final int stock;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.descriptions,
    required this.price,
    required this.stock,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      descriptions: json['descriptions'] ?? '',
      price: json['price'] ?? 0,
      stock: json['stock'] ?? 0,
      image: json['image'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'descriptions': descriptions,
      'price': price,
      'stock': stock,
      'image': image,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper untuk status stok
  String get stockStatus => stock > 0 ? 'Tersedia: $stock' : 'Stok Habis';
  Color get stockColor => stock > 0 ? Colors.green : Colors.red;
}