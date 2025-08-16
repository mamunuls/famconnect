
import 'package:famconnect/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSnackBarMessage(BuildContext context, String message,
    [bool isError = false]) {
  Get.snackbar(
    isError ? 'Error' : 'Success',
    message,
    duration: const Duration(seconds: 5),
    snackPosition: SnackPosition.TOP,
    backgroundColor: isError ? Colors.red : AppColors.themeColor,
    colorText: Colors.white,
    icon: Icon(
      isError ? Icons.error : Icons.check_circle,
      color: Colors.white,
    ),
    borderRadius: 20,
    margin: const EdgeInsets.all(15),
    isDismissible: true,
    // dismissDirection: SnackDismissDirection.VERTICAL,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.easeOutBack,
  );
}
