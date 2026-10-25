import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/game_preview.dart';

class GameCard extends StatelessWidget {
  const GameCard({required this.game, super.key});

  final GamePreview game;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: game.accent.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: game.accent.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: game.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(game.icon, color: game.accent, size: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  game.status,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(game.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(game.description),
        ],
      ),
    );
  }
}
