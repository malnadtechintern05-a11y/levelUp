import 'package:flutter/material.dart';

class AvatarHelper {
  static IconData getIconForId(String avatarId) {
    switch (avatarId) {
      case 'hero1':
        return Icons.person;
      case 'hero2':
        return Icons.face;
      case 'hero3':
        return Icons.star;
      case 'hero4':
        return Icons.shield;
      case 'hero5':
        return Icons.bolt;
      case 'hero6':
        return Icons.pets;
      default:
        return Icons.person;
    }
  }
}
