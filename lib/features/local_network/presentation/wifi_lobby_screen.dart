import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/local_room_client.dart';
import '../data/local_room_discovery.dart';
import '../data/local_room_server.dart';
import 'wifi_tic_tac_toe_screen.dart';

class WifiLobbyScreen extends StatefulWidget {
  const WifiLobbyScreen({super.key});

  @override
  State<WifiLobbyScreen> createState() => _WifiLobbyScreenState();
}

class _WifiLobbyScreenState extends State<WifiLobbyScreen> {
  final _hostNameController = TextEditingController();
  final _guestNameController = TextEditingController();
  final _roomCodeController = TextEditingController();
  final _addressController = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _hostNameController.dispose();
    _guestNameController.dispose();
    _roomCodeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.coral),
    );
  }

  Future<void> _createRoom() async {
    final name = _hostNameController.text.trim();
    if (name.isEmpty) {
      _showError('Informe o nome do anfitrião.');
      return;
    }
    setState(() => _busy = true);
    try {
      final server = await LocalRoomServer.start(hostName: name);
      if (!mounted) {
        await server.close();
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WifiTicTacToeScreen.host(server: server),
        ),
      );
    } on SocketException {
      _showError('Não foi possível abrir a sala nesta rede.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _joinRoom() async {
    final name = _guestNameController.text.trim();
    final code = _roomCodeController.text.trim();
    if (name.isEmpty) {
      _showError('Informe o nome do convidado.');
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      _showError('Informe o código de seis números da sala.');
      return;
    }
    setState(() => _busy = true);
    try {
      final manual = _parseAddress(_addressController.text);
      final discovered = manual == null
          ? await LocalRoomDiscoveryResponder.find(code)
          : null;
      final address = manual?.$1 ?? discovered?.address;
      final port = manual?.$2 ?? discovered?.port;
      if (address == null || port == null) {
        _showError(
          'Sala não encontrada. Confirme o Wi-Fi ou informe IP:porta.',
        );
        return;
      }
      final client = await LocalRoomClient.connect(
        address: address,
        port: port,
        guestName: name,
      );
      if (!mounted) {
        await client.close();
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WifiTicTacToeScreen.guest(client: client),
        ),
      );
    } on TimeoutException {
      _showError('A sala demorou para responder. Tente novamente.');
    } on SocketException {
      _showError('Não foi possível conectar ao celular anfitrião.');
    } on StateError catch (error) {
      _showError(error.message.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  (String, int)? _parseAddress(String value) {
    final match = RegExp(
      r'^([0-9]{1,3}(?:\.[0-9]{1,3}){3}):(\d{1,5})$',
    ).firstMatch(value.trim());
    if (match == null) return null;
    final port = int.tryParse(match.group(2)!);
    if (port == null || port < 1 || port > 65535) return null;
    return (match.group(1)!, port);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Sala Wi-Fi'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.8),
            radius: 1.3,
            colors: [Color(0xFF173C4C), AppColors.background],
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _NetworkNotice(),
                    const SizedBox(height: 18),
                    _LobbyCard(
                      icon: Icons.wifi_tethering_rounded,
                      accent: AppColors.primary,
                      eyebrow: 'ANFITRIÃO',
                      title: 'Criar sala',
                      description:
                          'Este celular mantém a partida enquanto a sala estiver aberta.',
                      children: [
                        _LobbyField(
                          key: const Key('wifi-host-name'),
                          controller: _hostNameController,
                          label: 'Seu nome',
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          key: const Key('create-wifi-room'),
                          onPressed: _busy ? null : _createRoom,
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          label: const Text('Criar sala de Jogo da Velha'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _LobbyCard(
                      icon: Icons.login_rounded,
                      accent: AppColors.cyan,
                      eyebrow: 'CONVIDADO',
                      title: 'Entrar na sala',
                      description:
                          'Digite o código exibido no celular anfitrião.',
                      children: [
                        _LobbyField(
                          key: const Key('wifi-guest-name'),
                          controller: _guestNameController,
                          label: 'Seu nome',
                        ),
                        const SizedBox(height: 12),
                        _LobbyField(
                          key: const Key('wifi-room-code'),
                          controller: _roomCodeController,
                          label: 'Código de 6 números',
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                        ),
                        const SizedBox(height: 12),
                        _LobbyField(
                          key: const Key('wifi-manual-address'),
                          controller: _addressController,
                          label: 'IP:porta (opcional)',
                          hint: '192.168.0.10:43210',
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          key: const Key('join-wifi-room'),
                          onPressed: _busy ? null : _joinRoom,
                          icon: const Icon(Icons.search_rounded),
                          label: const Text('Encontrar e entrar'),
                        ),
                      ],
                    ),
                    if (_busy) ...[
                      const SizedBox(height: 20),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NetworkNotice extends StatelessWidget {
  const _NetworkNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.router_rounded, color: AppColors.secondary, size: 30),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Os dois celulares devem estar na mesma rede Wi-Fi. Não é necessário computador ou internet.',
            ),
          ),
        ],
      ),
    );
  }
}

class _LobbyCard extends StatelessWidget {
  const _LobbyCard({
    required this.icon,
    required this.accent,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.children,
  });

  final IconData icon;
  final Color accent;
  final String eyebrow;
  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, color: accent, size: 38),
          const SizedBox(height: 12),
          Text(
            eyebrow,
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(description),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _LobbyField extends StatelessWidget {
  const _LobbyField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.maxLength,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
