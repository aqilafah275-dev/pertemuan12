import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/Product.dart';
import '../service/api_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  File? _imageFile;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.product.name);

    _descriptionController =
        TextEditingController(text: widget.product.descriptions);

    _priceController =
        TextEditingController(text: widget.product.price.toString());

    _stockController =
        TextEditingController(text: widget.product.stock.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final picked =
        await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.updateProduct(
        id: widget.product.id,
        name: _nameController.text,
        descriptions: _descriptionController.text,
        price: int.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        imageFile: _imageFile,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Produk berhasil diperbarui"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label tidak boleh kosong";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Produk"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              if (_imageFile != null)
                Image.file(
                  _imageFile!,
                  height: 170,
                )
              else
                Image.network(
                  ApiService.getImageUrl(widget.product.image),
                  height: 170,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image, size: 100),
                ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Pilih Gambar"),
              ),

              const SizedBox(height: 20),

              buildTextField(
                controller: _nameController,
                label: "Nama Produk",
              ),

              buildTextField(
                controller: _descriptionController,
                label: "Deskripsi",
              ),

              buildTextField(
                controller: _priceController,
                label: "Harga",
                keyboardType: TextInputType.number,
              ),

              buildTextField(
                controller: _stockController,
                label: "Stok",
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _updateProduct,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Update Produk"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}