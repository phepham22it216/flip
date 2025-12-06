import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';

// Helpers cho priority và difficulty
class TaskHelpers {
  static String priorityText(int p) {
    switch (p) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không xác định';
    }
  }

  static Color priorityColor(int p) {
    switch (p) {
      case 1:
        return AppColors.xanh2;
      case 2:
        return AppColors.vang;
      case 3:
        return AppColors.doSoft;
      default:
        return Colors.grey;
    }
  }

  static String difficultyText(int d) {
    switch (d) {
      case 1:
        return 'Dễ';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Khó';
      default:
        return 'Không xác định';
    }
  }

  static Color difficultyColor(int d) {
    switch (d) {
      case 1:
        return AppColors.xanhLa1;
      case 2:
        return AppColors.vang;
      case 3:
        return AppColors.doSoft;
      default:
        return Colors.grey;
    }
  }
}
