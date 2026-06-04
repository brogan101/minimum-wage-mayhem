# Collision Layer Matrix

To prevent physics glitches (like flying players), all objects must be assigned to these specific layers.

| Layer | Name | Description | Collision Mask (What it hits) |
|---|---|---|---|
| 1 | World | Floors, Walls, Counters | Everything |
| 2 | Player | The Player Character | World, Interactables, Food |
| 3 | Interactables | Buttons, Windows, Doors | Player |
| 4 | Food | Burgers, Cups, Sauce | World, Player, Interactables |
| 5 | Hazards | Spills, Fire, Trash | Player, Food |
| 6 | NPC | Coworkers, Customers | World, Player |

**Rule:** Food items must disable collision with the Player (Layer 2) while being held in the `HoldPosition` to prevent physics explosions.
