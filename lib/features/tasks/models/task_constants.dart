import 'package:flutter/material.dart';
import 'package:flip/theme/app_colors.dart';

/// Constants cho Task Management
class TaskConstants {
  // ============ TRẠNG THÁI (STATUS) ============
  static const String statusInProgress = 'inProgress'; // chưa xong
  static const String statusCompleted = 'completed'; // Hoàn thành
  
  // ============ ĐỘ ƯU TIÊN (PRIORITY) ============
  static const int priorityLow = 1;
  static const int priorityMedium = 2;
  static const int priorityHigh = 3;

  static String getPriorityLabel(int priority) {
    switch (priority) {
      case priorityLow:
        return 'Thấp';
      case priorityMedium:
        return 'Trung bình';
      case priorityHigh:
        return 'Cao';
      default:
        return 'Không xác định';
    }
  }

  // ============ ĐỘ KHÓ (DIFFICULTY) ============
  static const int difficultyEasy = 1;
  static const int difficultyMedium = 2;
  static const int difficultyHard = 3;

  static String getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case difficultyEasy:
        return 'Dễ';
      case difficultyMedium:
        return 'Trung bình';
      case difficultyHard:
        return 'Khó';
      default:
        return 'Không xác định';
    }
  }

  // ============ MA TRẬN EISENHOWER (MATRIX QUADRANT) ============
  static const String quadrantDoFirst = 'DO_FIRST'; // Khẩn cấp + Quan trọng
  static const String quadrantSchedule =
      'SCHEDULE'; // Không khẩn cấp + Quan trọng
  static const String quadrantDelegate =
      'DELEGATE'; // Khẩn cấp + Không quan trọng
  static const String quadrantEliminate =
      'ELIMINATE'; // Không khẩn cấp + Không quan trọng

  static String getQuadrantLabel(String quadrant) {
    switch (quadrant) {
      case quadrantDoFirst:
        return 'Làm ngay';
      case quadrantSchedule:
        return 'Lên lịch';
      case quadrantDelegate:
        return 'Ủy quyền';
      case quadrantEliminate:
        return 'Loại bỏ';
      default:
        return 'Không xác định';
    }
  }

  static String getQuadrantDescription(String quadrant) {
    switch (quadrant) {
      case quadrantDoFirst:
        return 'Khẩn cấp & Quan trọng';
      case quadrantSchedule:
        return 'Không khẩn cấp & Quan trọng';
      case quadrantDelegate:
        return 'Khẩn cấp & Không quan trọng';
      case quadrantEliminate:
        return 'Không khẩn cấp & Không quan trọng';
      default:
        return '';
    }
  }

  // ============ MÀU SẮC THEO MA TRẬN ============
  static const Color colorDoFirst = Color(0xFFFF6B9D); // Hồng
  static const Color colorSchedule = Color(0xFF9B59B6); // Tím 1
  static const Color colorDelegate = Color(0xFF4ECDC4); // Xanh 2
  static const Color colorEliminate = Color(0xFFFFB142); // Cam

  static Color getColorFromQuadrant(String quadrant) {
    switch (quadrant) {
      case quadrantDoFirst:
        return colorDoFirst;
      case quadrantSchedule:
        return colorSchedule;
      case quadrantDelegate:
        return colorDelegate;
      case quadrantEliminate:
        return colorEliminate;
      default:
        return colorEliminate;
    }
  }

  static String getQuadrantFromColor(Color color) {
    if (color.value == colorDoFirst.value) return quadrantDoFirst;
    if (color.value == colorSchedule.value) return quadrantSchedule;
    if (color.value == colorDelegate.value) return quadrantDelegate;
    if (color.value == colorEliminate.value) return quadrantEliminate;
    return quadrantEliminate;
  }

  static int getColorValue(String quadrant) {
    return getColorFromQuadrant(quadrant).value;
  }

  // ============ LOẠI TASK (TYPE) ============
  static const String typePersonal = 'personal';
  static const String typeGroup = 'group';

  // ============ REMINDER OPTIONS ============
  static const List<String> reminderOptions = [
    'Cả ngày',
    '5 phút trước',
    '10 phút trước',
    '15 phút trước',
    '30 phút trước',
    '1 giờ trước',
    '1 ngày trước',
  ];

  // ============ DEFAULT VALUES ============
  static const String defaultQuadrant = quadrantEliminate;
  static const int defaultPriority = priorityMedium;
  static const int defaultDifficulty = difficultyMedium;
  static const String defaultStatus = statusInProgress;
  static const String defaultType = typePersonal;
  static const bool defaultReminderEnabled = true;
  static const bool defaultPinned = false;
  static const int defaultPercent = 0;

  // ============ MÀU SẮC - CONVERSION (COLOR CONVERSION) ============
  static String getColorName(Color color) {
    if (color == AppColors.tim1) return 'tim1';
    if (color == AppColors.tim2) return 'tim2';
    if (color == AppColors.hong) return 'hong';
    if (color == AppColors.da) return 'da';
    if (color == AppColors.xanh1) return 'xanh1';
    if (color == AppColors.xanh2) return 'xanh2';
    if (color == AppColors.xanh3) return 'xanh3';
    if (color == AppColors.doSoft) return 'doSoft';
    if (color == AppColors.xanhLa1) return 'xanhLa1';
    if (color == AppColors.xanhLa2) return 'xanhLa2';
    if (color == AppColors.xanhLa3) return 'xanhLa3';
    if (color == AppColors.cam) return 'cam';
    if (color == AppColors.vang) return 'vang';
    if (color == AppColors.success) return 'success';
    return 'xanh1'; // default fallback
  }
}
