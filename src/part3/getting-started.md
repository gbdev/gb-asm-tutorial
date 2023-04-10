

# Introducing Galactic Armada

This guide will help you create a classic shoot-em-up in RGBDS. This isn’t meant to be a “step-by-step tutorial”. Many portions of the code may not be explained, or may just be given a short explanation. This tutorial is meant to teach some of the major concepts for creating a shoot-em-up. To view some more details, The source code is available for free on github here: 

[https://github.com/LaroldsJubilantJunkyard/rgbds-shmup](https://github.com/LaroldsJubilantJunkyard/rgbds-shmup)

> ⚠️ **NOTE**: Many macros & functions will be used in this project. I’ll explain some of them near the end and when first used.

## Feature set

Here's a list of features that will be included in the final product.

- Vertical Scrolling Background
- Basic HUD (via Window) & Score
- 4-Directional Player Movement
- Enemies
- Bullets
- Enemy/Bullet Collision
- Enemy/Player Collision
- Smooth Movement via Scaled Integers - Instead of using counters, smoother motion can be achieved using 16-bit (scaled) integers.
- Multiple Game States: Title Screen, Gameplay, Story State
- STAT Interrupts - used to properly draw the HUD at the top of gameplay.
- RGBGFX & INCBIN
- Writing Text


