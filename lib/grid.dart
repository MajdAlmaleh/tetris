import 'package:flutter/material.dart';
import 'package:tetris/pixel.dart';

class Grid extends StatefulWidget {
  
  final List<Pixel> pixels;

  const Grid({Key? key, required this.pixels})
      : super(key: key);

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: 180,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 3, mainAxisSpacing: 3, crossAxisCount: 10),
        itemBuilder: (context, index) {

          return Container(
            color: widget.pixels[index].getColor,
          );
        });
  }
}
