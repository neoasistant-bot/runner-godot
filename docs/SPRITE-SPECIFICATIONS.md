# Especificaciones de Sprites — Sistema de Combate

Este documento detalla todos los sprites necesarios para implementar el sistema de combate, con especificaciones técnicas exactas.

---

## 1. Formato General

| Propiedad | Valor |
|-----------|-------|
| **Formato** | PNG (con transparencia) |
| **Color Mode** | RGBA 32-bit |
| **Estilo** | Pixel Art |
| **Resolución base** | 16x16 o 32x32 píxeles |
| **Escala en juego** | 3x - 4x (se escalan en Godot) |

**Nota:** Todos los sprites deben tener fondo transparente y estar centrados en el canvas.

---

## 2. Sprites de Enemigos

### 2.1 Slime

| Propiedad | Valor |
|-----------|-------|
| **Tamaño** | 16x16 px |
| **Frames de animación** | 2-4 (idle wobble) |
| **Colores sugeridos** | Verde (#4CAF50), morado (#9C27B0), o azul (#2196F3) |
| **Hitbox** | 14x12 px (centrado) |

**Descripción visual:**
- Blob gelatinoso simple
- Ojos pequeños (2-3px)
- Animación de "respiración" o wobble
- Puede tener brillo/reflejo

```
Frame 1:        Frame 2:
  ████            ████
 ██████          ██████
████████        ████████
 ██████         ████████
  ████           ██████
```

### 2.2 Murciélago

| Propiedad | Valor |
|-----------|-------|
| **Tamaño** | 16x16 px |
| **Frames de animación** | 4 (alas batiendo) |
| **Colores sugeridos** | Gris oscuro (#424242), morado (#7B1FA2) |
| **Hitbox** | 12x8 px (centrado) |

**Descripción visual:**
- Vista frontal o lateral
- Alas extendidas en frames alternos
- Ojos rojos brillantes (1-2px)
- Orejas puntiagudas

```
Frame 1 (alas arriba):    Frame 2 (alas abajo):
    ▲▲                        ▲▲
   ████                      ████
  ██████                    ██  ██
 ▲██████▲                  ██    ██
```

### 2.3 Esqueleto

| Propiedad | Valor |
|-----------|-------|
| **Tamaño** | 16x24 px (más alto) |
| **Frames de animación** | 4 (caminando) |
| **Colores sugeridos** | Blanco hueso (#F5F5F5), gris (#9E9E9E) |
| **Hitbox** | 12x20 px |

**Descripción visual:**
- Figura humanoide simplificada
- Cráneo visible con cuencas de ojos
- Costillas o torso esquelético
- Brazos y piernas de huesos

```
  ██
 ████     ← Cráneo
  ██
 ████     ← Torso
  ██
 █  █     ← Piernas
```

### 2.4 Fantasma

| Propiedad | Valor |
|-----------|-------|
| **Tamaño** | 16x20 px |
| **Frames de animación** | 2-3 (flotando) |
| **Colores sugeridos** | Blanco semi-transparente (#FFFFFF, alpha 70%) |
| **Hitbox** | 10x14 px |

**Descripción visual:**
- Forma de sábana/hoja clásica
- Ojos negros o huecos
- Borde inferior ondulado
- Efecto de transparencia/brillo

```
   ████
  ██████
 ████████
 ██ ██ ██    ← Ojos
 ████████
  ▼  ▼  ▼    ← Borde ondulado
```

---

## 3. Sprites del Jugador (Ataques)

### 3.1 Ataque Melee

| Propiedad | Valor |
|-----------|-------|
| **Tamaño** | 32x16 px (horizontal) |
| **Frames** | 3 (swing animation) |
| **Colores** | Amarillo/dorado (#FFD54F) para efecto de golpe |
| **Duración** | 0.2 segundos total |

**Descripción visual:**
- Arco de ataque frente al jugador
- Efecto de "slash" o "whoosh"
- Líneas de movimiento
- Puede ser puño, espada, o energía

```
Frame 1:      Frame 2:      Frame 3:
    ╱             ─             ╲
   ╱             ───             ╲
  ╱             ─────             ╲
```

### 3.2 Proyectil (Ataque Distancia)

| Propiedad | Valor |
|-----------|-------|
| **Tamaño** | 8x8 px |
| **Frames** | 2-4 (rotación o pulso) |
| **Colores** | Cyan (#00BCD4), amarillo (#FFEB3B), o blanco |
| **Trail** | Opcional, 3-4 frames de estela |

**Descripción visual:**
- Bola de energía, flecha, o shuriken
- Brillo central
- Efecto de movimiento/cola

```
Bola:         Flecha:       Shuriken:
  ██            ▶▶           ╲ ╱
 ████                         ╳
  ██                         ╱ ╲
```

---

## 4. Sprites de Obstáculos Especiales

### 4.1 Rayo (Warning + Active)

| Propiedad | Valor |
|-----------|-------|
| **Tamaño Warning** | 16x pantalla (línea vertical) o pantalla x 16 (horizontal) |
| **Tamaño Active** | Mismo, pero con efecto de energía |
| **Colores Warning** | Rojo semi-transparente (#F44336, alpha 50%) |
| **Colores Active** | Amarillo brillante (#FFEB3B) con blanco central |

**Descripción visual:**
- Warning: línea parpadeante roja
- Active: rayo eléctrico con zigzag

```
Warning:          Active:
    │                ╱╲
    │               ╱  ╲
    │              ╱    ╲
    │               ╲  ╱
    │                ╲╱
```

### 4.2 Onda de Choque

| Propiedad | Valor |
|-----------|-------|
| **Tamaño** | 64x64 px (expandible) |
| **Frames** | 4-6 (expansión) |
| **Colores** | Rojo (#F44336) → naranja (#FF9800) |

**Descripción visual:**
- Círculo que crece desde el centro
- Borde más grueso, interior transparente
- Efecto de energía/ondas

### 4.3 Trampa de Pinchos

| Propiedad | Valor |
|-----------|-------|
| **Tamaño** | 16x16 px (tile) |
| **Frames** | 2 (oculto → extendido) |
| **Colores** | Gris metálico (#607D8B), punta roja opcional |

**Descripción visual:**
- Pinchos triangulares
- Base metálica
- Salen del suelo/pared

```
Oculto:       Extendido:
              ▲ ▲ ▲
████████      ████████
```

---

## 5. Efectos Visuales

### 5.1 Impacto de Golpe

| Propiedad | Valor |
|-----------|-------|
| **Tamaño** | 16x16 px |
| **Frames** | 4-5 (explosión) |
| **Colores** | Blanco → amarillo → naranja |
| **Duración** | 0.15 segundos |

### 5.2 Muerte de Enemigo

| Propiedad | Valor |
|-----------|-------|
| **Tamaño** | 24x24 px |
| **Frames** | 5-6 |
| **Colores** | Blanco con partículas |

### 5.3 Partículas de XP

| Propiedad | Valor |
|-----------|-------|
| **Tamaño** | 4x4 px o 8x8 px |
| **Frames** | 2 (brillo) |
| **Colores** | Amarillo/dorado (#FFD700) |

---

## 6. Spritesheet Recomendado

Para eficiencia, combinar en spritesheets:

### enemies_spritesheet.png (64x64)
```
┌────┬────┬────┬────┐
│Slm1│Slm2│Bat1│Bat2│  16x16 cada celda
├────┼────┼────┼────┤
│Bat3│Bat4│Skl1│Skl2│
├────┼────┼────┼────┤
│Skl3│Skl4│Gho1│Gho2│
├────┼────┼────┼────┤
│Gho3│    │    │    │
└────┴────┴────┴────┘
```

### attacks_spritesheet.png (64x32)
```
┌────┬────┬────┬────┐
│Mel1│Mel2│Mel3│Proj│  16x16 / 32x16 para melee
├────┼────┼────┼────┤
│Proj│Proj│Proj│    │
└────┴────┴────┴────┘
```

---

## 7. Herramientas Recomendadas

| Herramienta | Uso | Precio |
|-------------|-----|--------|
| **Aseprite** | Pixel art + animación | $20 (o compilar gratis) |
| **Piskel** | Pixel art web | Gratis |
| **Libresprite** | Fork gratuito de Aseprite | Gratis |
| **Pixilart** | Editor web | Gratis |

---

## 8. Resumen de Assets Necesarios

| Categoría | Cantidad | Prioridad |
|-----------|----------|-----------|
| Slime (idle) | 2-4 frames | 🔴 Alta |
| Murciélago (volar) | 4 frames | 🔴 Alta |
| Esqueleto (caminar) | 4 frames | 🟡 Media |
| Fantasma (flotar) | 2-3 frames | 🟡 Media |
| Ataque melee | 3 frames | 🔴 Alta |
| Proyectil | 2-4 frames | 🔴 Alta |
| Impacto | 4-5 frames | 🟡 Media |
| Rayo warning | 1-2 frames | 🟢 Baja |
| Rayo active | 2-3 frames | 🟢 Baja |
| Muerte enemigo | 5-6 frames | 🟡 Media |

**Total mínimo para MVP:** ~30 frames individuales

---

## 9. Si Usás Assets de Kenney

Ya tenemos assets de Kenney. Podemos adaptar:

| Necesitamos | Tile Kenney sugerido |
|-------------|---------------------|
| Slime | tile_0072 (blob) o tile_0073 |
| Murciélago | tile_0024 (Characters) |
| Esqueleto | tile_0011-0014 (Characters) |
| Fantasma | tile_0025 (Characters) con transparencia |
| Proyectil | tile_0151 (moneda) recoloreada |
| Pinchos | tile_0048 o tile_0049 |

**Ventaja:** Consistencia visual con lo existente.
**Desventaja:** Menos personalización.
