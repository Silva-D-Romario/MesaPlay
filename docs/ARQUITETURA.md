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
    ├── players/         # Jogadores e placar local
    ├── tic_tac_toe/     # Motor testado e interface da partida local
    └── local_network/   # Salas, descoberta e WebSocket na rede local
```

## Multiplayer na rede local

Um dos celulares será o anfitrião temporário da partida. Ele manterá o estado oficial do jogo e abrirá uma conexão WebSocket. Os demais aparelhos encontrarão a sala pela rede Wi-Fi usando descoberta local ou entrarão com código/QR Code.

```text
Celular anfitrião ── WebSocket na rede Wi-Fi ── Celular convidado
       │
       └── valida jogadas e mantém o estado oficial
```

O servidor existe apenas dentro do aplicativo durante a partida. Não depende do computador do desenvolvedor nem de hospedagem externa.

## Evolução futura

Uma API externa será opcional e ficará reservada para contas sincronizadas, ranking global e partidas pela internet. O funcionamento local continuará independente dela.
