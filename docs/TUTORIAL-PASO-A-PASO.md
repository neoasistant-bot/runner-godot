# Dash Runner — Tutorial Paso a Paso

> Guia completa para construir un Endless Runner 2D en Godot 4.x
> Seguila a tu ritmo. Cada seccion produce algo visible y jugable.

---

## Antes de empezar: Instalacion

### 1. Descargar Godot 4.4+

1. Ir a https://godotengine.org/download
2. Descargar la version **Standard** para Windows (64-bit)
3. Extraer en una carpeta conocida, por ejemplo `C:\Tools\Godot\`
4. No requiere instalacion — es un ejecutable portable

### 2. Descargar Assets (Kenney Pixel Platformer)

1. Ir a https://kenney.nl/assets/pixel-platformer
2. Click "Download" (es gratis)
3. Extraer el contenido en: `C:\Users\Marti\Documents\proyectos\dash-runner\assets\kenney\`

> **Nota:** Los assets los usamos en la Tarea 12. Las primeras tareas usan rectangulos de colores como placeholder. No te preocupes si no los descargaste todavia.

---

## TAREA 1: Crear el Proyecto en Godot

**Resultado:** Un proyecto vacio que corre sin errores.

### Paso 1.1: Crear proyecto nuevo

1. Abrir Godot
2. Click **"New Project"**
3. En "Project Path", navegar a: `C:\Users\Marti\Documents\proyectos\dash-runner\`
4. Project Name: `Dash Runner`
5. Renderer: seleccionar **"Mobile"** (optimizado para celular)
6. Click **"Create & Edit"**

### Paso 1.2: Configurar la pantalla

1. Ir a **Project → Project Settings** (menu superior)
2. En el buscador escribir `window`
3. Cambiar estos valores:
   - `Display > Window > Size > Viewport Width` = **1920**
   - `Display > Window > Size > Viewport Height` = **1080**
   - `Display > Window > Stretch > Mode` = **canvas_items**
   - `Display > Window > Stretch > Aspect` = **keep_height**
4. Buscar `orientation`
   - `Display > Window > Handheld > Orientation` = **landscape**
5. Cerrar la ventana de settings

### Paso 1.3: Crear carpetas

En el panel **FileSystem** (abajo a la izquierda):
1. Click derecho en `res://` → **New Folder** → `scenes`
2. Click derecho en `res://` → **New Folder** → `scripts`
3. Click derecho en `res://` → **New Folder** → `assets`
4. Click derecho en `res://` → **New Folder** → `data`

Tu estructura deberia verse asi:
```
res://
├── assets/
├── data/
├── scenes/
└── scripts/
```

### Paso 1.4: Crear la escena principal

1. **Scene → New Scene** (menu superior)
2. En el panel izquierdo, click **"Other Node"**
3. Buscar `Node2D` → seleccionarlo → click **Create**
4. En el panel **Scene** (arriba a la izquierda), el nodo se llama "Node2D"
5. **Doble click** en el nombre → renombrar a **"Game"**
6. **Ctrl+S** → guardar en `res://scenes/game.tscn`

### Paso 1.5: Agregar nodos hijos a Game

Con "Game" seleccionado:
1. Click el boton **"+"** (Add Child Node) arriba del panel Scene
2. Buscar `Node2D` → Create → renombrar a **"World"**
3. Seleccionar "Game" de nuevo → "+" → buscar `CanvasLayer` → Create → renombrar a **"UI"**

Tu arbol de escena deberia verse asi:
```
Game (Node2D)
├── World (Node2D)
└── UI (CanvasLayer)
```

### Paso 1.6: Establecer como escena principal

1. Ir a **Project → Project Settings**
2. Buscar `main scene`
3. `Application > Run > Main Scene` = `res://scenes/game.tscn`
4. Cerrar settings

### Paso 1.7: PROBAR

Presionar **F5** (o el boton ▶ arriba a la derecha).

**Esperado:** Se abre una ventana gris vacia en modo landscape (1920x1080). Sin errores.

Cerrar la ventana del juego.

### Paso 1.8: Inicializar Git

Abrir una terminal en la carpeta del proyecto y ejecutar:

```bash
cd C:\Users\Marti\Documents\proyectos\dash-runner
git init
```

Crear un archivo `.gitignore` en la raiz del proyecto con este contenido:

```
# Godot
.godot/
*.tmp
*.log
export_presets.cfg

# OS
Thumbs.db
.DS_Store
```

Hacer el primer commit:
```bash
git add -A
git commit -m "feat: initial Godot project setup"
```

**TAREA 1 COMPLETADA** ✓

---

## TAREA 2: El Personaje (Player)

**Resultado:** Un cuadrado azul que cae con gravedad y aterriza en un piso verde.

### Paso 2.1: Crear la escena del Player

1. **Scene → New Scene**
2. "Other Node" → buscar `CharacterBody2D` → Create
3. Renombrar a **"Player"**
4. **Ctrl+S** → guardar en `res://scenes/player.tscn`

### Paso 2.2: Agregar visual (placeholder)

Con "Player" seleccionado:
1. "+" → buscar `ColorRect` → Create
2. En el panel **Inspector** (derecha):
   - `Size` → `x: 32, y: 56`
   - `Position` → `x: -16, y: -56` (para centrar respecto al origen)
   - `Color` → elegir azul

### Paso 2.3: Agregar colision

Con "Player" seleccionado:
1. "+" → buscar `CollisionShape2D` → Create
2. En el Inspector, en **Shape** → click `<empty>` → **New RectangleShape2D**
3. Click en el RectangleShape2D que aparece → `Size` → `x: 28, y: 54`
4. Posicionar el CollisionShape2D en `Position → y: -28` (centrado verticalmente)

Tu escena del Player:
```
Player (CharacterBody2D)
├── ColorRect (azul, 32x56)
└── CollisionShape2D (RectangleShape2D 28x54)
```

### Paso 2.4: Escribir el script del Player

1. Seleccionar el nodo **"Player"**
2. Click en el icono de **scroll** (📜) arriba del panel Scene → "Attach Script"
3. Path: `res://scripts/player.gd`
4. Click **Create**
5. Reemplazar TODO el contenido con:

```gdscript
extends CharacterBody2D

const GRAVITY: float = 1200.0

func _physics_process(delta: float) -> void:
    # Aplicar gravedad si no esta en el piso
    if not is_on_floor():
        velocity.y += GRAVITY * delta

    move_and_slide()
```

6. **Ctrl+S** para guardar el script

### Paso 2.5: Agregar piso al juego

1. Abrir `scenes/game.tscn` (doble click en FileSystem)
2. Seleccionar **"World"**
3. "+" → `StaticBody2D` → Create → renombrar a **"Ground"**
4. Con "Ground" seleccionado:
   - "+" → `CollisionShape2D` → Create
   - En Inspector > Shape → **New WorldBoundaryShape2D**
   - Esto crea un piso infinito horizontal
5. Mover "Ground" a `Position → y: 500` en el Inspector

6. Para darle visual al piso:
   - Seleccionar "Ground"
   - "+" → `ColorRect` → Create
   - `Size` → `x: 1920, y: 200`
   - `Position` → `x: 0, y: 0`
   - `Color` → verde oscuro

### Paso 2.6: Agregar el Player a la escena del juego

1. En `scenes/game.tscn`, seleccionar **"Game"** (nodo raiz)
2. Click derecho → **"Instantiate Child Scene"** (o Ctrl+Shift+A)
3. Seleccionar `res://scenes/player.tscn`
4. El Player aparece como hijo de Game
5. Mover el Player a `Position → x: 200, y: 300` (arriba del piso)

Tu arbol deberia verse asi:
```
Game (Node2D)
├── World (Node2D)
│   └── Ground (StaticBody2D)
│       ├── CollisionShape2D
│       └── ColorRect (verde)
├── Player (instancia de player.tscn)
└── UI (CanvasLayer)
```

### Paso 2.7: PROBAR

Presionar **F5**.

**Esperado:**
- El cuadrado azul (Player) aparece arriba
- Cae con gravedad
- Aterriza en el piso verde y se detiene
- No tiembla ni se hunde

Si el player cae a traves del piso, verifica que:
- El Ground tiene un CollisionShape2D con WorldBoundaryShape2D
- El Player tiene un CollisionShape2D con RectangleShape2D
- La posicion Y del Ground es 500

### Paso 2.8: Commit

```bash
git add scenes/player.tscn scripts/player.gd scenes/game.tscn
git commit -m "feat: player with gravity and ground collision"
```

**TAREA 2 COMPLETADA** ✓

---

## TAREA 3: Controles — Saltar con Swipe/Teclado

**Resultado:** El player salta cuando presionas Espacio/W/Arriba, o cuando haces swipe arriba en pantalla tactil.

### Paso 3.1: Configurar teclas en InputMap

1. **Project → Project Settings → Input Map** (tab arriba)
2. En el campo "Add New Action" escribir: `jump` → click **Add**
3. Click el **"+"** a la derecha de "jump"
   - **Key** → presionar **Espacio** → click OK
   - **"+"** otra vez → **Key** → presionar **W** → click OK
   - **"+"** otra vez → **Key** → presionar **Flecha Arriba** → click OK
4. Agregar otra accion: `crouch` → click Add
   - **"+"** → **Key** → presionar **S** → click OK
   - **"+"** → **Key** → presionar **Flecha Abajo** → click OK
5. Cerrar settings

### Paso 3.2: Crear el detector de swipe

1. En FileSystem, click derecho en `scripts/` → **New Script**
2. Nombre: `swipe_detector.gd`
3. Pegar este contenido:

```gdscript
extends Node

## Detecta gestos de swipe en pantalla tactil.
## Emite signals que otros nodos pueden escuchar.

signal swiped_up
signal swiped_down
signal tapped

const SWIPE_THRESHOLD: float = 50.0  # pixeles minimos para contar como swipe
const TAP_THRESHOLD: float = 20.0    # movimiento maximo para contar como tap

var _touch_start: Vector2 = Vector2.ZERO
var _touch_start_time: int = 0
var _is_touching: bool = false

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            # Dedo toca la pantalla
            _touch_start = event.position
            _touch_start_time = Time.get_ticks_msec()
            _is_touching = true
        else:
            # Dedo se levanta de la pantalla
            if _is_touching:
                _process_gesture(event.position)
                _is_touching = false

func _process_gesture(end_pos: Vector2) -> void:
    var diff: Vector2 = end_pos - _touch_start
    var duration: int = Time.get_ticks_msec() - _touch_start_time

    # Si se movio poco y fue rapido, es un tap
    if diff.length() < TAP_THRESHOLD and duration < 300:
        tapped.emit()
        return

    # Si el movimiento vertical es mayor que el horizontal, es un swipe vertical
    if abs(diff.y) > SWIPE_THRESHOLD and abs(diff.y) > abs(diff.x):
        if diff.y < 0:
            swiped_up.emit()   # Swipe hacia arriba
        else:
            swiped_down.emit() # Swipe hacia abajo
```

### Paso 3.3: Registrar como Autoload (singleton)

Los Autoloads son scripts que se cargan automaticamente y estan disponibles en TODO el juego.

1. **Project → Project Settings → Autoload** (tab arriba)
2. En Path, click el icono de carpeta → seleccionar `res://scripts/swipe_detector.gd`
3. El nombre se autocompleta como "SwipeDetector"
4. Click **Add**
5. Cerrar settings

### Paso 3.4: Actualizar player.gd con salto

Abrir `scripts/player.gd` y reemplazar TODO con:

```gdscript
extends CharacterBody2D

const GRAVITY: float = 1200.0
const JUMP_VELOCITY: float = -600.0  # negativo = hacia arriba

var _is_crouching: bool = false

func _ready() -> void:
    # Conectar las signals del swipe detector
    SwipeDetector.swiped_up.connect(_on_swipe_up)
    SwipeDetector.swiped_down.connect(_on_swipe_down)

func _physics_process(delta: float) -> void:
    # Aplicar gravedad
    if not is_on_floor():
        velocity.y += GRAVITY * delta

    # Controles de teclado (para testear en PC)
    if Input.is_action_just_pressed("jump") and is_on_floor():
        _jump()
    if Input.is_action_just_pressed("crouch") and is_on_floor():
        _crouch()

    move_and_slide()

func _jump() -> void:
    # Solo saltar si esta en el piso
    if is_on_floor():
        velocity.y = JUMP_VELOCITY

func _crouch() -> void:
    if is_on_floor():
        _is_crouching = true
        # Por ahora solo un flag, lo implementamos bien en Tarea 8

func _on_swipe_up() -> void:
    _jump()

func _on_swipe_down() -> void:
    _crouch()
```

### Paso 3.5: PROBAR

Presionar **F5**.

**Esperado:**
- Presionar **Espacio**, **W** o **Flecha Arriba** → el player salta
- El salto tiene un arco natural (sube y baja)
- No puede saltar en el aire (doble salto no existe)
- Aterriza suavemente en el piso

**Para probar swipe:** Necesitas correrlo en un celular o emulador Android. En PC funciona con el teclado.

### Paso 3.6: Commit

```bash
git add scripts/swipe_detector.gd scripts/player.gd project.godot
git commit -m "feat: swipe detection and jump input"
```

**TAREA 3 COMPLETADA** ✓

---

## TAREA 4: El Mundo se Mueve (Scroll Infinito)

**Resultado:** El piso se desplaza infinitamente hacia la izquierda, dando la ilusion de que el player corre.

### Concepto clave

> El player NO se mueve horizontalmente. El MUNDO se mueve hacia la izquierda.
> Esto es el patron estandar de todos los endless runners.

### Paso 4.1: Crear world_scroller.gd

Crear `scripts/world_scroller.gd`:

```gdscript
extends Node2D

## Controla la velocidad de scroll del mundo.
## Llama al metodo scroll() de todos sus hijos que lo tengan.

var scroll_speed: float = 300.0  # pixeles por segundo
var _base_speed: float = 300.0
var _speed_modifier: float = 1.0
var _is_running: bool = true

func _process(delta: float) -> void:
    if not _is_running:
        return

    var amount: float = scroll_speed * delta
    for child in get_children():
        if child.has_method("scroll"):
            child.scroll(amount)

func stop() -> void:
    _is_running = false

func increase_speed(amount: float) -> void:
    _base_speed += amount
    scroll_speed = _base_speed * _speed_modifier

func set_speed_modifier(modifier: float) -> void:
    _speed_modifier = modifier
    scroll_speed = _base_speed * _speed_modifier
```

### Paso 4.2: Crear ground_manager.gd

Crear `scripts/ground_manager.gd`:

```gdscript
extends Node2D

## Maneja los tiles del piso que se reciclan infinitamente.
## Cuando un tile sale por la izquierda, se reposiciona a la derecha.

var tile_width: float = 256.0
var ground_y: float = 0.0  # relativo al nodo padre

var _tiles: Array[ColorRect] = []
var _viewport_width: float

func _ready() -> void:
    _viewport_width = get_viewport_rect().size.x
    _spawn_initial_tiles()

func _spawn_initial_tiles() -> void:
    # Crear suficientes tiles para cubrir la pantalla + 2 extra
    var count: int = ceili(_viewport_width / tile_width) + 2
    for i in count:
        var tile := ColorRect.new()
        tile.size = Vector2(tile_width + 2, 100)  # +2 para evitar gaps
        tile.color = Color.DARK_GREEN
        tile.position = Vector2(i * tile_width, ground_y)
        _tiles.append(tile)
        add_child(tile)

func scroll(amount: float) -> void:
    for tile in _tiles:
        tile.position.x -= amount

        # Si el tile salio completamente por la izquierda, moverlo a la derecha
        if tile.position.x < -tile_width:
            var rightmost_x: float = _get_rightmost_x()
            tile.position.x = rightmost_x + tile_width

func _get_rightmost_x() -> float:
    var max_x: float = -INF
    for tile in _tiles:
        if tile.position.x > max_x:
            max_x = tile.position.x
    return max_x
```

### Paso 4.3: Reorganizar la escena del juego

Abrir `scenes/game.tscn`. Vamos a reorganizar:

1. Seleccionar el nodo **"World"** → click derecho → **Attach Script** → elegir `res://scripts/world_scroller.gd`

2. Con "World" seleccionado → "+" → `Node2D` → renombrar a **"GroundManager"**
   - Attach script: `res://scripts/ground_manager.gd`
   - En Inspector, posicion: `y: 500` (misma altura que el ground actual)

3. Ahora podes **eliminar el ColorRect** que estaba dentro de Ground (ya no lo necesitamos, GroundManager crea los tiles automaticamente)

El arbol queda:
```
Game (Node2D)
├── World (Node2D) ← con world_scroller.gd
│   └── GroundManager (Node2D) ← con ground_manager.gd, position y=500
├── Ground (StaticBody2D) ← MANTENER para la colision fisica
│   └── CollisionShape2D (WorldBoundaryShape2D)
├── Player
└── UI (CanvasLayer)
```

> **Importante:** El nodo "Ground" (StaticBody2D) se mantiene FUERA de World para que no se mueva. Es solo la linea invisible de colision. El visual del piso lo maneja GroundManager.

### Paso 4.4: PROBAR

Presionar **F5**.

**Esperado:**
- Los tiles verdes del piso se mueven hacia la izquierda continuamente
- Cuando un tile sale por la izquierda, reaparece por la derecha (loop infinito)
- El player sigue parado sobre el piso (la colision sigue funcionando)
- El player puede saltar normalmente

**Si el piso se ve con huecos:** Aumenta el `tile_width` o el `+2` en el tamanho del ColorRect.

### Paso 4.5: Commit

```bash
git add scripts/world_scroller.gd scripts/ground_manager.gd scenes/game.tscn
git commit -m "feat: infinite scrolling ground"
```

**TAREA 4 COMPLETADA** ✓

---

## TAREA 5: Obstaculos y Game Over

**Resultado:** Obstaculos rojos aparecen por la derecha. Si chocas, el juego se detiene.

### Paso 5.1: Crear el GameManager (Autoload)

Crear `scripts/game_manager.gd`:

```gdscript
extends Node

## Maneja el estado global del juego: score, game over, high score.

signal game_over
signal game_started
signal score_changed(new_score: int)

var is_playing: bool = false
var score: int = 0
var _distance: float = 0.0

func _process(delta: float) -> void:
    if is_playing:
        _distance += delta * 100.0  # ~100 puntos por segundo
        var new_score: int = int(_distance)
        if new_score != score:
            score = new_score
            score_changed.emit(score)

func start_game() -> void:
    score = 0
    _distance = 0.0
    is_playing = true
    game_started.emit()

func end_game() -> void:
    is_playing = false
    game_over.emit()

func add_coin() -> void:
    _distance += 10.0  # cada moneda suma 10 puntos
```

Registrar como Autoload:
1. **Project → Project Settings → Autoload**
2. Path: `res://scripts/game_manager.gd` → Name: **GameManager** → Add

### Paso 5.2: Crear la escena del Obstaculo

1. **Scene → New Scene**
2. "Other Node" → `Area2D` → Create → renombrar a **"Obstacle"**
3. Agregar hijos:
   - "+" → `ColorRect` → Create
     - `Size: x: 40, y: 60`
     - `Position: x: -20, y: -60`
     - `Color: rojo`
   - "+" → `CollisionShape2D` → Create
     - Shape → New RectangleShape2D → Size: `x: 36, y: 58`
     - `Position: y: -30`
4. **Ctrl+S** → guardar como `res://scenes/obstacle.tscn`

### Paso 5.3: Escribir obstacle.gd

Attach script al nodo "Obstacle":

```gdscript
extends Area2D

## Un obstaculo individual que se mueve con el mundo.

enum Type { GROUND, AERIAL }

@export var obstacle_type: Type = Type.GROUND

func _ready() -> void:
    add_to_group("obstacles")

func scroll(amount: float) -> void:
    position.x -= amount

func is_off_screen() -> bool:
    return position.x < -100
```

### Paso 5.4: Crear obstacle_spawner.gd

Crear `scripts/obstacle_spawner.gd`:

```gdscript
extends Node2D

## Genera obstaculos proceduralmente a intervalos aleatorios.

@export var obstacle_scene: PackedScene
@export var min_gap: float = 400.0
@export var max_gap: float = 700.0
@export var ground_y: float = -40.0   # relativo a la posicion del spawner
@export var aerial_y: float = -150.0  # para obstaculos aereos

var _distance_since_last: float = 0.0
var _next_spawn_distance: float = 0.0
var _obstacles: Array[Area2D] = []
var _is_active: bool = true

func _ready() -> void:
    _next_spawn_distance = randf_range(min_gap, max_gap)

func scroll(amount: float) -> void:
    if not _is_active:
        return

    _distance_since_last += amount

    # Mover obstaculos existentes
    var to_remove: Array[int] = []
    for i in _obstacles.size():
        if is_instance_valid(_obstacles[i]):
            _obstacles[i].scroll(amount)
            if _obstacles[i].is_off_screen():
                to_remove.append(i)
        else:
            to_remove.append(i)

    # Eliminar los que salieron de pantalla (de atras para adelante)
    for i in range(to_remove.size() - 1, -1, -1):
        if is_instance_valid(_obstacles[to_remove[i]]):
            _obstacles[to_remove[i]].queue_free()
        _obstacles.remove_at(to_remove[i])

    # Generar nuevo obstaculo si hay suficiente distancia
    if _distance_since_last >= _next_spawn_distance:
        _spawn_obstacle()
        _distance_since_last = 0.0
        _next_spawn_distance = randf_range(min_gap, max_gap)

func _spawn_obstacle() -> void:
    if not obstacle_scene:
        return

    var obs: Area2D = obstacle_scene.instantiate()

    # 30% de probabilidad de obstaculo aereo
    if randf() > 0.7:
        obs.obstacle_type = obs.Type.AERIAL
        obs.position = Vector2(get_viewport_rect().size.x + 100, aerial_y)
    else:
        obs.obstacle_type = obs.Type.GROUND
        obs.position = Vector2(get_viewport_rect().size.x + 100, ground_y)

    _obstacles.append(obs)
    add_child(obs)

func stop() -> void:
    _is_active = false
```

### Paso 5.5: Agregar HitboxArea al Player

Abrir `scenes/player.tscn`:

1. Seleccionar **"Player"**
2. "+" → `Area2D` → Create → renombrar a **"HitboxArea"**
3. Con "HitboxArea" seleccionado:
   - "+" → `CollisionShape2D` → Create
   - Shape → New RectangleShape2D → Size: `x: 26, y: 52`
   - Position: `y: -28`

El arbol del Player queda:
```
Player (CharacterBody2D)
├── ColorRect (azul)
├── CollisionShape2D (para fisica/piso)
└── HitboxArea (Area2D)
    └── CollisionShape2D (para detectar obstaculos)
```

### Paso 5.6: Actualizar player.gd con deteccion de muerte

Reemplazar `scripts/player.gd` con:

```gdscript
extends CharacterBody2D

const GRAVITY: float = 1200.0
const JUMP_VELOCITY: float = -600.0

var _is_crouching: bool = false
var _is_dead: bool = false

func _ready() -> void:
    SwipeDetector.swiped_up.connect(_on_swipe_up)
    SwipeDetector.swiped_down.connect(_on_swipe_down)
    $HitboxArea.area_entered.connect(_on_hitbox_area_entered)

func _physics_process(delta: float) -> void:
    if _is_dead:
        return

    if not is_on_floor():
        velocity.y += GRAVITY * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        _jump()
    if Input.is_action_just_pressed("crouch") and is_on_floor():
        _crouch()

    move_and_slide()

func _jump() -> void:
    if is_on_floor() and not _is_dead:
        velocity.y = JUMP_VELOCITY

func _crouch() -> void:
    if is_on_floor() and not _is_dead:
        _is_crouching = true

func _on_swipe_up() -> void:
    _jump()

func _on_swipe_down() -> void:
    _crouch()

func _on_hitbox_area_entered(area: Area2D) -> void:
    if area.is_in_group("obstacles"):
        _die()
    elif area.is_in_group("coins"):
        area.collect()
        GameManager.add_coin()

func _die() -> void:
    if _is_dead:
        return
    _is_dead = true
    GameManager.end_game()
    # Visual: poner rojo al morir
    $ColorRect.color = Color.RED
    velocity = Vector2.ZERO
```

### Paso 5.7: Conectar todo en game.tscn

Abrir `scenes/game.tscn`:

1. Seleccionar **"World"** → "+" → `Node2D` → renombrar a **"ObstacleSpawner"**
   - Attach script: `res://scripts/obstacle_spawner.gd`
   - En el Inspector, en `Obstacle Scene` → click → **Quick Load** → elegir `obstacle.tscn`
   - Position del ObstacleSpawner: `y: 500` (misma Y que el GroundManager)

2. Necesitamos un script para el nodo Game que inicie el juego y conecte el game_over.
   Seleccionar **"Game"** → Attach Script → `res://scripts/game.gd`:

```gdscript
extends Node2D

## Script principal del juego. Inicia el juego y maneja el game over.

func _ready() -> void:
    GameManager.start_game()
    GameManager.game_over.connect(_on_game_over)

func _on_game_over() -> void:
    $World.stop()
    # Por ahora solo detiene el mundo. Agregaremos pantalla de game over despues.
```

Tambien hay que conectar el game_over en world_scroller.gd. Actualizar la funcion `_ready`:

```gdscript
func _ready() -> void:
    GameManager.game_over.connect(stop)
```

(Agregar esa linea al inicio de `world_scroller.gd`)

El arbol final:
```
Game (Node2D) ← con game.gd
├── World (Node2D) ← con world_scroller.gd
│   ├── GroundManager (Node2D) ← con ground_manager.gd
│   └── ObstacleSpawner (Node2D) ← con obstacle_spawner.gd
├── Ground (StaticBody2D)
│   └── CollisionShape2D
├── Player
└── UI (CanvasLayer)
```

### Paso 5.8: PROBAR

Presionar **F5**.

**Esperado:**
- El piso se mueve
- Rectangulos rojos (obstaculos) aparecen por la derecha a intervalos variados
- Algunos a nivel del piso, algunos mas arriba (aereos)
- Saltar para esquivar los del piso funciona
- Tocar un obstaculo → el player se pone rojo, el mundo se detiene
- El score sigue subiendo mientras jugas (visible en la consola con print)

**Problemas comunes:**
- Los obstaculos no aparecen: verifica que `obstacle_scene` esta asignado en el Inspector
- Los obstaculos no matan: verifica que HitboxArea tiene un CollisionShape2D
- Los obstaculos flotan: ajustar `ground_y` en el Inspector del ObstacleSpawner

### Paso 5.9: Commit

```bash
git add scenes/ scripts/
git commit -m "feat: obstacle spawning and collision game over"
```

**TAREA 5 COMPLETADA** ✓

---

## TAREA 6: Monedas y Puntaje en Pantalla

**Resultado:** Monedas amarillas aparecen, las recolectas al tocarlas, y el score se muestra arriba.

### Paso 6.1: Crear la escena de la Moneda

1. **Scene → New Scene** → `Area2D` → renombrar a **"Coin"**
2. Hijos:
   - `ColorRect` → Size: `20x20`, Position: `-10, -10`, Color: **amarillo**
   - `CollisionShape2D` → Shape: New CircleShape2D, Radius: `10`
3. Guardar como `res://scenes/coin.tscn`

### Paso 6.2: Escribir coin.gd

```gdscript
extends Area2D

## Una moneda coleccionable.

func _ready() -> void:
    add_to_group("coins")

func scroll(amount: float) -> void:
    position.x -= amount

func is_off_screen() -> bool:
    return position.x < -50

func collect() -> void:
    queue_free()
```

### Paso 6.3: Crear coin_spawner.gd

Crear `scripts/coin_spawner.gd`:

```gdscript
extends Node2D

## Genera monedas a intervalos aleatorios.

@export var coin_scene: PackedScene
@export var min_gap: float = 200.0
@export var max_gap: float = 400.0
@export var coin_y_min: float = -200.0  # relativo al spawner
@export var coin_y_max: float = -20.0

var _distance_since_last: float = 0.0
var _next_spawn_distance: float = 0.0
var _coins: Array[Area2D] = []
var _is_active: bool = true

func _ready() -> void:
    _next_spawn_distance = randf_range(min_gap, max_gap)

func scroll(amount: float) -> void:
    if not _is_active:
        return

    _distance_since_last += amount

    var to_remove: Array[int] = []
    for i in _coins.size():
        if is_instance_valid(_coins[i]):
            _coins[i].scroll(amount)
            if _coins[i].is_off_screen():
                to_remove.append(i)
        else:
            to_remove.append(i)

    for i in range(to_remove.size() - 1, -1, -1):
        if is_instance_valid(_coins[to_remove[i]]):
            _coins[to_remove[i]].queue_free()
        _coins.remove_at(to_remove[i])

    if _distance_since_last >= _next_spawn_distance:
        _spawn_coin()
        _distance_since_last = 0.0
        _next_spawn_distance = randf_range(min_gap, max_gap)

func _spawn_coin() -> void:
    if not coin_scene:
        return

    var coin: Area2D = coin_scene.instantiate()
    coin.position = Vector2(
        get_viewport_rect().size.x + 50,
        randf_range(coin_y_min, coin_y_max)
    )
    _coins.append(coin)
    add_child(coin)

func stop() -> void:
    _is_active = false
```

### Paso 6.4: Agregar CoinSpawner y ScoreLabel a game.tscn

1. En `scenes/game.tscn`:
   - Seleccionar **World** → "+" → `Node2D` → renombrar a **"CoinSpawner"**
   - Attach script: `scripts/coin_spawner.gd`
   - Inspector: `Coin Scene` → Quick Load → `coin.tscn`
   - Position: `y: 500` (misma base que los obstaculos)

2. Seleccionar **UI** → "+" → `Label` → renombrar a **"ScoreLabel"**
   - Attach script (nuevo): `scripts/score_ui.gd`
   - En Inspector:
     - `Text`: "0"
     - `Position`: `x: 20, y: 20`
     - En `Theme Overrides > Font Sizes > Font Size`: **48**
     - En `Theme Overrides > Colors > Font Color`: **blanco**

### Paso 6.5: Escribir score_ui.gd

```gdscript
extends Label

## Muestra el puntaje actual en pantalla.

func _ready() -> void:
    GameManager.score_changed.connect(_on_score_changed)
    text = "0"

func _on_score_changed(new_score: int) -> void:
    text = str(new_score)
```

### Paso 6.6: PROBAR

Presionar **F5**.

**Esperado:**
- Monedas amarillas aparecen a diferentes alturas
- Al pasar por ellas, desaparecen (se recolectan)
- El numero arriba a la izquierda sube continuamente (distancia)
- Recolectar una moneda hace que el score suba un poquito mas

### Paso 6.7: Commit

```bash
git add scenes/ scripts/
git commit -m "feat: coins, score display, and collectible system"
```

**TAREA 6 COMPLETADA** ✓

---

## TAREA 7: Sistema de Zonas

**Resultado:** El color del fondo y piso cambian segun la zona. Las zonas mas peligrosas tienen mas obstaculos y son mas rapidas.

### Paso 7.1: Crear el Resource ZoneData

Crear `scripts/zone_data.gd`:

```gdscript
class_name ZoneData
extends Resource

## Define los parametros visuales y de dificultad de una zona.

@export var zone_name: String = ""
@export var ground_color: Color = Color.DARK_GREEN
@export var bg_color: Color = Color.CORNFLOWER_BLUE
@export var obstacle_min_gap: float = 400.0
@export var obstacle_max_gap: float = 700.0
@export var coin_min_gap: float = 200.0
@export var coin_max_gap: float = 400.0
@export var speed_modifier: float = 1.0
@export var obstacle_color: Color = Color.RED
@export var aerial_chance: float = 0.3  # probabilidad de obstaculo aereo
@export var duration_distance: float = 2000.0  # distancia antes de cambiar de zona
```

### Paso 7.2: Crear archivos de zona

En Godot:
1. Click derecho en carpeta `data/` → **New Resource** → buscar `ZoneData` → Create
2. Rellenar valores y guardar como `data/zone_safe_plains.tres`:
   - zone_name: "Safe Plains"
   - ground_color: `#2d5a27` (verde oscuro)
   - bg_color: `#6495ed` (celeste)
   - obstacle_min_gap: 500
   - obstacle_max_gap: 800
   - coin_min_gap: 150
   - coin_max_gap: 300
   - speed_modifier: 1.0
   - obstacle_color: `#8b4513` (marron)
   - aerial_chance: 0.2
   - duration_distance: 2000

3. Repetir para `data/zone_danger_cave.tres`:
   - zone_name: "Danger Cave"
   - ground_color: `#3a3a3a` (gris oscuro)
   - bg_color: `#2f4f4f` (gris azulado)
   - obstacle_min_gap: 250
   - obstacle_max_gap: 450
   - coin_min_gap: 400
   - coin_max_gap: 600
   - speed_modifier: 1.3
   - obstacle_color: `#8b0000` (rojo oscuro)
   - aerial_chance: 0.4
   - duration_distance: 1500

4. Repetir para `data/zone_sky_bonus.tres`:
   - zone_name: "Sky Bonus"
   - ground_color: `#e8e8e8` (blanco grisaceo)
   - bg_color: `#ff6347` (rojo atardecer)
   - obstacle_min_gap: 350
   - obstacle_max_gap: 550
   - coin_min_gap: 100
   - coin_max_gap: 200
   - speed_modifier: 1.1
   - obstacle_color: `#ffd700` (dorado)
   - aerial_chance: 0.3
   - duration_distance: 1000

### Paso 7.3: Crear zone_manager.gd

Crear `scripts/zone_manager.gd`:

```gdscript
extends Node

## Decide que zona esta activa y notifica los cambios.

signal zone_changed(zone: ZoneData)

@export var zones_safe: Array[ZoneData] = []
@export var zones_danger: Array[ZoneData] = []
@export var zones_bonus: Array[ZoneData] = []

var current_zone: ZoneData
var _distance_in_zone: float = 0.0
var _zone_cycle: int = 0

func _ready() -> void:
    if zones_safe.size() > 0:
        _set_zone(zones_safe[0])

func update_distance(amount: float) -> void:
    _distance_in_zone += amount

    if current_zone and _distance_in_zone >= current_zone.duration_distance:
        _next_zone()

func _next_zone() -> void:
    _distance_in_zone = 0.0
    _zone_cycle += 1

    # Patron: safe → danger → bonus → safe → danger → bonus...
    var cycle: int = _zone_cycle % 3
    match cycle:
        0:
            if zones_safe.size() > 0:
                _set_zone(zones_safe.pick_random())
        1:
            if zones_danger.size() > 0:
                _set_zone(zones_danger.pick_random())
        2:
            if zones_bonus.size() > 0:
                _set_zone(zones_bonus.pick_random())

func _set_zone(zone: ZoneData) -> void:
    current_zone = zone
    zone_changed.emit(zone)
```

### Paso 7.4: Integrar en game.tscn

1. Seleccionar **"Game"** → "+" → `Node` → renombrar a **"ZoneManager"**
   - Attach script: `scripts/zone_manager.gd`
   - En Inspector:
     - `Zones Safe` → agregar → arrastrar `zone_safe_plains.tres`
     - `Zones Danger` → agregar → arrastrar `zone_danger_cave.tres`
     - `Zones Bonus` → agregar → arrastrar `zone_sky_bonus.tres`

2. Actualizar `scripts/game.gd`:

```gdscript
extends Node2D

func _ready() -> void:
    GameManager.start_game()
    GameManager.game_over.connect(_on_game_over)
    $ZoneManager.zone_changed.connect(_on_zone_changed)

func _process(delta: float) -> void:
    if GameManager.is_playing:
        $ZoneManager.update_distance($World.scroll_speed * delta)

func _on_game_over() -> void:
    $World.stop()

func _on_zone_changed(zone: ZoneData) -> void:
    # Cambiar color de fondo
    RenderingServer.set_default_clear_color(zone.bg_color)

    # Actualizar velocidad
    $World.set_speed_modifier(zone.speed_modifier)

    # Actualizar spawners (si tienen el metodo)
    var obs_spawner = $World/ObstacleSpawner
    if obs_spawner:
        obs_spawner.min_gap = zone.obstacle_min_gap
        obs_spawner.max_gap = zone.obstacle_max_gap

    var coin_spawner = $World/CoinSpawner
    if coin_spawner:
        coin_spawner.min_gap = zone.coin_min_gap
        coin_spawner.max_gap = zone.coin_max_gap
```

### Paso 7.5: PROBAR

Presionar **F5**. Jugar por 20-30 segundos.

**Esperado:**
- Empieza en "Safe Plains" (fondo celeste, piso verde, pocos obstaculos)
- Despues de un rato cambia a "Danger Cave" (fondo oscuro, mas obstaculos, mas rapido)
- Luego "Sky Bonus" (fondo atardecer, muchas monedas)
- El ciclo se repite

### Paso 7.6: Commit

```bash
git add scripts/ data/ scenes/
git commit -m "feat: data-driven zone system with themed difficulty"
```

**TAREA 7 COMPLETADA** ✓

---

## TAREA 8: Mecanica de Agacharse

**Resultado:** Al presionar S o swipe abajo, el player se agacha (se achica) y puede pasar bajo obstaculos aereos.

### Paso 8.1: Agregar segundo CollisionShape al Player

En `scenes/player.tscn`:

1. Seleccionar el `CollisionShape2D` existente → renombrar a **"CollisionStanding"**
2. Seleccionar **"Player"** → "+" → `CollisionShape2D` → renombrar a **"CollisionCrouching"**
   - Shape: New RectangleShape2D → Size: `x: 28, y: 24`
   - Position: `y: -14`
   - **Desactivar** en Inspector: `Disabled = true`

3. Dentro de HitboxArea:
   - Renombrar el CollisionShape2D existente a **"HitboxStanding"**
   - "+" → `CollisionShape2D` → renombrar a **"HitboxCrouching"**
     - Shape: New RectangleShape2D → Size: `x: 26, y: 22`
     - Position: `y: -12`
     - `Disabled = true`

Arbol del Player:
```
Player (CharacterBody2D)
├── ColorRect
├── CollisionStanding (CollisionShape2D — 28x54)
├── CollisionCrouching (CollisionShape2D — 28x24, DISABLED)
└── HitboxArea (Area2D)
    ├── HitboxStanding (CollisionShape2D — 26x52)
    └── HitboxCrouching (CollisionShape2D — 26x22, DISABLED)
```

### Paso 8.2: Actualizar player.gd

Reemplazar `scripts/player.gd` completamente:

```gdscript
extends CharacterBody2D

const GRAVITY: float = 1200.0
const JUMP_VELOCITY: float = -600.0
const CROUCH_DURATION: float = 0.6  # segundos agachado

var _is_crouching: bool = false
var _is_dead: bool = false
var _crouch_timer: float = 0.0

func _ready() -> void:
    SwipeDetector.swiped_up.connect(_on_swipe_up)
    SwipeDetector.swiped_down.connect(_on_swipe_down)
    $HitboxArea.area_entered.connect(_on_hitbox_area_entered)

func _physics_process(delta: float) -> void:
    if _is_dead:
        return

    # Gravedad
    if not is_on_floor():
        velocity.y += GRAVITY * delta

    # Timer de agacharse
    if _is_crouching:
        _crouch_timer -= delta
        if _crouch_timer <= 0:
            _stand_up()

    # Controles de teclado
    if Input.is_action_just_pressed("jump") and is_on_floor():
        _jump()
    if Input.is_action_just_pressed("crouch") and is_on_floor():
        _crouch()

    move_and_slide()

func _jump() -> void:
    if is_on_floor() and not _is_dead and not _is_crouching:
        velocity.y = JUMP_VELOCITY

func _crouch() -> void:
    if is_on_floor() and not _is_dead and not _is_crouching:
        _is_crouching = true
        _crouch_timer = CROUCH_DURATION

        # Cambiar collision shapes
        $CollisionStanding.disabled = true
        $CollisionCrouching.disabled = false
        $"HitboxArea/HitboxStanding".disabled = true
        $"HitboxArea/HitboxCrouching".disabled = false

        # Visual: achatar el sprite
        $ColorRect.size.y = 28
        $ColorRect.position.y = -28

func _stand_up() -> void:
    _is_crouching = false

    # Restaurar collision shapes
    $CollisionStanding.disabled = false
    $CollisionCrouching.disabled = true
    $"HitboxArea/HitboxStanding".disabled = false
    $"HitboxArea/HitboxCrouching".disabled = true

    # Visual: restaurar sprite
    $ColorRect.size.y = 56
    $ColorRect.position.y = -56

func _on_swipe_up() -> void:
    _jump()

func _on_swipe_down() -> void:
    _crouch()

func _on_hitbox_area_entered(area: Area2D) -> void:
    if area.is_in_group("obstacles"):
        _die()
    elif area.is_in_group("coins"):
        area.collect()
        GameManager.add_coin()

func _die() -> void:
    if _is_dead:
        return
    _is_dead = true
    GameManager.end_game()
    $ColorRect.color = Color.RED
    velocity = Vector2.ZERO
```

### Paso 8.3: PROBAR

Presionar **F5**.

**Esperado:**
- Presionar **S** → el player se achica a la mitad de altura
- Despues de 0.6 segundos se levanta solo
- Obstaculos aereos pasan por encima cuando esta agachado
- No puede saltar mientras esta agachado
- Obstaculos del piso siguen matando

### Paso 8.4: Commit

```bash
git add scripts/player.gd scenes/player.tscn
git commit -m "feat: crouch mechanic with collision switching"
```

**TAREA 8 COMPLETADA** ✓

---

## TAREA 9: Menu Principal y Game Over

**Resultado:** El juego tiene un menu de inicio y una pantalla de game over con score y high score.

### Paso 9.1: Agregar persistencia de high score

Actualizar `scripts/game_manager.gd` — agregar estas funciones al final:

```gdscript
const SAVE_PATH: String = "user://highscore.save"

func get_high_score() -> int:
    if not FileAccess.file_exists(SAVE_PATH):
        return 0
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file:
        return file.get_32()
    return 0

func save_high_score() -> void:
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_32(score)
```

### Paso 9.2: Crear la escena del Menu Principal

1. **Scene → New Scene** → `Control` → renombrar a **"MainMenu"**
2. En Inspector: Layout → **Full Rect** (para que ocupe toda la pantalla)
3. Agregar hijos:

```
MainMenu (Control — Full Rect)
└── VBoxContainer (centrado)
    ├── TitleLabel (Label)
    ├── PlayButton (Button)
    └── HighScoreLabel (Label)
```

Pasos detallados:
- "+" → `VBoxContainer`
  - En Inspector > Layout > Anchors Preset: **Center**
  - Theme Overrides > Constants > Separation: **20**
- Dentro de VBoxContainer:
  - "+" → `Label` → renombrar **"TitleLabel"**
    - Text: "DASH RUNNER"
    - Theme Overrides > Font Sizes: **72**
    - Horizontal Alignment: **Center**
  - "+" → `Button` → renombrar **"PlayButton"**
    - Text: "JUGAR"
    - Theme Overrides > Font Sizes: **36**
    - Custom Minimum Size: `x: 300, y: 80`
  - "+" → `Label` → renombrar **"HighScoreLabel"**
    - Text: "High Score: 0"
    - Theme Overrides > Font Sizes: **24**
    - Horizontal Alignment: **Center**

4. Guardar como `res://scenes/main_menu.tscn`

### Paso 9.3: Escribir main_menu.gd

```gdscript
extends Control

func _ready() -> void:
    var high_score: int = GameManager.get_high_score()
    $VBoxContainer/HighScoreLabel.text = "High Score: %d" % high_score
    $VBoxContainer/PlayButton.pressed.connect(_on_play)

func _on_play() -> void:
    get_tree().change_scene_to_file("res://scenes/game.tscn")
```

### Paso 9.4: Crear la pantalla de Game Over

1. **Scene → New Scene** → `Control` → renombrar a **"GameOverScreen"**
2. Layout: **Full Rect**
3. Agregar hijos:

```
GameOverScreen (Control — Full Rect)
└── Panel (centrado, semi-transparente)
    └── VBoxContainer
        ├── GameOverLabel (Label — "GAME OVER")
        ├── ScoreLabel (Label — "Score: 0")
        ├── HighScoreLabel (Label — "High Score: 0")
        ├── RetryButton (Button — "REINTENTAR")
        └── MenuButton (Button — "MENU")
```

Pasos detallados:
- "+" → `Panel`
  - Layout > Anchors Preset: **Center**
  - Custom Minimum Size: `x: 400, y: 350`
  - Self Modulate > A (alpha): **200** (semi-transparente)
- Dentro de Panel:
  - "+" → `VBoxContainer` → Layout: **Full Rect** con margenes de 20px
    - Separation: **15**
  - Dentro de VBoxContainer agregar los Labels y Buttons como en el paso anterior

4. Guardar como `res://scenes/game_over.tscn`

### Paso 9.5: Escribir game_over.gd

```gdscript
extends Control

func _ready() -> void:
    $Panel/VBoxContainer/ScoreLabel.text = "Score: %d" % GameManager.score

    var high: int = GameManager.get_high_score()
    var is_new: bool = GameManager.score > high

    if is_new:
        GameManager.save_high_score()
        high = GameManager.score

    var hs_text: String = "High Score: %d" % high
    if is_new:
        hs_text += " NEW!"
    $Panel/VBoxContainer/HighScoreLabel.text = hs_text

    $Panel/VBoxContainer/RetryButton.pressed.connect(_on_retry)
    $Panel/VBoxContainer/MenuButton.pressed.connect(_on_menu)

func _on_retry() -> void:
    get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_menu() -> void:
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
```

### Paso 9.6: Conectar Game Over en game.gd

Actualizar `scripts/game.gd`:

```gdscript
extends Node2D

var _game_over_scene: PackedScene = preload("res://scenes/game_over.tscn")

func _ready() -> void:
    GameManager.start_game()
    GameManager.game_over.connect(_on_game_over)
    $ZoneManager.zone_changed.connect(_on_zone_changed)

func _process(delta: float) -> void:
    if GameManager.is_playing:
        $ZoneManager.update_distance($World.scroll_speed * delta)

func _on_game_over() -> void:
    $World.stop()
    # Esperar un momento antes de mostrar game over
    await get_tree().create_timer(0.5).timeout
    var screen = _game_over_scene.instantiate()
    $UI.add_child(screen)

func _on_zone_changed(zone: ZoneData) -> void:
    RenderingServer.set_default_clear_color(zone.bg_color)
    $World.set_speed_modifier(zone.speed_modifier)

    var obs_spawner = $World/ObstacleSpawner
    if obs_spawner:
        obs_spawner.min_gap = zone.obstacle_min_gap
        obs_spawner.max_gap = zone.obstacle_max_gap

    var coin_spawner = $World/CoinSpawner
    if coin_spawner:
        coin_spawner.min_gap = zone.coin_min_gap
        coin_spawner.max_gap = zone.coin_max_gap
```

### Paso 9.7: Cambiar la escena principal al Menu

**Project → Project Settings → Application → Run → Main Scene** = `res://scenes/main_menu.tscn`

### Paso 9.8: PROBAR

Presionar **F5**.

**Esperado:**
- Aparece el menu con "DASH RUNNER", boton "JUGAR", y high score
- Click JUGAR → empieza el juego
- Morir → pantalla de Game Over con score
- Si es nuevo record, dice "NEW!"
- REINTENTAR → juego de nuevo
- MENU → vuelve al menu principal
- El high score persiste entre sesiones

### Paso 9.9: Commit

```bash
git add scenes/ scripts/
git commit -m "feat: main menu, game over screen, and high score"
```

**TAREA 9 COMPLETADA** ✓

---

## TAREA 10: Dificultad Progresiva

**Resultado:** El juego se vuelve mas rapido con el tiempo.

### Paso 10.1: Agregar rampa de velocidad a game.gd

Actualizar `scripts/game.gd`, agregar estas constantes y variable:

```gdscript
const SPEED_INCREASE: float = 10.0   # pixeles/seg que se agregan
const SPEED_INTERVAL: float = 10.0   # cada 10 segundos
const MAX_BASE_SPEED: float = 800.0

var _speed_timer: float = 0.0
```

Actualizar `_process()`:

```gdscript
func _process(delta: float) -> void:
    if GameManager.is_playing:
        $ZoneManager.update_distance($World.scroll_speed * delta)

        # Aumentar velocidad gradualmente
        _speed_timer += delta
        if _speed_timer >= SPEED_INTERVAL:
            _speed_timer = 0.0
            $World.increase_speed(SPEED_INCREASE)
```

Actualizar `world_scroller.gd` — agregar limite en `increase_speed`:

```gdscript
func increase_speed(amount: float) -> void:
    _base_speed = min(_base_speed + amount, 800.0)
    scroll_speed = _base_speed * _speed_modifier
```

### Paso 10.2: PROBAR

Jugar 30+ segundos. El juego se siente notablemente mas rapido.

### Paso 10.3: Commit

```bash
git add scripts/game.gd scripts/world_scroller.gd
git commit -m "feat: progressive difficulty speed ramp"
```

**TAREA 10 COMPLETADA** ✓

---

## TAREA 11: Animaciones Basicas

**Resultado:** El player tiene feedback visual para correr, saltar, agacharse y morir.

### Paso 11.1: Agregar AnimationPlayer al Player

En `scenes/player.tscn`:
1. Seleccionar **"Player"** → "+" → `AnimationPlayer`

2. En el panel **Animation** (abajo):
   - Click **"Animation"** → **New** → nombre: **"run"**
   - Duracion: **0.4s**, Loop: **activado** (icono de flechas circulares)
   - Seleccionar el `ColorRect`
   - En el timeline:
     - Frame 0.0: position.y = -56 (click la llave al lado de position)
     - Frame 0.2: position.y = -60 (el player "sube" un poquito)
     - Frame 0.4: position.y = -56 (vuelve)
   - Esto crea un bounce sutil

3. Crear animacion **"die"**:
   - Duracion: **0.5s**, Loop: **desactivado**
   - Frame 0.0: modulate = blanco, rotation = 0
   - Frame 0.25: modulate = rojo
   - Frame 0.5: modulate = rojo, rotation = 0.5 (rota un poco)

### Paso 11.2: Reproducir animaciones en player.gd

Agregar al final de `_ready()`:
```gdscript
$AnimationPlayer.play("run")
```

En `_jump()`, agregar:
```gdscript
$AnimationPlayer.stop()
```

Cuando aterriza (en `_physics_process`, despues de `move_and_slide()`):
```gdscript
if is_on_floor() and not _is_crouching and not _is_dead:
    if not $AnimationPlayer.is_playing() or $AnimationPlayer.current_animation != "run":
        $AnimationPlayer.play("run")
```

En `_die()`:
```gdscript
$AnimationPlayer.play("die")
```

### Paso 11.3: PROBAR

**Esperado:**
- El player rebota suavemente mientras corre
- Al saltar, la animacion de correr se pausa
- Al aterrizar, vuelve a animar
- Al morir, se pone rojo y rota

### Paso 11.4: Commit

```bash
git add scripts/player.gd scenes/player.tscn
git commit -m "feat: basic player animations"
```

**TAREA 11 COMPLETADA** ✓

---

## TAREA 12: Assets Reales (Kenney)

**Resultado:** Los rectangulos de colores se reemplazan por sprites de pixel art.

### Prerrequisito

Descargar Kenney "Pixel Platformer" de https://kenney.nl/assets/pixel-platformer y extraer en `assets/kenney/`.

### Paso 12.1: Reemplazar el sprite del Player

1. En `scenes/player.tscn`:
   - Eliminar el `ColorRect`
   - Seleccionar **Player** → "+" → `Sprite2D`
   - En Inspector > Texture → cargar el sprite del personaje de Kenney
   - Ajustar el CollisionShape2D para que coincida con el nuevo sprite

### Paso 12.2: Reemplazar sprites de obstaculos

1. En `scenes/obstacle.tscn`:
   - Reemplazar ColorRect con Sprite2D
   - Usar sprite de caja/roca para obstaculos de piso
   - Crear variante para aereos si hay sprites disponibles

### Paso 12.3: Reemplazar sprite de moneda

1. En `scenes/coin.tscn`:
   - Reemplazar ColorRect con Sprite2D
   - Usar sprite de moneda de Kenney
   - Agregar animacion de rotacion suave con AnimationPlayer

### Paso 12.4: Reemplazar tiles del piso

Actualizar `ground_manager.gd` para usar sprites en vez de ColorRect:
- Reemplazar `_create_tile()` para que cree un `Sprite2D` con la textura del tileset

### Paso 12.5: PROBAR

**Esperado:** Todo se ve como pixel art. Las colisiones siguen funcionando.

### Paso 12.6: Commit

```bash
git add assets/ scenes/ scripts/
git commit -m "feat: replace placeholders with Kenney pixel art"
```

**TAREA 12 COMPLETADA** ✓

---

## TAREA 13: Exportar a Android

**Resultado:** Un archivo APK que se puede instalar en un celular Android.

### Paso 13.1: Instalar herramientas

Necesitas:
1. **JDK 17** — descargar de https://adoptium.net/
2. **Android SDK** — la forma mas facil es instalar Android Studio y usar su SDK Manager
   - O descargar solo command-line tools de https://developer.android.com/studio#command-line-tools-only

### Paso 13.2: Configurar en Godot

1. **Editor → Editor Settings** (no Project Settings)
2. Buscar "Android"
3. Configurar:
   - `Export > Android > Java SDK Path` → ruta al JDK 17
   - `Export > Android > Android SDK Path` → ruta al Android SDK
4. Si no tenes un keystore de debug:
   - Godot puede generarlo automaticamente

### Paso 13.3: Crear preset de export

1. **Project → Export**
2. Click **"Add..."** → **Android**
3. Configurar:
   - Unique Name: `com.dashrunner.game`
   - Version Name: `1.0.0`
   - Version Code: `1`
   - Min SDK: `24` (Android 7.0)
   - Target SDK: `33`
   - Screen > Orientation: **Landscape**

### Paso 13.4: Exportar APK

1. Click **"Export Project..."**
2. Elegir ubicacion: `build/dash-runner.apk`
3. Desmarcar "Export with Debug" si queres una build limpia
4. Click **Save**

### Paso 13.5: Instalar en celular

Conectar celular por USB con depuracion USB activada:

```bash
adb install build/dash-runner.apk
```

O simplemente copiar el APK al celular y abrirlo.

### Paso 13.6: PROBAR en celular

**Esperado:**
- El juego abre en landscape
- Los swipes funcionan para saltar y agacharse
- El rendimiento es fluido
- El score y high score funcionan

### Paso 13.7: Commit

```bash
git add export_presets.cfg
git commit -m "feat: Android export configuration"
```

**TAREA 13 COMPLETADA** ✓

---

## Felicitaciones!

Si llegaste hasta aca, tenes un endless runner funcional para Android hecho en Godot. Aprendiste:

- **Escenas y nodos** de Godot
- **GDScript** (similar a Python)
- **Fisica** (CharacterBody2D, gravedad, colisiones)
- **Input tactil** (swipe detection)
- **Generacion procedural** (spawners)
- **Data-driven design** (Resources para zonas)
- **UI** (Labels, Buttons, CanvasLayer)
- **Persistencia** (FileAccess para high score)
- **Export a Android**

### Ideas para seguir mejorando (post-MVP)

- [ ] Implementar la accion de TAP (ataque o habilidad)
- [ ] Agregar power-ups (escudo, iman de monedas, slow-mo)
- [ ] Agregar efectos de sonido y musica
- [ ] Agregar particulas (explosion al morir, brillo al recolectar moneda)
- [ ] Multiples personajes desbloqueables
- [ ] Mas zonas con tematicas unicas
- [ ] Tabla de liderazgo online
- [ ] Publicar en Google Play Store
