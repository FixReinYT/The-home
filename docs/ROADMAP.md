# THE HOUSE — Development roadmap

## Milestone 0 — Project foundation
- [x] Create Godot project and main scene
- [x] Add first-person movement and mouse look
- [x] Add flashlight
- [x] Add procedural greybox house and collision
- [x] Add interactive door
- [x] Add first-pass monster patrol/hearing/vision logic
- [ ] Run and validate in Godot 4.3+
- [ ] Fix all parser/runtime errors found during validation

## Milestone 1 — Playable vertical slice
- [ ] Add a complete route through several connected rooms
- [ ] Add functional hiding spots
- [ ] Add item pickup and inventory
- [ ] Add a first puzzle and a locked exit
- [ ] Add monster search states and reliable navigation around obstacles
- [ ] Add death/retry loop
- [ ] Add basic sound cues

## Milestone 2 — Visual production
- [ ] Replace greybox geometry with authored environment meshes
- [ ] Create original monster model and rig
- [ ] Create animation set
- [ ] Add PBR material and texture sets
- [ ] Improve lighting, shadows and post-processing
- [ ] Profile performance at 1080p

## Milestone 3 — Psychological horror and narrative
- [ ] Add tension system and scripted hallucination events
- [ ] Add notes, recordings and environmental storytelling
- [ ] Write and implement the full story
- [ ] Implement and test multiple endings

## Milestone 4 — Release preparation
- [ ] Main menu and settings
- [ ] Save/load
- [ ] Three difficulty presets
- [ ] Accessibility options
- [ ] Windows x64 export
- [ ] Test packaged build on a clean Windows installation

## Acceptance rule

A task is complete only after it is implemented and verified in-engine. A checked item must never be treated as a substitute for a real test.
