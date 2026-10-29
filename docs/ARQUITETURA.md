# Arquitetura

## Princípios

- Funcionar offline para partidas no mesmo aparelho.
- Não exigir computador ou servidor permanente para partidas na rede local.
- Manter as regras dos jogos separadas da interface e da comunicação em rede.
- Usar um único código Flutter para Android e iOS.

## Organização prevista

```text
lib/
├── app/                 # Inicialização e navegação
├── core/                # Tema, utilitários e componentes compartilhados
└── features/
    ├── home/            # Catálogo de jogos
    ├── tic_tac_toe/     # Jogo da Velha: domínio e interface local
    ├── checkers/        # Damas: regras, temas e interface local
    ├── hangman/         # Forca: palavra, desenho e interface local
    ├── connect_four/    # Lig 4: motor, gravidade e interface local
    └── local_network/   # Estado autoritativo, UDP, WebSocket e telas Wi-Fi
```

Cada jogo possui uma camada `domain`, sem dependência da interface, e uma camada `presentation`. Isso permite testar as regras separadamente e reaproveitá-las no futuro modo Wi-Fi.

## Multiplayer na rede local

Um dos celulares será o anfitrião temporário da partida. Ele manterá o estado oficial do jogo e abrirá uma conexão WebSocket. Os demais aparelhos encontrarão a sala pela rede Wi-Fi usando descoberta local ou entrarão com código/QR Code.

```text
Celular anfitrião ── WebSocket na rede Wi-Fi ── Celular convidado
       │
       └── valida jogadas e mantém o estado oficial
```

O servidor existe apenas dentro do aplicativo durante a partida. Não depende do computador do desenvolvedor nem de hospedagem externa.

Na implementação atual, o anfitrião abre um `HttpServer` com WebSocket em uma porta dinâmica. O código de seis números é anunciado por UDP broadcast. Todas as jogadas do convidado passam pelo anfitrião, que valida turno, casa livre, vitória, empate e revanche antes de transmitir o novo estado.

Se o roteador bloquear broadcast, o convidado pode usar o endereço `IP:porta` exibido na tela do anfitrião.

## Evolução futura

Uma API externa será opcional e ficará reservada para contas sincronizadas, ranking global e partidas pela internet. O funcionamento local continuará independente dela.
