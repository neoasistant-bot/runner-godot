# 🎮 Runner — Godot (Android)

Un juego **runner 2D** para Android, desarrollado en [Godot Engine](https://godotengine.org/), inspirado en la estética y el mundo de **Terraria**.

---

## 🕹️ ¿Qué es este juego?

Un juego de tipo *endless runner* lateral donde el personaje corre automáticamente a través de un mundo generado con la estética pixel art de Terraria. El jugador debe saltar, esquivar obstáculos y sobrevivir el mayor tiempo posible.

### Características planeadas

- 🌍 Mundo generado proceduralmente con estética Terraria
- 🧱 Sprites pixel art (bloques, personajes, enemigos)
- 📱 Diseñado para Android (controles táctiles)
- 💀 Mecánica de muerte y reinicio rápido
- 🏆 Sistema de puntuación (distancia recorrida)
- 🎵 Música y efectos de sonido chiptune

---

## 🛠️ Tecnologías

| Herramienta | Uso |
|---|---|
| [Godot 4.x](https://godotengine.org/) | Motor del juego |
| GDScript | Lenguaje de scripting |
| Android Export Template | Build para Android |
| Aseprite / IA | Sprites pixel art |

---

## 📁 Estructura del proyecto

```
runner-godot/
├── assets/
│   ├── sprites/       # Personajes, tiles, enemigos
│   ├── music/         # Música de fondo
│   └── sfx/           # Efectos de sonido
├── scenes/
│   ├── main.tscn      # Escena principal
│   ├── player.tscn    # Personaje
│   └── world.tscn     # Mundo generado
├── scripts/
│   ├── player.gd      # Lógica del jugador
│   ├── world_gen.gd   # Generación del mundo
│   └── score.gd       # Sistema de puntuación
├── project.godot      # Configuración del proyecto
└── README.md
```

---

## 🚀 Estado del proyecto

> 🟡 **En desarrollo inicial** — configurando estructura y herramientas

---

## 🤝 Colaboradores

- **Martín** — Creador y diseñador del juego
- **Neo** (IA assistant) — Apoyo técnico y automatización

---

## 📄 Licencia

Proyecto personal. Todos los derechos reservados.
