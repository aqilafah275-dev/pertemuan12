import 'package:flutter/material.dart';
import 'produk/list_product.dart'; // Import halaman list product

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laravel Flutter API Latihan 12',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ProductListScreen(), // Diarahkan langsung ke sini
    );
  }
}