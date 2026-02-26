# STORIES FINAL — Sistema de Combate Revisado
_Listo para desarrollo — revisado y completo_

---

## ÉPICA 0: Investigación Previa (hacer PRIMERO)

### [INV-01] Auditar tipos en GameManager y sistemas de dificultad
**Como** dev,  
**quiero** revisar y tipar correctamente `GameManager.get_difficulty_level()` y funciones relacionadas,  
**para** evitar errores de Variant inference como el que ocurrió en HazardSpawner.

**Criterios de aceptación:**
- `GameManager.get_difficulty_level()` retorna `int` explícito
- Todos los sitios que llaman esa función usan tipo explícito
- No hay warnings de Variant en scripts de combate
- **Esto desbloquea PROG-01 y PU-01**

**Estimado:** 30 min

---

## ÉPICA 1: Progresión Escalonada de Dificultad

### Thresholds de XP por fase (configurables en BalanceConfig)
| Fase | XP requerido | Qué aparece |
|------|-------------|-------------|
| 1 | 0 | Solo obstáculos (bloques) |
| 2 | 100 | + Hazards (rayo, onda de choque) |
| 3 | 250 | + Enemigos (solo Slime al inicio) |
| 4 | 500 | Slime + Murciélago + Hazards |
| 5 | 900 | Todo: Slime + Bat + Skeleton + Hazards |
| 6 | 1500 | Todo + Ghost + mayor frecuencia |

---

### [PROG-01] DifficultyPhaseManager — enum de fases
**Como** dev,  
**quiero** un sistema de fases explícito (enum),  
**para** que spawners y sistemas consulten la fase actual en lugar de un número crudo de dificultad.

**Criterios de aceptación:**
- Enum `DifficultyPhase { OBSTACLES_ONLY, HAZARDS, ENEMIES, MIX_1, MIX_2, FULL }` en GameManager
- Función `GameManager.get_phase() -> DifficultyPhase` que evalúa el XP actual
- Thresholds definidos en `BalanceConfig`
- Señal `GameManager.phase_changed(new_phase: DifficultyPhase)` emitida al cambiar de fase
- Mensaje visual en pantalla al subir de fase ("¡Nuevos peligros!")

**Dependencias:** INV-01  
**Estimado:** 1.5h

---

### [PROG-02] Refactor EnemySpawner — respetar fases
**Como** dev,  
**quiero** que EnemySpawner consulte la fase antes de cada spawn,  
**para** introducir enemigos de forma progresiva.

**Criterios de aceptación:**
- EnemySpawner se suscribe a `GameManager.phase_changed`
- Fase < ENEMIES → no spawna nada
- Fase == ENEMIES → solo Slime
- Fase == MIX_1 → Slime + Bat (60/40)
- Fase == MIX_2 → Slime + Bat + Skeleton
- Fase == FULL → todos incluyendo Ghost

**Dependencias:** PROG-01  
**Estimado:** 1h

---

### [PROG-03] Refactor HazardSpawner — respetar fases
**Como** dev,  
**quiero** que HazardSpawner solo esté activo en Fase 2+,  
**para** no abrumar al jugador desde el inicio.

**Criterios de aceptación:**
- Inactivo en OBSTACLES_ONLY
- Activa en HAZARDS y superiores
- En FULL puede coincidir con enemigos en pantalla

**Dependencias:** PROG-01  
**Estimado:** 45 min

---

### [PROG-04] QA — Validar progresión de fases
**Como** QA,  
**quiero** verificar que cada fase se activa en el XP correcto,  
**para** que la experiencia sea la esperada.

**Checklist:**
- [ ] Arrancar nivel → solo obstáculos visibles
- [ ] Llegar a 100 XP → aparecen hazards, no enemigos
- [ ] Llegar a 250 XP → aparecen Slimes
- [ ] Llegar a 500 XP → aparecen Murciélagos
- [ ] Confirmar que no hay mezcla prematura
- [ ] Mensaje visual de nueva fase aparece

**Dependencias:** PROG-01, PROG-02, PROG-03  
**Estimado:** 30 min

---

## ÉPICA 2: Power-ups

### [PU-01] PowerUpManager — sistema base
**Como** dev,  
**quiero** un Autoload que gestione el estado de power-ups activos,  
**para** que cualquier script pueda consultar qué power-up está activo.

**Criterios de aceptación:**
- Autoload `PowerUpManager` con señales: `activated(type: String)`, `expired(type: String)`
- Solo 1 power-up activo a la vez
- Si el jugador recoge uno mientras tiene otro activo → el nuevo **reemplaza** al anterior (el viejo expira inmediatamente)
- Duración configurable por tipo en BalanceConfig
- `PowerUpManager.is_active(type: String) -> bool`

**Dependencias:** INV-01  
**Estimado:** 1h

---

### [PU-02] PowerUp base scene + script
**Como** dev,  
**quiero** una clase base `PowerUp` (Area2D),  
**para** que todos los power-ups hereden de ella.

**Criterios de aceptación:**
- `scenes/powerups/power_up_base.tscn` con Sprite2D + CollisionShape2D (CircleShape, r=30)
- `scripts/power_up.gd` con `@export var power_up_type: String`
- Al colisionar con el jugador → llama `PowerUpManager.activate(power_up_type)` + `queue_free()`
- Animación idle: rotación suave + bob up/down

**Estimado:** 45 min

---

### [PU-03] Power-up: Velocidad de Ataque
**Como** jugador,  
**quiero** recoger un power-up que duplique mi velocidad de ataque,  
**para** hacer más daño en poco tiempo.

**Criterios de aceptación:**
- Tipo: `"attack_speed"`
- Cooldown melee: 0.4s → 0.2s durante activación
- Cooldown ranged: 0.8s → 0.4s durante activación
- Duración: 10s (en BalanceConfig)
- Visual en jugador: modulate amarillo suave (Color(1.5, 1.5, 0.5))
- CombatController chequea `PowerUpManager.is_active("attack_speed")` para aplicar cooldown reducido

**Dependencias:** PU-01, PU-02  
**Estimado:** 1h

---

### [PU-04] Power-up: Espada Grande
**Como** jugador,  
**quiero** un power-up que amplíe mi rango melee,  
**para** atacar sin acercarme tanto.

**Criterios de aceptación:**
- Tipo: `"big_sword"`
- Rango melee: 150px → 280px (offset del melee_attack + scale x1.8)
- Hitbox visible: ColorRect semitransparente azul durante el ataque
- Duración: 8s
- Visual en jugador: modulate azul suave

**Dependencias:** PU-01, PU-02  
**Estimado:** 1h

---

### [PU-05] Power-up: Laser
**Como** jugador,  
**quiero** un power-up que haga mi proyectil atravesar enemigos,  
**para** impactar a varios en línea.

**Criterios de aceptación:**
- Tipo: `"laser"`
- El proyectil no llama `queue_free()` al golpear: decrementa un contador `hits_remaining` (max 3)
- Se destruye al llegar al borde o después de 3 hits
- Visual: proyectil cambia a cyan + trail de partículas simple
- Duración: 12s
- Projectile.gd chequea `PowerUpManager.is_active("laser")` para cambiar comportamiento

**Dependencias:** PU-01, PU-02  
**Estimado:** 1.5h

---

### [PU-06] PowerUpSpawner
**Como** dev,  
**quiero** un spawner que aparezca power-ups durante el nivel,  
**para** que el jugador los encuentre de forma natural.

**Criterios de aceptación:**
- Solo activo en Fase 2+ (cuando hay algo con qué atacar)
- Spawn interval: 20-35s random
- Máximo 1 power-up visible en pantalla a la vez
- Tipo de power-up: random uniforme entre los 3 disponibles
- Posición: random en pantalla con margen de 150px
- Conectado en level.gd igual que EnemySpawner

**Dependencias:** PU-01, PU-02, PROG-01  
**Estimado:** 45 min

---

### [PU-07] UI — Indicador de power-up activo
**Como** jugador,  
**quiero** ver qué power-up tengo y cuánto tiempo queda,  
**para** tomar decisiones de combate.

**Criterios de aceptación:**
- Panel en esquina superior derecha: ícono (emoji/label) + ProgressBar de tiempo
- Aparece al activar, desaparece al expirar
- Parpadea en los últimos 2 segundos
- No interfiere con otros elementos de UI (score, XP, distancia)

**Dependencias:** PU-01  
**Estimado:** 45 min

---

## ÉPICA 3: Integración

### [INT-01] Merge combat-vfx → ahi-vienen-los-golpes
Mergear efectos visuales al branch base de combate.  
**Prerequisito:** verificar que no hay conflictos en enemy.gd y melee_attack.gd.

### [INT-02] Merge combat-hazards → ahi-vienen-los-golpes
Mergear hazards al branch base.  
**Prerequisito:** INV-01 resuelto (tipado correcto).

### [INT-03] Merge combat-balance → ahi-vienen-los-golpes
Mergear BalanceConfig al branch base.  
**Prerequisito:** PROG-01 completo (BalanceConfig recibe los thresholds de fases).

### [INT-04] QA final de integración completa
Verificar que todo funciona junto: obstáculos + hazards + enemigos + power-ups + VFX + progresión de fases.

---

## Orden de implementación recomendado

```
INV-01 → PROG-01 → PROG-02 → PROG-03
                 ↘ PU-01 → PU-02 → PU-03 → PU-04 → PU-05 → PU-06 → PU-07
                 
INT-01 → INT-02 → INT-03 → INT-04 (al final de todo)
PROG-04 (QA) después de PROG-01/02/03
```

**Total estimado:** ~12-14 horas de desarrollo
