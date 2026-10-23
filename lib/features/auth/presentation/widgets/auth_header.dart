import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: AppColors.goldLight,
          child: Icon(
            Icons.content_cut,
            color: AppColors.primary,
            size: 36,
          ),
        ),
        SizedBox(height: 15),
        Text(
          'Welcome to TailorPro',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Sign in to manage your tailoring business',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}