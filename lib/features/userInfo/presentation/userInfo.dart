import 'package:flutter/material.dart';
import 'package:helpai_teachers/features/auth/data/data_provider.dart';
import 'package:provider/provider.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final fullName = dataProvider.userName ?? 'Guest';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (dataProvider.imageUrl != null)
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(dataProvider.imageUrl!),
          )
        else
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 40)),
        const SizedBox(height: 10),
        Text(
          fullName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
