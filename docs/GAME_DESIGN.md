# THE HOUSE — Game design brief

## High concept
A first-person psychological survival-horror game for Windows. The player wakes inside an isolated house and must investigate its rooms, evade an unknown creature, solve environmental puzzles and uncover why the building seems to know them.

## Pillars
1. Vulnerability: the player has no reliable way to overpower the creature.
2. Uncertainty: sound, darkness and unreliable perceptions create tension.
3. Readable stealth: the creature uses sight, hearing and last-known-position logic rather than omniscient tracking.
4. Environmental storytelling: rooms, objects, notes and recordings reveal the narrative.
5. Grounded presentation: authored geometry, PBR materials, careful lighting and restrained post-processing.

## Player verbs
Move, look, run, crouch, hide, inspect, pick up, use, unlock, listen and escape.

## Creature design direction
An original non-human presence. Its final silhouette, anatomy, rig and animation language require a dedicated art pass and approval. The current dark capsule is a temporary gameplay placeholder only.

## Psychological systems
A hidden tension value may influence ambience and rare perception events. Hallucinations must be authored and distinguishable in implementation from actual world-state changes; they must not randomly invalidate puzzle logic or trap the player unfairly.

## Scope guard
The first release target is one carefully built house and a complete, replayable escape scenario. Additional locations and chapters are deferred until the core loop is stable.
