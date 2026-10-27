# AsobiPlay

Aplicativo mobile de jogos de tabuleiro para jogar no mesmo celular ou com amigos conectados à mesma rede Wi-Fi.

> Projeto em desenvolvimento. A versão atual permite jogar Jogo da Velha, Damas e Forca com dois jogadores no mesmo celular.

## Recursos disponíveis

- Cadastro rápido dos nomes dos jogadores em cada jogo.
- Jogo da Velha com validação de jogadas, vitória, empate e revanche.
- Damas com capturas obrigatórias, múltiplas capturas, promoção e damas voadoras.
- Personalização das cores do tabuleiro e das peças de Damas.
- Forca com palavra secreta protegida, dica opcional e desenho progressivo do boneco.
- Placar mantido durante as partidas e alternância de papéis nas revanches.
- Interface responsiva para Android e iOS.

## Proposta

O AsobiPlay reúne jogos rápidos para jogar com amigos. Cada jogador pode informar seu nome, manter um placar local e escolher entre duas formas de partida:

- **Mesmo celular:** dois jogadores compartilham o aparelho.
- **Rede Wi-Fi:** um celular cria a sala e funciona como anfitrião temporário, sem depender de computador ou servidor externo.

## Tecnologias

- Flutter e Dart
- Material 3
- WebSocket e descoberta na rede local nas próximas etapas
- Testes unitários e de widgets
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

O código é organizado por funcionalidades. As regras de cada jogo são separadas da interface e da futura comunicação em rede, permitindo testes isolados e reutilização dos modos de partida.

Consulte a [arquitetura](docs/ARQUITETURA.md) e o [roadmap](docs/ROADMAP.md) para acompanhar as próximas entregas.

## Fluxo de desenvolvimento

- `main`: versão estável.
- `develop`: desenvolvimento e validação.
- Mudanças entram em `main` por pull request após os testes automáticos.

## Autor

Desenvolvido por [Romário Silva](https://github.com/Silva-D-Romario).
