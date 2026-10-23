import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class SplashPage extends StatelessWidget {
  final VoidCallback onContinue;

  const SplashPage({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.checkroom,
                      color: AppColors.gold, size: 31),
                  SizedBox(width: 10),
                  Text(
                    'TailorPro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 220,
                      height: 230,
                      decoration: BoxDecoration(
                        color: const Color(0xFF533725),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.gold),
                      ),
                      child: const Icon(
                        Icons.dry_cleaning,
                        color: AppColors.gold,
                        size: 130,
                      ),
                    ),
                    const SizedBox(height: 34),
                    const Text(
                      'Stitch Better.\nManage Smarter.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Everything your tailoring business needs\nin one beautifully organized app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              AppButton(
                title: 'Get Started →',
                onTap: onContinue,
              ),
              const SizedBox(height: 15),
              const Text(
                'Simple • Smart • Professional',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}