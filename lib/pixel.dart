import 'package:flutter/material.dart';

class Pixel {
  Color color = const Color.fromARGB(255, 59, 58, 58);
  bool busy = false;

  Pixel(
      {this.busy = false, this.color = const Color.fromARGB(255, 59, 58, 58)});
  // Getter for 'color'
  Color get getColor => color;

  // Setter for 'color'
  set setColor(Color newColor) {
    color = newColor;
  }

  // Getter for 'busy'
  bool get getBusy => busy;

  // Setter for 'busy'
  set setBusy(bool isBusy) {
    busy = isBusy;
  }
}
