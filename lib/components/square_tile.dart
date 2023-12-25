import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
    final Function()? onTap;

  const SquareTile({
    Key? key,
    required this.onTap,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: Image.asset(
          imagePath,
          height: 20,
          width: 20,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
