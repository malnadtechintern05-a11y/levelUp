import 'dart:io';
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

  static Widget buildAvatar({
    required String avatarId,
    String? profileImagePath,
    double radius = 24,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    if (profileImagePath != null &&
        profileImagePath.isNotEmpty &&
        File(profileImagePath).existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(profileImagePath)),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? const Color(0xFF0F172A),
      child: Icon(
        getIconForId(avatarId),
        size: radius * 1.1,
        color: iconColor ?? const Color(0xFFF5B942),
      ),
    );
  }
}
