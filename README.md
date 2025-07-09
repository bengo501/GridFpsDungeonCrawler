# Grid FPS Dungeon Crawler

Um jogo de RPG em primeira pessoa com movimento baseado em grid, desenvolvido em Godot 4.4.

## Funcionalidades Implementadas

### Sistema de Batalha
- Sistema de turnos com jogador e inimigos
- Habilidades mágicas com custo de MP
- Sistema de itens utilizáveis em batalha
- Possibilidade de fuga das batalhas
- Diferentes tipos de inimigos (Goblin, Orc, Esqueleto)

### Sistema de Progressão
- Sistema de níveis com experiência
- Aprendizado automático de habilidades por nível
- Barras de vida e MP
- Sistema de ouro

### Sistema de Interação
- Objetos interagíveis (baús, NPCs)
- Sistema de diálogo com efeito de digitação
- NPCs com diferentes funcionalidades (comerciantes, missões)
- Baús com recompensas e sistema de chaves

### Sistema de Save/Load
- Múltiplos slots de save
- Nomes personalizados para saves
- Persistência de progresso do jogador
- Informações detalhadas dos saves

### Interface de Usuário
- Menu principal completo
- HUD de exploração com barras de status
- Interface de batalha com opções
- Menus de pausa e opções
- Sistema de diálogo interativo

### Controles
- **WASD/Setas**: Movimento
- **Q/E**: Rotação
- **F**: Interagir
- **ESC**: Pausar
- **Enter**: Confirmar diálogos
- **ESC**: Cancelar/Voltar

## Estrutura do Projeto

```
├── managers/           # Gerenciadores globais (autoload)
│   ├── UIManager.gd
│   ├── GameManager.gd
│   ├── BattleManager.gd
│   ├── SaveManager.gd
│   ├── GameStateManager.gd
│   └── SceneManager.gd
├── scenes/            # Cenas principais
│   ├── ui/           # Interfaces de usuário
│   └── MainMenu.gd
├── scripts/          # Scripts de gameplay
│   ├── Player.gd
│   ├── Enemy.gd
│   ├── Interactable.gd
│   ├── Chest.gd
│   └── NPC.gd
└── README.md
```

## Sistemas de Jogo

### Habilidades Disponíveis
- **Bola de Fogo** (Nível 3): 25 dano, 10 MP
- **Cura** (Nível 5): Restaura 30 HP, 15 MP
- **Raio** (Nível 7): 35 dano, 20 MP

### Itens Disponíveis
- **Poção de Vida**: Restaura 50 HP
- **Poção de Mana**: Restaura 30 MP
- **Poção de Força**: Aumenta dano por 3 turnos

### Collision Layers
- Layer 1: Player
- Layer 2: Interactable
- Layer 4: Walls
- Layer 8: Enemies

## Como Jogar

1. **Exploração**: Use WASD para se mover pelo mundo em grid
2. **Interação**: Pressione F próximo a objetos para interagir
3. **Batalha**: Quando encontrar inimigos, escolha entre atacar, usar habilidades, itens ou fugir
4. **Progressão**: Derrote inimigos para ganhar experiência e subir de nível
5. **Save**: Use o menu de pausa para salvar seu progresso

## Desenvolvimento

Este projeto foi desenvolvido usando:
- **Engine**: Godot 4.4
- **Linguagem**: GDScript
- **Rendering**: Forward Plus
- **Resolução**: 1280x720

## Funcionalidades Futuras

- Sistema de inventário visual
- Mais tipos de inimigos e chefes
- Sistema de missões completo
- Loja funcional com NPCs
- Múltiplas áreas/dungeons
- Sistema de equipamentos
- Efeitos sonoros e música 