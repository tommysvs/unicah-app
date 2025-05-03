import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final double height;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = false,
    this.height = kToolbarHeight + 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 0, 100, 255),
              Color.fromARGB(255, 0, 76, 190),
            ],
          ),
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30), // Border radius inferior derecho
          ),
        ),
        child: AppBar(
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading:
              showBackButton
                  ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
