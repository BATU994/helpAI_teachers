import 'package:flutter/material.dart';
import 'package:helpai_teachers/theme/apptheme.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const UserTile({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.person, color: Colors.white),
            SizedBox(width: 20),
            Text(text, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
