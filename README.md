# MesaPlay

Aplicativo mobile de jogos de tabuleiro para jogar no mesmo celular ou com amigos conectados à mesma rede Wi-Fi.

> Projeto em desenvolvimento. A primeira etapa entrega a fundação Flutter, a identidade visual e a automação de qualidade.

## Proposta

O MesaPlay reunirá jogos rápidos como jogo da velha, Lig 4, Reversi e damas. Cada jogador poderá informar seu nome, manter um placar local e escolher entre duas formas de partida:

- **Mesmo celular:** dois jogadores compartilham o aparelho.
- **Rede Wi-Fi:** um celular cria a sala e funciona como anfitrião temporário, sem depender de computador ou servidor externo.

## Tecnologias

- Flutter e Dart
- Material 3
- WebSocket e descoberta na rede local nas próximas etapas
- Testes de widgets e regras de negócio
- GitHub Actions

## Executar localmente

Pré-requisitos: Flutter 3.35.2 ou compatível e um dispositivo/emulador configurado.

```bash
flutter pub get
flutter run
```

Validar o projeto:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Arquitetura

O código é organizado por funcionalidades. As regras de cada jogo ficarão separadas da interface e da comunicação em rede, permitindo testes isolados e reutilização dos modos de partida.

Consulte a [arquitetura](docs/ARQUITETURA.md) e o [roadmap](docs/ROADMAP.md) para acompanhar as próximas entregas.

## Fluxo de desenvolvimento

- `main`: versão estável.
- `develop`: desenvolvimento e validação.
- Mudanças entram em `main` por pull request após os testes automáticos.

## Autor

Desenvolvido por [Romário Silva](https://github.com/Silva-D-Romario).
