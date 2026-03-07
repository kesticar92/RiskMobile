import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

class RiskScoreWidget extends StatelessWidget {
  final int score;
  final String label;
  final double size;
  final bool showLabel;

  const RiskScoreWidget({
    super.key,
    required this.score,
    required this.label,
    this.size = 120,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(score);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: size * 0.07,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    score.toString(),
                    style: TextStyle(
                      fontSize: size * 0.28,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    '/100',
                    style: TextStyle(
                      fontSize: size * 0.12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
        if (showLabel) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class DebtGaugeWidget extends StatelessWidget {
  final double debtPercentage;

  const DebtGaugeWidget({super.key, required this.debtPercentage});

  @override
  Widget build(BuildContext context) {
    Color gaugeColor;
    if (debtPercentage < 30) {
      gaugeColor = AppColors.riskLow;
    } else if (debtPercentage < 40) {
      gaugeColor = AppColors.riskMedium;
    } else {
      gaugeColor = AppColors.riskHigh;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nivel de endeudamiento',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              AppFormatters.percent(debtPercentage / 100),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: gaugeColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (debtPercentage / 100).clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: gaugeColor.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
          ),
        ).animate().slideX(begin: -1, duration: 600.ms, curve: Curves.easeOut),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0%', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
            Container(
              width: 1,
              height: 8,
              color: AppColors.riskLow,
              margin: const EdgeInsets.only(right: 60),
            ),
            Container(
              width: 1,
              height: 8,
              color: AppColors.riskMedium,
            ),
            Text('100%', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ideal <30%', style: TextStyle(fontSize: 10, color: AppColors.riskLow)),
            Text('Máx 40%', style: TextStyle(fontSize: 10, color: AppColors.riskMedium)),
          ],
        ),
      ],
    );
  }
}
