# Guía de Creación de Niveles

Esta guía explica cómo crear nuevos niveles de forma estandarizada, cambiando solo las temáticas visuales.

---

## 1. Estructura de un Nivel

Cada nivel se define con un **Resource** (archivo `.tres`) que contiene:

```
data/level_[nombre].tres
```

### 1.1 Propiedades del LevelData

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `level_name` | String | Nombre mostrado en UI |
| `scroll_direction` | Vector2 | Dirección del scroll (-1,0), (1,0), (0,-1), (0,1) |
| `base_speed` | float | Velocidad base del mundo |
| `gravity_enabled` | bool | Si el jugador tiene gravedad |
| `base_distance` | float | Distancia base del nivel |
| `distance_scale_per_xp` | float | Incremento por nivel de dificultad |
| `bg_color` | Color | Color de fondo |
| `ground_color` | Color | Color del suelo/paredes |
| `obstacle_color` | Color | Color de obstáculos (si usan ColorRect) |
| `coin_value` | int | XP por moneda |
| `level_complete_bonus` | int | XP al completar |

---

## 2. Tipos de Niveles

### 2.1 Horizontal (Plataformas)

```gdscript
scroll_direction = Vector2(-1, 0)  # o (1, 0)
gravity_enabled = true
```

- Jugador corre horizontalmente
- Puede saltar (swipe up) y agacharse (swipe down)
- Obstáculos en el suelo o aire

### 2.2 Vertical (Endless)

```gdscript
scroll_direction = Vector2(0, -1)  # o (0, 1)
gravity_enabled = false
```

- Jugador se mueve en 3 carriles
- Esquiva con swipe left/right
- Obstáculos en los carriles

---

## 3. Crear un Nivel Nuevo

### Paso 1: Crear el Resource

Copiar un `.tres` existente y modificar:

```bash
cp data/level_rio.tres data/level_[nuevo].tres
```

### Paso 2: Editar Propiedades

Abrir en Godot o editar el archivo:

```tres
[gd_resource type="Resource" script_class="LevelData" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/level_data.gd" id="1"]

[resource]
script = ExtResource("1")
level_name = "Mi Nivel"
scroll_direction = Vector2(-1, 0)
base_speed = 350.0
gravity_enabled = true
base_distance = 1000.0
distance_scale_per_xp = 50.0
bg_color = Color(0.2, 0.3, 0.5)
ground_color = Color(0.4, 0.3, 0.2)
obstacle_color = Color(0.8, 0.2, 0.2)
coin_value = 10
level_complete_bonus = 50
```

### Paso 3: Registrar en TransitionManager

Editar `scripts/transition_manager.gd`:

```gdscript
const LEVEL_ORDER: Array[String] = [
    "res://data/level_rio.tres",
    "res://data/level_plataforma.tres",
    "res://data/level_hellevator.tres",
    "res://data/level_abduccion.tres",
    "res://data/level_[nuevo].tres",  # ← Agregar aquí
]
```

---

## 4. Personalizar Visuales (Tiles)

### 4.1 Cambiar Sprites de Obstáculos

Editar `scenes/obstacle.tscn`:

```
[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("res://assets/[tu_tileset]/tile_XXXX.png")
```

**O crear variantes por nivel:**

```gdscript
# En obstacle_spawner.gd
func _get_obstacle_texture() -> Texture2D:
    match _level_data.level_name:
        "Río": return preload("res://assets/kenney/Tiles/tile_0048.png")
        "Bosque": return preload("res://assets/custom/tree_obstacle.png")
        _: return preload("res://assets/kenney/Tiles/tile_0048.png")
```

### 4.2 Cambiar Sprite del Jugador

Similar, en `player.gd` o `player.tscn`.

### 4.3 Cambiar Fondo

Para fondos más complejos que un color:

1. Crear nodo `ParallaxBackground` en `level.tscn`
2. Agregar capas con texturas
3. Configurar motion_scale para efecto parallax

---

## 5. Checklist de Nuevo Nivel

- [ ] Crear archivo `data/level_[nombre].tres`
- [ ] Definir todas las propiedades
- [ ] Agregar a `LEVEL_ORDER` en TransitionManager
- [ ] (Opcional) Crear sprites temáticos
- [ ] (Opcional) Agregar música/sonidos
- [ ] Probar el nivel completo
- [ ] Verificar transiciones entrada/salida

---

## 6. Niveles de Ejemplo

### Nivel Fácil (Tutorial)

```tres
level_name = "Tutorial"
scroll_direction = Vector2(-1, 0)
base_speed = 250.0
gravity_enabled = true
base_distance = 500.0
distance_scale_per_xp = 20.0
```

### Nivel Difícil (Boss Rush)

```tres
level_name = "Boss Rush"
scroll_direction = Vector2(0, -1)
base_speed = 500.0
gravity_enabled = false
base_distance = 2000.0
distance_scale_per_xp = 100.0
```

---

## 7. Tips

1. **Testear velocidades**: base_speed muy alta = frustración
2. **Distancia balanceada**: 800-1500 es el sweet spot
3. **Colores contrastantes**: jugador debe destacar del fondo
4. **Transiciones suaves**: usar el mismo estilo visual entre niveles conectados

---

## 8. Estructura de Archivos Recomendada

```
data/
├── level_rio.tres
├── level_plataforma.tres
├── level_hellevator.tres
├── level_abduccion.tres
├── level_bosque.tres      # Ejemplo nuevo
└── level_volcán.tres      # Ejemplo nuevo

assets/
├── kenney/                 # Assets genéricos
├── bosque/                 # Assets temáticos
│   ├── bg_bosque.png
│   ├── ground_bosque.png
│   └── obstacle_arbol.png
└── volcan/
    ├── bg_volcan.png
    └── obstacle_roca.png
```
