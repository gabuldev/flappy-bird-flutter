# Requirements Document

## Introduction

Este projeto implementa uma versão simplificada do clássico jogo Flappy Bird usando Flutter, demonstrando as capacidades de renderização 2D do framework. O jogo apresenta um pássaro que voa através de obstáculos em um ambiente de rolagem lateral contínua, com controles simples de toque/clique e mecânicas de jogo intuitivas.

## Requirements

### Requirement 1

**User Story:** Como jogador, eu quero controlar um pássaro voando na tela, para que eu possa navegar através dos obstáculos.

#### Acceptance Criteria

1. WHEN o jogador toca na tela THEN o pássaro SHALL pular/voar para cima
2. WHEN não há input do jogador THEN o pássaro SHALL cair devido à gravidade
3. WHEN o jogo inicia THEN o pássaro SHALL aparecer no lado esquerdo da tela
4. IF o pássaro sai dos limites da tela THEN o jogo SHALL terminar

### Requirement 2

**User Story:** Como jogador, eu quero enfrentar obstáculos que se movem pela tela, para que o jogo seja desafiador.

#### Acceptance Criteria

1. WHEN o jogo está rodando THEN obstáculos (canos) SHALL aparecer do lado direito da tela
2. WHEN obstáculos aparecem THEN eles SHALL se mover da direita para a esquerda continuamente
3. WHEN obstáculos saem da tela THEN novos obstáculos SHALL ser gerados
4. IF o pássaro colide com um obstáculo THEN o jogo SHALL terminar
5. WHEN o pássaro passa por um par de canos THEN o jogador SHALL ganhar pontos

### Requirement 3

**User Story:** Como jogador, eu quero ver minha pontuação durante o jogo, para que eu possa acompanhar meu progresso.

#### Acceptance Criteria

1. WHEN o jogo inicia THEN a pontuação SHALL começar em zero
2. WHEN o pássaro passa por um obstáculo THEN a pontuação SHALL aumentar em 1 ponto
3. WHEN o jogo está rodando THEN a pontuação atual SHALL ser exibida na tela
4. WHEN o jogo termina THEN a pontuação final SHALL ser mostrada

### Requirement 4

**User Story:** Como jogador, eu quero poder reiniciar o jogo após perder, para que eu possa tentar novamente.

#### Acceptance Criteria

1. WHEN o jogo termina THEN uma tela de game over SHALL ser exibida
2. WHEN a tela de game over é mostrada THEN um botão de reiniciar SHALL estar disponível
3. WHEN o jogador clica em reiniciar THEN o jogo SHALL voltar ao estado inicial
4. WHEN o jogo reinicia THEN a pontuação SHALL ser resetada para zero

### Requirement 5

**User Story:** Como jogador, eu quero uma experiência visual fluida, para que o jogo seja agradável de jogar.

#### Acceptance Criteria

1. WHEN o jogo está rodando THEN a animação SHALL manter 60 FPS consistentes
2. WHEN elementos se movem na tela THEN as transições SHALL ser suaves
3. WHEN o pássaro voa THEN ele SHALL ter uma animação de batida de asas
4. WHEN o fundo se move THEN ele SHALL criar um efeito de paralaxe
5. IF o dispositivo não consegue manter 60 FPS THEN o jogo SHALL ajustar automaticamente para manter fluidez

### Requirement 6

**User Story:** Como jogador, eu quero controles responsivos, para que eu tenha controle preciso sobre o pássaro.

#### Acceptance Criteria

1. WHEN o jogador toca na tela THEN o pássaro SHALL responder imediatamente
2. WHEN múltiplos toques são feitos rapidamente THEN cada toque SHALL ser registrado
3. WHEN o jogo está pausado THEN os controles SHALL ser desabilitados
4. IF o jogador usa mouse (desktop) THEN cliques SHALL funcionar como toques
