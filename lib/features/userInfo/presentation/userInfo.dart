import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helpai_teachers/features/auth/data/data_provider.dart';
import 'package:provider/provider.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  String? uid;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    uid = user?.uid;

    if (uid != null) {
      // Call fetch and set
      Future.microtask(() {
        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        dataProvider.fetchAndSetUserData(uid!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final fullName = dataProvider.userName;

    if (fullName == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (dataProvider.imageUrl != null)
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(dataProvider.imageUrl!),
                )
              else
                const CircleAvatar(
                  radius: 70,
                  child: Icon(Icons.person, size: 40),
                ),
              const SizedBox(height: 10),
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
