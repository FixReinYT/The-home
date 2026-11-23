# THE HOUSE — Game design brief

## High concept
A first-person psychological survival-horror game for Windows. The player investigates an isolated house, evades an intelligent creature, solves interconnected environmental puzzles and uncovers why the building seems to know them.

## Target playtime
- **First-time normal playthrough:** approximately 4–5 hours.
- **Expert speedrun:** a route of approximately 60 minutes should be possible after the player has learned the layout, puzzle solutions and enemy behaviours.
- The one-hour route is an ambitious lower-bound target, not the expected experience for a first-time player.
- Playtime must come from meaningful exploration, puzzle chains, stealth encounters, story discoveries and deliberate pacing—not empty corridors, repetitive backtracking or artificial timers.

## Pillars
1. **Vulnerability:** the player cannot reliably overpower the creature and must use stealth, planning and the environment.
2. **Uncertainty:** sound, darkness and carefully authored unreliable perceptions create tension.
3. **Readable stealth:** the creature uses sight, hearing, investigation and last-known-position logic rather than omniscient tracking.
4. **Environmental storytelling:** rooms, objects, notes and recordings reveal the narrative and reward careful exploration.
5. **Grounded presentation:** authored environment meshes, coherent PBR materials, detailed props, deliberate lighting and restrained post-processing.
6. **Fair challenge:** deaths and puzzle failures should teach the player something; difficulty must not depend on arbitrary hidden rules.

## Player verbs
Move, look, run, crouch, hide, inspect, pick up, manage inventory, combine and use items, unlock, listen, solve mechanisms and escape.

## Intended game structure
The full experience should be divided into distinct story chapters or major acts within the house and its connected spaces. Each section must introduce a new narrative revelation, location identity, puzzle objective or meaningful change in the creature's behaviour. The complete route must form one coherent story rather than a sequence of disconnected fetch quests.

A production outline should specify:
- the protagonist, their motivation and personal stakes;
- the house's history and the central mystery;
- the creature's origin, rules and relationship to the protagonist;
- the chapter/act progression and major reveals;
- critical-path objectives and optional discoveries;
- puzzle dependencies and item flow;
- multiple endings, if supported by the final narrative.

These story specifics remain to be designed; they are not established canon yet.

## Creature design direction
An original non-human presence. Its final silhouette, anatomy, rig and animation language require a dedicated art pass and approval. The current dark capsule is a temporary gameplay placeholder only. The creature needs authored animation, readable sensory rules, search behaviour, chase escalation and fair counterplay.

## Psychological systems
A hidden tension value may influence ambience and rare perception events. Hallucinations must be authored and distinguishable in implementation from actual world-state changes; they must not randomly invalidate puzzle logic or trap the player unfairly.

## Scope and quality gates
The first release target is one substantial, interconnected house and its surrounding/connected spaces, with enough authored content for a 4–5 hour first playthrough and a learnable expert route of about one hour.

Do not claim the game is complete based on a launch menu, a small greybox map or an executable export. A milestone is complete only after its playable content has been tested in-engine. Before release, the full critical path must be completable from a clean save, all required puzzles and items must work, enemy encounters must be fair, and the exported Windows build must be tested on a Windows machine.
