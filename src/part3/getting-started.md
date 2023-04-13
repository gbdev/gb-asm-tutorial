

# Introducing Galactic Armada


![Untitled](../assets/part3/img/rgbds-shmup-gameplay2.gif)

This guide will help you create a classic shoot-em-up in RGBDS. This isn’t meant to be a “step-by-step tutorial”. Many portions of the code may not be explained, or may just be given a short explanation. This tutorial is meant to teach some of the major concepts for creating a shoot-em-up. To view some more details, The source code is available for free on github here: 

[https://github.com/LaroldsJubilantJunkyard/rgbds-shmup](https://github.com/LaroldsJubilantJunkyard/rgbds-shmup)

> ⚠️ **NOTE**: Some of the code snippets may be slightly altered for clarity purposes. In addition, Many macros & functions will be used in this project. Some will be explained, more obvious ones won't be explained. The macros are used to make the code easier to read, and also speed up development. If you're interested in learing about their inner workings, the source code for them is in the repo and commented for explanation.

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


