

# Introducing Galactic Armada

This guide will help you create a classic shoot-em-up in RGBDS. This isn’t meant to be a “step-by-step tutorial”, mostly a guide. Many portions of the code may not be explained, or may just be given a short explanation. This tutorial is meant to give aspiring RGBDS developers something to  “get the ball rolling” mentally. The source code is available for free on github here: https://github.com/LaroldsJubilantJunkyard/rgbds-shmup. 

[https://github.com/LaroldsJubilantJunkyard/rgbds-shmup](https://github.com/LaroldsJubilantJunkyard/rgbds-shmup)

<aside>
⚠️ **NOTE**: Many macros & functions will be used in this project. I’ll explain some of them near the end and when first used.

</aside>

## Feature set

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


