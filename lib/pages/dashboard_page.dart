import 'package:flutter/material.dart';

import '../produk/add_product.dart';
import '../produk/list_product.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        child: Padding(

          padding: const EdgeInsets.all(20),

          child: Column(

            children: [

              const SizedBox(height: 20),

              const CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 45,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Yummy Food App",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Selamat Datang 👋",
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 40),

              Row(

                children: [

                  Expanded(

                    child: menuCard(

                      context,

                      Icons.inventory,

                      "Data Produk",

                      Colors.orange,

                      (){

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProductListScreen(),
                          ),
                        );

                      },

                    ),

                  ),

                  const SizedBox(width: 20),

                  Expanded(

                    child: menuCard(

                      context,

                      Icons.add_box,

                      "Tambah Produk",

                      Colors.green,

                      (){

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddProductScreen(),
                          ),
                        );

                      },

                    ),

                  ),

                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget menuCard(
      BuildContext context,
      IconData icon,
      String title,
      Color color,
      VoidCallback onTap){

    return InkWell(

      onTap: onTap,

      child: Card(

        elevation: 5,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        child: Padding(

          padding: const EdgeInsets.symmetric(vertical: 30),

          child: Column(

            children: [

              Icon(
                icon,
                size: 60,
                color: color,
              ),

              const SizedBox(height: 15),

              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}