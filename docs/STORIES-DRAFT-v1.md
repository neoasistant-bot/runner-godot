# STORIES DRAFT v1 — Sistema de Combate Revisado
_Borrador inicial — no enviar a devs_

---

## ÉPICA 1: Progresión Escalonada de Dificultad

### [PROG-01] DifficultyManager — Fases de dificultad
**Como** jugador,  
**quiero** que el juego introduzca obstáculos, hazards y enemigos de forma progresiva,  
**para** aprender las mecánicas sin sentirme abrumado.

**Criterios de aceptación:**
- Fase 1: solo obstáculos (bloques para esquivar)
- Fase 2 (XP threshold): + hazards (rayo, onda de choque)
- Fase 3: + enemigos (Slime primero)
- Fase 4+: combinaciones crecientes
- En Fase 1 el EnemySpawner y HazardSpawner están desactivados
- Transición entre fases es suave (no instantánea)

**Notas técnicas:**
- Refactorizar `GameManager.get_difficulty_level()` para retornar una Fase (enum)
- EnemySpawner y HazardSpawner reciben la fase actual y activan/desactivan según corresponde
- Thresholds de XP configurables en BalanceConfig

---

### [PROG-02] Refactor EnemySpawner — respetar fases
**Como** dev,  
**quiero** que EnemySpawner solo spawne cuando la fase lo permite,  
**para** que la dificultad sea progresiva.

**Criterios de aceptación:**
- EnemySpawner chequea la fase actual antes de cada spawn
- Si fase < 3 → no spawna enemigos
- Si fase == 3 → solo Slime
- Si fase >= 4 → mix progresivo

---

### [PROG-03] Refactor HazardSpawner — respetar fases
**Como** dev,  
**quiero** que HazardSpawner solo spawne en Fase 2+,  
**para** no abrumar al jugador desde el inicio.

**Criterios de aceptación:**
- HazardSpawner inactivo en Fase 1
- Activa gradualmente desde Fase 2
- En Fase 4+ puede coincidir con enemigos

---

## ÉPICA 2: Power-ups

### [PU-01] Sistema base de Power-ups
**Como** jugador,  
**quiero** recoger power-ups durante el nivel,  
**para** tener ventajas temporales que hagan el juego más entretenido.

**Criterios de aceptación:**
- Los power-ups aparecen random en pantalla (como monedas)
- Duración: 8-12 segundos por power-up
- Solo 1 power-up activo a la vez
- Indicador visual en UI mostrando el power-up activo y tiempo restante
- PowerUpSpawner separado del CoinSpawner

**Notas técnicas:**
- Clase base `PowerUp` (Area2D)
- Autoload `PowerUpManager` que gestiona el estado activo
- Señal `power_up_activated(type)` y `power_up_expired()`

---

### [PU-02] Power-up: Velocidad de Ataque
**Como** jugador,  
**quiero** un power-up que reduzca el cooldown de ataque,  
**para** atacar más rápido temporalmente.

**Criterios de aceptación:**
- Cooldown melee: 0.4s → 0.2s
- Cooldown ranged: 0.8s → 0.4s
- Duración: 10s
- Visual: aura amarilla en el jugador

---

### [PU-03] Power-up: Espada Grande
**Como** jugador,  
**quiero** un power-up que agrande el rango de melee,  
**para** golpear enemigos desde más lejos.

**Criterios de aceptación:**
- Rango melee: 150px → 280px
- Hitbox del melee_attack.tscn se escala x2
- Duración: 8s
- Visual: hitbox visible con color azul semitransparente

---

### [PU-04] Power-up: Laser
**Como** jugador,  
**quiero** un power-up que convierta mi proyectil en laser,  
**para** que atraviese múltiples enemigos.

**Criterios de aceptación:**
- El proyectil no se destruye al golpear el primer enemigo
- Puede golpear hasta 3 enemigos en línea recta
- Visual: proyectil cambia de color (rojo/cyan)
- Duración: 12s

---

### [PU-05] PowerUpSpawner
**Como** dev,  
**quiero** un spawner dedicado a power-ups,  
**para** que aparezcan de forma controlada durante el nivel.

**Criterios de aceptación:**
- Spawn interval: 20-35s random
- Solo spawnea en Fase 2+ (cuando hay algo con qué atacar)
- Posición random en pantalla, recolectable al tocarlo (player body_entered)
- Máximo 1 power-up visible a la vez en pantalla

---

## ÉPICA 3: Integración y Ajustes

### [INT-01] Mover toda la lógica de combate a rama 'ahi-vienen-los-golpes'
**Como** dev,  
**quiero** que VFX, hazards, balance y power-ups vivan en esa rama,  
**para** tener un punto de integración claro antes de mergear a main.

---

### [INT-02] UI — Indicador de Power-up activo
**Como** jugador,  
**quiero** ver qué power-up tengo activo y cuánto tiempo queda,  
**para** planificar mi estrategia.

**Criterios de aceptación:**
- Ícono del power-up + barra de tiempo en esquina superior
- Desaparece cuando expira
- Animación de "expiración" (parpadeo en los últimos 2s)
