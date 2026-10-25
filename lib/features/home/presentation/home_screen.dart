import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../tic_tac_toe/presentation/tic_tac_toe_setup_screen.dart';
import '../domain/game_preview.dart';
import 'widgets/game_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const games = [
    GamePreview(
      name: 'Jogo da Velha',
      description: 'Partidas rápidas para dois jogadores.',
      icon: Icons.grid_3x3_rounded,
      accent: AppColors.primary,
      status: 'PRÓXIMO',
    ),
    GamePreview(
      name: 'Lig 4',
      description: 'Estratégia simples, disputa intensa.',
      icon: Icons.view_column_rounded,
      accent: AppColors.coral,
      status: 'EM BREVE',
    ),
    GamePreview(
      name: 'Damas',
      description: 'O clássico de tabuleiro entre amigos.',
      icon: Icons.circle_outlined,
      accent: AppColors.secondary,
      status: 'PLANEJADO',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.9),
            radius: 1.25,
            colors: [Color(0xFF20214A), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 36),
                sliver: SliverList.list(
                  children: [
                    const _TopBar(),
                    const SizedBox(height: 42),
                    const _HeroSection(),
                    const SizedBox(height: 34),
                    Text(
                      'Escolha o próximo desafio',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 238,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: games.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemBuilder: (context, index) => GameCard(
                          game: games[index],
                          onTap: () => index == 0
                              ? _openTicTacToe(context)
                              : _showComingSoon(context, games[index].name),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    const _LanPreview(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _openTicTacToe(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TicTacToeSetupScreen()),
    );
  }

  static void _showComingSoon(BuildContext context, String game) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$game chegará em uma próxima etapa.')),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.cyan],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'MP',
            style: TextStyle(
              color: AppColors.background,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'MesaPlay',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        IconButton.filledTonal(
          tooltip: 'Perfil',
          onPressed: () {},
          icon: const Icon(Icons.person_outline_rounded),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(99),
          ),
          child: const Text(
            'JOGUE JUNTO, ONDE ESTIVER',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Sua mesa. Seus amigos.\nEm qualquer lugar.',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 14),
        const Text(
          'Jogue no mesmo celular ou crie uma sala na rede Wi-Fi, sem depender de um servidor permanente.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 430) {
              return const Column(
                children: [_LocalButton(), SizedBox(height: 12), _LanButton()],
              );
            }

            return const Row(
              children: [
                Expanded(child: _LocalButton()),
                SizedBox(width: 12),
                Expanded(child: _LanButton()),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _LocalButton extends StatelessWidget {
  const _LocalButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => HomeScreen._openTicTacToe(context),
        icon: const Icon(Icons.smartphone_rounded),
        label: const Text('Mesmo celular'),
      ),
    );
  }
}

class _LanButton extends StatelessWidget {
  const _LanButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.wifi_tethering_rounded),
        label: const Text('Sala Wi-Fi'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(0, 52),
          side: const BorderSide(color: AppColors.surfaceLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _LanPreview extends StatelessWidget {
  const _LanPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.22),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.28)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.hub_rounded, color: AppColors.secondary, size: 30),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multiplayer local',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Um celular cria a sala e os amigos entram pela mesma rede Wi-Fi.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
