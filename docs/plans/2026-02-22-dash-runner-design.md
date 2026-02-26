# Dash Runner — Game Design Document

**Date:** 2026-02-22
**Status:** Approved
**Platform:** Android
**Engine:** Godot 4.x
**Genre:** Endless Runner 2D (side-scrolling)

---

## Concept

An endless 2D side-scrolling runner built in Godot for Android. The player runs infinitely to the right, using swipe gestures to dodge obstacles, while traversing themed zones that vary in difficulty and visual style.

The primary goal is learning Godot game development.

---

## Controls

| Input      | Action                                   |
|------------|------------------------------------------|
| Swipe Up   | Jump                                     |
| Swipe Down | Crouch (slide under aerial obstacles)    |
| Tap        | Special action (TBD — reserved for future)|

---

## Core Mechanics

### Movement
- The player character is stationary horizontally
- The world scrolls to the left, creating the illusion of running
- Player only moves vertically (jump/crouch)

### Obstacles
- **Ground obstacles:** Must jump over (boxes, rocks, barriers)
- **Aerial obstacles:** Must crouch under (stalactites, hanging objects)
- **Combinations:** Sequences requiring precise timing

### Scoring
- Distance traveled (primary score)
- Coins collected (bonus score)
- High score persisted locally via `FileAccess`

### Difficulty Progression
- Base speed increases every ~10 seconds
- Zone difficulty escalates with distance
- Obstacle spacing decreases over time

---

## Zone System (Data-Driven Procedural Generation)

The world is divided into chunks. Each chunk belongs to a **zone type** that defines sprites, difficulty, and behavior.

### Zone Definitions

| Zone         | Ground Tiles | Background      | Obstacles                    | Obstacle Freq | Coin Freq  | Speed Mod |
|--------------|-------------|-----------------|------------------------------|---------------|------------|-----------|
| Safe Plains  | Grass       | Blue sky/clouds | Small rock, bush             | LOW           | HIGH       | 1.0x      |
| Danger Cave  | Stone       | Dark cave       | Stalactite, spike, big rock  | HIGH          | LOW        | 1.3x      |
| Sky Bonus    | Clouds      | Sunset sky      | Bird, lightning              | MEDIUM        | VERY HIGH  | 1.1x      |

### Zone Scheduling Rules
1. Always start with "Safe Plains" (implicit tutorial)
2. Alternate safe → danger → safe → danger
3. Introduce harder zones as distance increases
4. Gradual visual transitions between zones (no hard cuts)

### Spawner Logic
- Obstacles spawn off-screen (right)
- Destroyed when off-screen (left), or recycled via object pooling
- Obstacle type randomly selected from zone's obstacle list (weighted)
- Spacing determined by zone's frequency settings

---

## Godot Scene Architecture

```
Game (Node2D)
├── Player (CharacterBody2D)
│   ├── Sprite2D
│   ├── CollisionShape2D
│   └── AnimationPlayer (run, jump, crouch, die)
├── World (Node2D)
│   ├── Ground (StaticBody2D — infinite scrolling tiles)
│   ├── ObstacleSpawner (Node2D)
│   └── CoinSpawner (Node2D)
├── ZoneManager (Node — handles zone transitions)
├── UI (CanvasLayer)
│   ├── ScoreLabel
│   └── PauseButton
├── MainMenu (CanvasLayer)
└── GameOverScreen (CanvasLayer)
```

### Key Technical Decisions
- **CharacterBody2D** for player (built-in physics for gravity/jump)
- **StaticBody2D** for ground (simple collision)
- **Area2D** for coins and obstacle triggers
- **AnimationPlayer** for all sprite animations
- **InputMap** configured for touch swipe detection

---

## Visual Style & Assets

### Style: Pixel Art (asset packs)

**Sources:**
- Kenney.nl (Pixel Platformer pack)
- itch.io (free pixel art platformer assets)
- OpenGameArt.org (CC0 assets)

**Required Assets:**
- Player character sprite sheet (32x32px): run, jump, crouch, die
- Tileset per zone (ground + background)
- Obstacle sprites per zone
- Coin sprite (animated)
- UI font (pixel art style)

Assets are placeholders — can be replaced with custom art later.

---

## Screens

### 1. Main Menu
- Game title
- "Play" button
- High score display

### 2. Gameplay
- Scrolling world with player
- Score counter (top)
- Current zone indicator (subtle)
- Pause button

### 3. Game Over
- Final score
- High score (with "NEW!" if beaten)
- "Retry" button
- "Menu" button

---

## Target Platform

- **Android only**
- Godot 4.x with Android export template
- Touch input (swipe gestures)
- Target resolution: 1080x1920 (portrait) or 1920x1080 (landscape — TBD)
- Minimum API level: Android 7.0+

---

## Future Considerations (Post-MVP)

- Tap action: special ability or attack mechanic
- Power-ups (shield, magnet, slow-mo)
- Character selection / unlockables
- More zone types
- Sound effects and music
- Play Store publication
