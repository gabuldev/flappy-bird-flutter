# Design Document

## Overview

O jogo Flappy Bird será implementado em Flutter utilizando o CustomPainter para renderização 2D de alta performance. A arquitetura seguirá o padrão de separação de responsabilidades com game loop customizado, sistema de física simples e gerenciamento de estado reativo. O foco está em demonstrar as capacidades de renderização 2D do Flutter mantendo código limpo e performance otimizada.

## Architecture

### Core Components

```
FlappyBirdApp
├── GameScreen (StatefulWidget)
│   ├── GameController (Game Logic)
│   ├── GameRenderer (CustomPainter)
│   └── InputHandler (GestureDetector)
├── Models
│   ├── Bird
│   ├── Pipe
│   └── GameState
└── Utils
    ├── Physics
    └── Constants
```

### Game Loop Architecture

O jogo utilizará um game loop baseado em `Ticker` do Flutter para atualizações consistentes:

1. **Update Phase**: Atualiza posições, física e lógica do jogo
2. **Render Phase**: Desenha todos os elementos usando CustomPainter
3. **Input Phase**: Processa input do usuário de forma assíncrona

## Components and Interfaces

### GameController

```dart
class GameController {
  GameState gameState;
  Bird bird;
  List<Pipe> pipes;

  void update(double deltaTime);
  void handleInput();
  void reset();
  bool checkCollisions();
}
```

**Responsabilidades:**

- Gerenciar estado do jogo (playing, gameOver, paused)
- Coordenar atualizações de todos os objetos do jogo
- Detectar colisões entre bird e pipes
- Controlar spawn de novos pipes

### GameRenderer (CustomPainter)

```dart
class GameRenderer extends CustomPainter {
  GameController controller;

  void paint(Canvas canvas, Size size);
  void drawBird(Canvas canvas, Bird bird);
  void drawPipes(Canvas canvas, List<Pipe> pipes);
  void drawBackground(Canvas canvas, Size size);
  void drawUI(Canvas canvas, Size size);
}
```

**Responsabilidades:**

- Renderizar todos os elementos visuais do jogo
- Otimizar drawing calls para 60 FPS
- Implementar efeitos visuais (paralaxe, animações)
- Gerenciar recursos gráficos

### Bird Model

```dart
class Bird {
  double x, y;
  double velocityY;
  double rotation;
  BirdState state; // flying, falling, dead

  void update(double deltaTime);
  void jump();
  void applyGravity(double deltaTime);
  Rect getBounds();
}
```

**Responsabilidades:**

- Física do pássaro (gravidade, pulo)
- Animação de batida de asas
- Rotação baseada na velocidade
- Detecção de bounds para colisão

### Pipe Model

```dart
class Pipe {
  double x;
  double topHeight, bottomHeight;
  double gapSize;
  bool scored;

  void update(double deltaTime);
  bool isOffScreen();
  List<Rect> getBounds(); // top and bottom pipe bounds
}
```

**Responsabilidades:**

- Movimento horizontal dos canos
- Definir gap entre canos superior e inferior
- Tracking se o jogador já pontuou neste pipe

## Data Models

### GameState

```dart
enum GameStatus { menu, playing, gameOver, paused }

class GameState {
  GameStatus status;
  int score;
  int highScore;
  double gameSpeed;

  void reset();
  void incrementScore();
  void updateHighScore();
}
```

### Physics System

```dart
class Physics {
  static const double gravity = 980.0; // pixels/second²
  static const double jumpVelocity = -350.0; // pixels/second
  static const double terminalVelocity = 500.0;
  static const double pipeSpeed = 200.0; // pixels/second

  static bool checkRectCollision(Rect a, Rect b);
  static double applyGravity(double velocity, double deltaTime);
}
```

## Error Handling

### Performance Monitoring

- **Frame Rate Monitoring**: Detectar drops de FPS e ajustar qualidade
- **Memory Management**: Cleanup de pipes off-screen automaticamente
- **Resource Loading**: Fallbacks para assets que falharem ao carregar

### Game State Recovery

```dart
class ErrorHandler {
  static void handleGameCrash(Exception e) {
    // Log error
    // Reset game to safe state
    // Show user-friendly message
  }

  static void handleRenderError(Exception e) {
    // Fallback to simpler rendering
    // Maintain game functionality
  }
}
```

### Input Validation

- Ignorar inputs durante transições de estado
- Prevenir spam de inputs que podem quebrar física
- Validar bounds antes de aplicar transformações

## Testing Strategy

### Unit Tests

```dart
// Physics Tests
test('bird applies gravity correctly', () {
  // Test gravity application over time
});

test('collision detection works accurately', () {
  // Test various collision scenarios
});

// Game Logic Tests
test('score increments when passing pipe', () {
  // Test scoring mechanism
});

test('game resets to initial state', () {
  // Test reset functionality
});
```

### Widget Tests

```dart
testWidgets('game responds to tap input', (tester) async {
  // Test input handling
});

testWidgets('game over screen shows correct score', (tester) async {
  // Test UI state transitions
});
```

### Integration Tests

```dart
testWidgets('complete game flow works', (tester) async {
  // Test full game cycle: start -> play -> game over -> restart
});
```

### Performance Tests

- **Frame Rate Tests**: Verificar 60 FPS consistente
- **Memory Tests**: Verificar que não há vazamentos
- **Stress Tests**: Testar com muitos pipes na tela

## Rendering Optimizations

### CustomPainter Optimizations

1. **Dirty Region Updates**: Apenas redesenhar áreas que mudaram
2. **Object Pooling**: Reutilizar objetos Pipe para evitar garbage collection
3. **Batch Drawing**: Agrupar drawing calls similares
4. **Asset Caching**: Cache de paints e paths reutilizáveis

### Animation Strategy

```dart
class AnimationManager {
  late AnimationController birdController;
  late Animation<double> birdAnimation;

  void setupAnimations() {
    // Bird wing flap animation
    // Background parallax animation
    // UI transition animations
  }
}
```

## Platform Considerations

### Mobile Optimizations

- Touch input com área de toque generosa
- Orientação portrait fixa
- Otimizações para diferentes densidades de tela

### Desktop Support

- Mouse click equivalente a touch
- Keyboard input (spacebar para pular)
- Window resizing handling

### Performance Targets

- **Mobile**: 60 FPS em dispositivos mid-range
- **Desktop**: 60 FPS consistente
- **Memory**: < 50MB usage durante gameplay
- **Battery**: Otimizado para não drenar bateria rapidamente
