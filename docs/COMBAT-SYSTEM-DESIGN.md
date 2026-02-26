# Sistema de Combate — "Ahí Vienen los Golpes"

## Resumen

Esta fase agrega combate al juego: enemigos que se mueven hacia el jugador, ataques del jugador (melee y distancia), y obstáculos especiales que solo se pueden esquivar.

---

## 1. Enemigos

### 1.1 Tipos de Enemigos

| Tipo | HP | Velocidad | Comportamiento | Cómo derrotar |
|------|-----|-----------|----------------|---------------|
| **Slime** | 1 | Lenta | Viene recto hacia el jugador | 1 golpe melee O 2 ataques distancia |
| **Murciélago** | 1 | Media | Viene en diagonal/zigzag | 1 golpe melee O 2 ataques distancia |
| **Esqueleto** | 2 | Media | Viene recto, más resistente | 2 golpes melee O 4 ataques distancia |
| **Fantasma** | 1 | Rápida | Atraviesa obstáculos | Solo ataque distancia (2 hits) |

### 1.2 Spawn de Enemigos

- Los enemigos spawnean **fuera de pantalla** en la dirección del scroll
- Frecuencia aumenta con la dificultad (basada en XP)
- Pueden aparecer solos o en grupos de 2-3
- No spawnean en los primeros 3 segundos del nivel

### 1.3 Colisiones

- Si el enemigo toca al jugador → **Game Over** (igual que obstáculos)
- Si el jugador ataca al enemigo → el enemigo pierde HP
- Si HP llega a 0 → enemigo muere + drop XP bonus

---

## 2. Ataques del Jugador

### 2.1 Ataque Melee (Golpe)

| Propiedad | Valor |
|-----------|-------|
| **Input** | Tap en pantalla (no swipe) |
| **Alcance** | ~150px frente al jugador |
| **Daño** | 2 HP |
| **Cooldown** | 0.4 segundos |
| **Duración** | 0.2 segundos (hitbox activo) |

**Visual:**
- El jugador hace un "punch" o "slash"
- Hitbox rectangular aparece frente a él
- Partículas/efecto de impacto

### 2.2 Ataque a Distancia (Proyectil)

| Propiedad | Valor |
|-----------|-------|
| **Input** | Doble tap en pantalla |
| **Alcance** | Hasta el borde de pantalla |
| **Daño** | 1 HP |
| **Cooldown** | 0.8 segundos |
| **Velocidad** | 800 px/s |
| **Cantidad** | 1 proyectil por ataque |

**Visual:**
- Proyectil pequeño (bola de energía, flecha, etc.)
- Viaja en línea recta hacia donde apunta el scroll
- Se destruye al impactar enemigo o salir de pantalla

### 2.3 Tabla de Daño

| Enemigo | Melee (2 dmg) | Distancia (1 dmg) |
|---------|---------------|-------------------|
| Slime (1 HP) | 1 golpe | 2 proyectiles |
| Murciélago (1 HP) | 1 golpe | 2 proyectiles |
| Esqueleto (2 HP) | 1 golpe | 4 proyectiles |
| Fantasma (1 HP) | ❌ No funciona | 2 proyectiles |

---

## 3. Obstáculos Especiales (Solo Esquivar)

Estos NO se pueden destruir, solo esquivar.

| Tipo | Descripción | Advertencia |
|------|-------------|-------------|
| **Rayo** | Línea vertical/horizontal que cruza la pantalla | Parpadea 0.5s antes de activarse |
| **Onda de choque** | Onda expansiva desde un punto | Círculo rojo crece desde el centro |
| **Trampa de pinchos** | Pinchos que salen del suelo/pared | Brillan antes de activarse |

**Mecánica:**
1. Aparece indicador visual (parpadeo, brillo)
2. 0.5-1 segundo de advertencia
3. Se activa y daña si el jugador está en zona
4. Desaparece después de 0.3 segundos

---

## 4. Niveles Más Largos

### 4.1 Nueva Fórmula de Distancia

```gdscript
# Antes (v1.0)
level_distance = base_distance + (difficulty_level * distance_scale)

# Ahora (v2.0)
level_distance = base_distance + (difficulty_level * distance_scale) + (levels_completed * 100)
```

### 4.2 Progresión

| Nivel | Distancia Base | Con Dificultad 5 | Con 10 niveles completados |
|-------|----------------|------------------|----------------------------|
| Río | 800 | 1050 | 1850 |
| Plataforma | 1000 | 1250 | 2050 |
| Hellevator | 1200 | 1450 | 2250 |
| Abducción | 1000 | 1250 | 2050 |

### 4.3 Checkpoints (Futuro)

- Cada 500 unidades de distancia = checkpoint
- Al morir, respawnear en último checkpoint
- Penalidad de XP reducida (10% en vez de 20%)

---

## 5. XP y Recompensas

| Acción | XP Ganado |
|--------|-----------|
| Moneda | 10 (base) |
| Matar Slime | 15 |
| Matar Murciélago | 20 |
| Matar Esqueleto | 30 |
| Matar Fantasma | 25 |
| Completar nivel | 50 + (10 * difficulty) |
| Esquivar ataque especial | 5 |

---

## 6. Prioridad de Implementación

### Fase 1: Fundamentos
1. Sistema de ataque melee
2. Enemigo básico (Slime)
3. Spawn de enemigos

### Fase 2: Expansión
4. Ataque a distancia
5. Más tipos de enemigos
6. Obstáculos especiales (rayos)

### Fase 3: Polish
7. Efectos visuales
8. Balanceo de dificultad
9. Niveles más largos

---

## 7. Consideraciones Técnicas

### 7.1 Nuevos Nodos Necesarios

```
Enemy (Area2D)
├── Sprite2D
├── CollisionShape2D
├── HitboxArea (Area2D)
│   └── CollisionShape2D
└── HealthComponent

MeleeAttack (Area2D)
├── Sprite2D (animación)
└── CollisionShape2D

Projectile (Area2D)
├── Sprite2D
└── CollisionShape2D

SpecialHazard (Area2D)
├── WarningSprite
├── DamageSprite
└── CollisionShape2D
```

### 7.2 Nuevos Autoloads

- `CombatManager`: maneja cooldowns, daño, combos
- `EnemySpawner`: (por nivel, similar a ObstacleSpawner)

### 7.3 Señales Nuevas

```gdscript
signal enemy_damaged(enemy, damage)
signal enemy_killed(enemy, xp_value)
signal player_attacked(attack_type)
signal hazard_warning(position, type)
signal hazard_activated(position, type)
```
