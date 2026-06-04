# MASTER IMPLEMENTATION ROADMAP: Sir, This Is A Drive-Thru

## 🚩 PROJECT STATUS: "THE LOGIC ENGINE"
- **Current State:** All core systemic logic (Managers) is implemented. Basic 3D movement and procedural world scripts are written.
- **The Gap:** The project lacks physical scenes (.tscn), 3D assets (.glb), UI layouts, and a connected game loop.
- **The Goal:** Transition from a "Code Repository" to a "Playable 3D Experience."

---

## 🛠 PHASE 1: THE PHYSICAL FOUNDATION (The "Greybox" Era)
*Goal: Get the game runnable in Godot with a basic, functional 3D environment.*

### 1.1 Scene Construction (The .tscn Layer)
- [ ] **Main Scene**: Create `Main.tscn` to handle the game state and scene transitions.
- [ ] **Player Scene**: Build `Player.tscn` with a `CharacterBody3D`, `Camera3D`, `RayCast3D` (for interaction), and `Marker3D` (for holding items).
- [ ] **Restaurant Layout**: Execute `WorldGenerator.gd` to create the 3D boundaries.
- [ ] **Station Scenes**: Create physical scenes for the Grill, Fryer, Drink Machine, and Bagging Table.
- [ ] **Window Scene**: Build the `DriveThruWindow.tscn` with a sliding animation.

### 1.2 Input & Physics Tuning
- [ ] **Input Map**: Fully configure `project.godot` with WASD, Sprint, Interact, Throw, and View Toggle.
- [ ] **Physics Material**: Create "Slippery" and "Bouncy" physics materials for food and spills.
- [ ] **Collision Layers**: Setup layers for `Player`, `Interactable`, `Food`, and `World` to prevent physics glitches.

---

## 🍔 PHASE 2: THE TACTILE LOOP (The "Meat" of Gameplay)
*Goal: Make the act of making food feel satisfying and physical.*

### 2.1 The Assembly Pipeline
- [ ] **Physical Merging**: Implement the `FoodAssembler` logic so that placing a patty on a bun physically creates a "Burger" object.
- [ ] **State Visuals**: Connect the `FoodItem` state (Raw $\rightarrow$ Cooked $\rightarrow$ Burnt) to the `food_cook.gdshader`.
- [ ] **Bagging Logic**: Create a "Snap-to-Bag" system where food physically enters the bag.

### 2.2 The Drive-Thru Interface
- [ ] **The Window Hand-off**: Create a "Receive Zone" at the window that triggers the `OrderManager` validation.
- [ ] **The HUD**: Build the `GameHUD.tscn` with the Order Checklist, Beef Bar, and Cash display.
- [ ] **Voice Prototype**: Implement a "Press-to-Speak" button that triggers a "Tone Selector" (Professional/Savage).

---

## 🌪️ PHASE 3: THE CHAOS & DRAMA (The "Funny" Layer)
*Goal: Turn the shift into a stressful, comedic experience.*

### 3.1 NPC Intelligence
- [ ] **Crew Spawning**: Implement `NPCSpawner` to populate the kitchen with coworkers.
- [ ] **Behavioral AI**: Use `NavigationAgent3D` so NPCs walk to their stations and get in the player's way.
- [ ] **Drama Triggers**: Connect `EmployeeAI` to the `EventLog` to trigger "Calling Out" or "Hiding in the Freezer."

### 3.2 Conflict Resolution
- [ ] **Beef Battle UI**: Create a dialogue-choice pop-up for the "Verbal Duel" when Beef hits 100.
- [ ] **Chaos Director Integration**: Connect `ChaosDirector` to physical events (e.g., the drink machine actually spraying water).
- [ ] **Shady Acts**: Map physical interactions to the `CrimeSystem` (e.g., clicking the register for 2 seconds = Skimming).

---

## 🏠 PHASE 4: THE LIFE SIM & PROGRESSION (The "Grind")
*Goal: Give the player a reason to keep playing another shift.*

### 4.1 The Apartment Hub
- [ ] **The 3D Room**: Build a small apartment scene where the player can walk around.
- [ ] **Interactable Furniture**: Create the Bed, Gaming PC, and Coffee Maker as physical objects that update `StatManager`.
- [ ] **Upgrade Shop**: A simple menu to spend `WalletManager` cash on better furniture.

### 4.2 Career & Persistence
- [ ] **Save/Load System**: Implement JSON serialization for Rank, Cash, and Apartment upgrades.
- [ ] **Promotion Logic**: Trigger a "Promotion Ceremony" (funny pop-up) when `CareerManager` hits a new rank.
- [ ] **The HR Report**: Create a visual "End-of-Shift" screen that parses the `EventLog` into a funny report.

---

## 🎨 PHASE 5: THE COMMERCIAL POLISH (The "Steam" Layer)
*Goal: Make the game look and sound like a finished product.*

### 5.1 Visuals & Audio
- [ ] **Asset Swap**: Replace CSG Boxes with CC0 Low-Poly models (from Kenney.nl).
- [ ] **Material Pass**: Apply PBR textures to the floor, walls, and equipment.
- [ ] **Soundscape**: Implement the `AudioManager` with real .wav files for sizzling, honking, and screams.
- [ ] **Animation**: Add "Sway" to the camera and "Wobble" to the food items.

### 5.2 Final Validation
- [ ] **Balance Pass**: Tune the `ChaosDirector` budget so the game isn't too hard too fast.
- [ ] **Bug Hunt**: Fix "Item Clipping" and "Physics Explosions."

---

## 🌟 CONTENT & EASTER EGGS (The "Secret Sauce")

### 🎁 Hidden Content
- [ ] **The Secret Menu**: Finding a hidden "Corporate Manual" in the office unlocks weird orders (e.g., "The Void Burger").
- [ ] **The Golden Mop**: A rare spawn that makes the player move 2x faster but leaves a trail of glitter.
- [ ] **The CEO's Visit**: A random event where the CEO comes in; if you serve him a burnt burger, you get a "Promotion by Mistake."
- [ ] **The Haunted Fryer**: A rare event where the fryer starts talking to the player.

### 🍟 Absurd Details
- [ ] **Sauce Physics**: Sauce packets that can be thrown and "splat" on walls.
- [ ] **Customer Reactions**: Customers who drive away and leave a "1-star review" in real-time on the HUD.
- [ ] **The Mascot Suit**: A punishment that physically changes the player's model and limits their vision.

---

## 📌 REFERENCE GUIDE FOR AI
**When the user says "Reference the doc," check:**
1. **Current Phase**: Which phase are we in?
2. **Remaining Tasks**: What checkboxes are still `[ ]`?
3. **System Links**: Which manager is being affected by the current task?
4. **Requirement Check**: Does this change align with the "Fully 3D Walk-around" rule?
