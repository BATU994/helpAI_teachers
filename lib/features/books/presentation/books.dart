import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helpai_teachers/features/books/presentation/booksList.dart';

class Books extends StatelessWidget {
  const Books({super.key});

  @override
  Widget build(BuildContext context) {
    return const TypeOfBooks();
  }
}

class TypeOfBooks extends StatelessWidget {
  const TypeOfBooks({super.key});

  Future<List<String>> fetchTypes() async {
    final DocumentReference documentReference = FirebaseFirestore.instance
        .collection('books')
        .doc('typesOfBooks');

    try {
      final DocumentSnapshot snapshot = await documentReference.get();
      if (snapshot.exists) {
        final List<dynamic>? types = snapshot.get('types');
        return types != null ? List<String>.from(types) : [];
      } else {
        print("No books found.");
        return [];
      }
    } catch (e) {
      print("Error fetching books: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(CupertinoIcons.book_fill, color: Colors.black),
        centerTitle: true,
        title: Text('Available Books', style: TextStyle(fontSize: 20)),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchTypes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No book types found.'));
          } else {
            final typesOfBooks = snapshot.data!;
            return ListView.builder(
              itemCount: typesOfBooks.length,
              itemBuilder: (context, i) {
                return InkWell(
                  onTap: () {
                    print(typesOfBooks[i]);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => bookList(bookType: typesOfBooks[i]),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFF6B6B),
                              Color(0xFFFFA07A), 
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(
                              0xFFFFE4C4,
                            ).withOpacity(0.5), 
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(
                                    0xFFFFF5EE,
                                  ).withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.book_rounded,
                                  color: Color(0xFFDC143C), 
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  typesOfBooks[i],
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(
                                      0xFF2F4F4F,
                                    ), 
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFFFF4500),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
