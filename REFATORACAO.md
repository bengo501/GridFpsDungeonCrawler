# Refatoração do Projeto - Grid FPS Dungeon Crawler

## Resumo das Mudanças

### Arquivos Removidos (Duplicados/Não Utilizados)
- `Player.gd` (raiz) - Arquivo duplicado, mantido apenas `scripts/Player.gd`
- `scenes/Player.gd` - Arquivo duplicado com implementação diferente
- `scenes/Player.tscn` - Arquivo duplicado, mantido apenas `Player.tscn` (raiz)
- `Grid.gd` (raiz) - Arquivo duplicado, criado novo `scenes/Grid.gd`
- `TestScene.gd` - Arquivo de teste temporário

### Arquivos UID Órfãos Removidos
- Todos os arquivos `.uid` órfãos foram removidos para limpar o projeto
- Incluindo arquivos de managers, scripts e scenes

### Correções Implementadas

#### 1. GameStateManager.gd
- Adicionado `PAUSE_MENU` ao enum `GameState` para corrigir erro de linter

#### 2. Player.gd (scripts/)
- Corrigido uso de `PAUSE_MENU` para `PAUSED`
- Implementado sistema de movimentação baseado na direção do jogador
- Adicionado sistema de detecção de colisão robusto
- Movimento relativo: W/S para frente/trás, A/D para esquerda/direita
- Rotação: Q/E para girar esquerda/direita

#### 3. Grid.gd (scenes/)
- Criado novo sistema de grid funcional
- Implementado geração procedural de dungeon
- Adicionado sistema de detecção de paredes
- Métodos para conversão entre coordenadas de grid e mundo

#### 4. Collision Layers
- **Player**: Layer 2, Mask 1
- **Walls**: Layer 1, Mask 0
- Configuração adequada para detecção de colisão

#### 5. Main.tscn
- Atualizado para usar `scenes/Grid.gd`
- Removido script de teste
- Configuração correta das referências

### Sistema de Movimentação

#### Controles Implementados:
- **W/Seta para cima**: Move para frente (direção que o jogador está olhando)
- **S/Seta para baixo**: Move para trás (direção oposta)
- **A/Seta para esquerda**: Move para a esquerda (relativo à direção do jogador)
- **D/Seta para direita**: Move para a direita (relativo à direção do jogador)
- **Q**: Gira para a esquerda
- **E**: Gira para a direita
- **F**: Interagir
- **ESC**: Pausar

#### Funcionalidades:
- Movimento baseado em grid (2x2 unidades)
- Rotação suave com interpolação
- Detecção de colisão com paredes
- Sistema de direção relativa ao jogador
- Integração com GameManager para tracking de posição

### Estrutura Final do Projeto

```
├── managers/           # Gerenciadores globais (autoload)
│   ├── UIManager.gd
│   ├── GameManager.gd
│   ├── BattleManager.gd
│   ├── SaveManager.gd
│   ├── GameStateManager.gd
│   └── SceneManager.gd
├── scenes/            # Cenas e scripts de scene
│   ├── ui/           # Interfaces de usuário
│   ├── Grid.gd       # Sistema de grid principal
│   └── [outros arquivos de scene]
├── scripts/          # Scripts de gameplay
│   ├── Player.gd     # Script principal do jogador
│   ├── Enemy.gd
│   ├── Interactable.gd
│   ├── Chest.gd
│   └── NPC.gd
├── Player.tscn       # Cena do jogador
├── Main.tscn         # Cena principal
├── Wall.tscn         # Cena de parede
├── Floor.tscn        # Cena de chão
└── README.md         # Documentação do projeto
```

### Próximos Passos

1. **Testar o sistema de movimentação** no editor do Godot
2. **Implementar sistema de colisão mais avançado** se necessário
3. **Adicionar efeitos visuais** para movimento e rotação
4. **Implementar sistema de interação** com objetos
5. **Adicionar sistema de save/load** para posição do jogador

### Problemas Conhecidos

- Sistema de colisão pode precisar de ajustes finos
- Alguns debug prints ainda presentes para troubleshooting
- Necessário testar integração com outros sistemas do jogo

### Como Testar

1. Abra o projeto no Godot 4.4
2. Execute a cena `Main.tscn`
3. Use WASD para movimento e Q/E para rotação
4. Observe os logs no console para debug se necessário 