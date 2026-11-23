# THE HOUSE

A first-person psychological survival-horror project for Windows, built with Godot 4.

## Current milestone: expanded environment prototype

The current branch contains:
- first-person movement, mouse look, crouching and running;
- a procedural multi-room mansion layout with foyer, salon, dining room, kitchen, library and bedroom;
- furnished environment props including sofa, dining set, kitchen counters, cabinets, bookcases, books, bed, windows and lighting fixtures;
- basic material variation, emissive window glass and room lighting;
- runtime-synthesized low-frequency ambience, distant creaks and a proximity heartbeat layer (temporary audio implementation, not final recorded sound design);
- flashlight, interactive exit door and first-pass monster patrol/hearing/line-of-sight pursuit;
- main menu, settings screen and pause menu;
- automated Windows x64 export workflow.

## Important visual-status disclosure

The mansion is currently assembled from procedural Godot meshes and primitive material resources. It is a larger, furnished blockout/art pass, **not photorealistic production art**. It does not yet contain authored high-poly asset packs, scanned PBR texture sets, a finished monster model/rig, animation library, authored soundscape or final narrative campaign. The current build must not be described as a finished 4–5 hour game.

## Run

1. Download or clone this repository.
2. Open the project folder in Godot 4.3.
3. Import the project when prompted.
4. Press F5.

## Controls

| Key | Action |
|---|---|
| W A S D | Move |
| Mouse | Look |
| Shift | Run |
| Ctrl | Crouch |
| E | Interact |
| F | Toggle flashlight |
| Esc | Pause / release mouse |

## Build

GitHub Actions exports a Windows x64 executable and uploads a ZIP artifact. The exported game still requires testing on a real Windows installation.

## Project structure

- scenes/ — Godot scenes
- scripts/ — player, monster, menu, world and environment builder
- docs/ — design and development notes

See docs/ROADMAP.md for remaining work and quality gates.
