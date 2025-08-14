# Implementation Plan

- [x] 1. Setup projeto Flutter e estrutura básica

  - Criar novo projeto Flutter com configurações iniciais
  - Configurar estrutura de diretórios (models, screens, utils)
  - Adicionar dependências necessárias no pubspec.yaml
  - _Requirements: 5.1, 6.4_

- [x] 2. Implementar modelos de dados fundamentais

  - [x] 2.1 Criar modelo Bird com física básica

    - Implementar classe Bird com propriedades de posição e velocidade
    - Adicionar métodos para jump(), applyGravity() e update()
    - Implementar getBounds() para detecção de colisão
    - Criar testes unitários para física do Bird
    - _Requirements: 1.1, 1.2, 1.4_

  - [x] 2.2 Criar modelo Pipe para obstáculos

    - Implementar classe Pipe com posição e dimensões
    - Adicionar lógica de movimento horizontal
    - Implementar getBounds() para colisão com top e bottom pipes
    - Adicionar flag 'scored' para tracking de pontuação
    - Criar testes unitários para movimento e bounds dos Pipes
    - _Requirements: 2.1, 2.2, 2.5_

  - [x] 2.3 Implementar GameState para gerenciamento de estado
    - Criar enum GameStatus e classe GameState
    - Implementar métodos reset(), incrementScore() e updateHighScore()
    - Adicionar persistência de high score usando SharedPreferences
    - Criar testes unitários para gerenciamento de estado
    - _Requirements: 3.1, 3.4, 4.3_

- [x] 3. Criar sistema de física e constantes

  - [x] 3.1 Implementar classe Physics com constantes do jogo
    - Definir constantes de gravidade, velocidade de pulo e velocidade dos pipes
    - Implementar função checkRectCollision() para detecção de colisões
    - Adicionar função applyGravity() para física do bird
    - Criar testes unitários para todas as funções de física
    - _Requirements: 1.2, 1.4, 2.4_

- [x] 4. Desenvolver GameController para lógica central

  - [x] 4.1 Implementar GameController básico

    - Criar classe GameController com gerenciamento de Bird e lista de Pipes
    - Implementar método update() para atualizar todos os objetos do jogo
    - Adicionar lógica de spawn de novos pipes em intervalos regulares
    - Implementar método reset() para reinicializar o jogo
    - _Requirements: 2.1, 2.3, 4.3_

  - [x] 4.2 Adicionar detecção de colisões e game over
    - Implementar método checkCollisions() entre bird e pipes
    - Adicionar verificação de bounds da tela para o bird
    - Implementar lógica de game over quando colisão é detectada
    - Adicionar sistema de pontuação quando bird passa por pipes
    - Criar testes unitários para detecção de colisões
    - _Requirements: 1.4, 2.4, 2.5, 3.2_

- [x] 5. Implementar sistema de renderização com CustomPainter

  - [x] 5.1 Criar GameRenderer básico

    - Implementar classe GameRenderer extends CustomPainter
    - Adicionar método paint() com canvas e size
    - Implementar drawBird() para renderizar o pássaro
    - Adicionar drawPipes() para renderizar obstáculos
    - _Requirements: 5.1, 5.2_

  - [x] 5.2 Adicionar renderização de background e UI

    - Implementar drawBackground() com efeito de paralaxe
    - Adicionar drawUI() para mostrar pontuação atual
    - Implementar renderização de tela de game over
    - Otimizar rendering para manter 60 FPS consistente
    - _Requirements: 3.3, 4.1, 5.1, 5.4_

  - [x] 5.3 Implementar animações do bird
    - Adicionar animação de batida de asas usando AnimationController
    - Implementar rotação do bird baseada na velocidade vertical
    - Criar smooth transitions entre estados de animação
    - Testar animações em diferentes frame rates
    - _Requirements: 5.3_

- [x] 6. Criar tela principal do jogo com input handling

  - [x] 6.1 Implementar GameScreen widget

    - Criar StatefulWidget GameScreen com Ticker para game loop
    - Integrar GameController e GameRenderer
    - Adicionar GestureDetector para capturar toques na tela
    - Implementar game loop usando TickerProvider
    - _Requirements: 1se isssvoce.1, 6.1, 6.2_

  - [x] 6.2 Adicionar controles responsivos
    - Implementar handleInput() no GameController para processar toques
    - Adicionar suporte para múltiplos toques rápidos
    - Implementar controles de mouse para desktop (clique = toque)
    - Adicionar controle de teclado (spacebar) para desktop
    - Criar testes de widget para input handling
    - _Requirements: 6.1, 6.2, 6.4_

- [x] 7. Implementar tela de game over e restart

  - [x] 7.1 Criar UI de game over

    - Implementar overlay de game over com pontuação final
    - Adicionar botão de restart com styling apropriado
    - Mostrar high score na tela de game over
    - Implementar transições suaves entre estados do jogo
    - _Requirements: 4.1, 4.2_

  - [x] 7.2 Adicionar funcionalidade de restart
    - Conectar botão de restart ao método reset() do GameController
    - Implementar transição suave de game over para jogo ativo
    - Resetar todas as animações e estados visuais
    - Testar ciclo completo: jogo -> game over -> restart
    - _Requirements: 4.2, 4.3, 4.4_

- [x] 8. Otimizações de performance e polimento

  - [x] 8.1 Implementar object pooling para pipes

    - Criar sistema de reutilização de objetos Pipe
    - Implementar cleanup automático de pipes off-screen
    - Otimizar garbage collection reduzindo alocações desnecessárias
    - Testar performance com muitos pipes na tela
    - _Requirements: 5.1, 5.5_

  - [x] 8.2 Adicionar otimizações de rendering
    - Implementar dirty region updates no CustomPainter
    - Adicionar caching de paints e paths reutilizáveis
    - Otimizar drawing calls agrupando operações similares
    - Implementar fallback para dispositivos com performance limitada
    - _Requirements: 5.1, 5.5_

- [-] 9. Testes de integração e validação final

  - [x] 9.1 Criar testes de integração completos

    - Implementar teste de fluxo completo do jogo
    - Testar transições entre todos os estados do jogo
    - Validar que todos os requirements são atendidos
    - Testar em diferentes tamanhos de tela e orientações
    - _Requirements: All requirements_

  - [ ] 9.2 Testes de performance e otimização final
    - Executar testes de frame rate em dispositivos target
    - Validar uso de memória durante gameplay prolongado
    - Testar responsividade de input em diferentes cenários
    - Fazer ajustes finais baseados nos resultados dos testes
    - _Requirements: 5.1, 5.5, 6.1, 6.2_
