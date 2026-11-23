# THE HOUSE

A first-person psychological survival-horror project for Windows, built with Godot 4.

## Current milestone: prototype foundation

This repository currently contains the first code-driven prototype foundation:
- first-person movement, mouse look, crouching and running;
- a procedural greybox house layout with collision;
- a toggleable flashlight;
- an interactive door;
- a first-pass monster controller with patrol, hearing and line-of-sight pursuit;
- a minimal in-game status HUD.

**Important:** this is an early gameplay prototype, not the finished realistic-art game. The current environment and creature are blockout/procedural placeholders. Production-quality models, PBR texture sets, authored animation, expanded house layout, narrative content, sound design, saving, difficulty balancing and Windows export still need to be built and tested.

## Requirements

- Godot Engine 4.3 or newer (Compatibility renderer)
- Windows, Linux or macOS for editor testing

## Run

1. Download or clone this repository.
2. Open the project folder in Godot 4.
3. Import the project when prompted.
4. Press F5 to run the main scene.

## Controls

| Key | Action |
|---|---|
| W A S D | Move |
| Mouse | Look |
| Shift | Run |
| Ctrl | Crouch |
| E | Interact |
| F | Toggle flashlight |
| Esc | Release mouse; click the game window to recapture |

## Project structure

- scenes/ — Godot scenes
- scripts/ — player, monster, door and world logic
- docs/ — design and development notes

## Development status

See docs/ROADMAP.md for milestone status and acceptance criteria.
