import 'package:flutter/material.dart';
import 'package:helpai_teachers/features/Articlepage/presentation/articlepage.dart';
import 'package:helpai_teachers/features/books/presentation/books.dart';
import 'package:helpai_teachers/features/chat/presentation/chat.dart';
import 'package:helpai_teachers/features/userInfo/presentation/userInfo.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int sectionIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    switch (sectionIndex) {
      case 0:
        bodyContent = Books();
        break;
      case 1:
        bodyContent = ArticlePage();
        break;
      case 2:
        bodyContent = const Chat();
        break;
      case 3:
        bodyContent = const UserInfo();
        break;
      default:
        bodyContent = const Center(child: Text('tf u lookin at'));
        break;
    }
    return Scaffold(body: bodyContent, bottomNavigationBar: bottomNavBar());
  }

  void onChanged(int index) {
    setState(() {
      sectionIndex = index;
    });
  }

  BottomNavigationBar bottomNavBar() {
    return BottomNavigationBar(
      currentIndex: sectionIndex,
      onTap: onChanged,
      selectedItemColor: Colors.blue,
      items: const [
        BottomNavigationBarItem(
          label: 'Books',
          icon: Icon(Icons.menu_book_sharp, color: Colors.blueAccent),
        ),
        BottomNavigationBarItem(
          label: 'News',
          icon: Icon(Icons.newspaper_sharp, color: Colors.blueAccent),
        ),
        BottomNavigationBarItem(
          label: 'Message',
          icon: Icon(Icons.chat_bubble, color: Colors.blueAccent),
        ),
        BottomNavigationBarItem(
          label: 'Profile',
          icon: Icon(Icons.person, color: Colors.blueAccent),
        ),
      ],
    );
  }
}
