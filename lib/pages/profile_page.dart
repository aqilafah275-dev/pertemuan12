import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'logout_page.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 55,
              child: Icon(
                Icons.person,
                size: 60,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              user?.email ?? "-",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Food Product App",
              style: TextStyle(fontSize: 16),
            ),

            const Spacer(),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton.icon(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),

                onPressed: () async {
                  onPressed: () {
                   LogoutPage.logout(context);
                  };

                },

                icon: const Icon(Icons.logout,color: Colors.white),

                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),

              ),
            ),

          ],
        ),
      ),
    );
  }
}