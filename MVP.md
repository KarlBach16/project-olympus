# Olympus MVP Plan

## 1. Project Goal

Build a very small playable prototype of a Greek mythology-inspired survivor-like 2D game in Godot.

The goal is not to make a complete game yet.  
The goal is to learn Godot and verify whether the core loop feels fun.

## 2. Core Direction

- Engine: Godot 4.x
- Language: GDScript
- Genre: survivor-like 2D action
- Camera: top-down / 2D field
- Platform target later: iOS / Android
- Current target: desktop prototype

## 3. MVP Scope

### Player

Only one playable character for MVP:

- Achilles

Movement:
- 4-direction movement
- 2-frame walking animation per direction later
- For first prototype, static sprite is acceptable

### Enemy

Only one enemy type:

- Cyclops placeholder enemy

Behavior:
- Spawns around the player
- Moves toward the player
- Deals damage on contact

### Attack

Only one weapon:

- Spear / short-range slash or thrown spear

Behavior:
- Auto-attacks nearest enemy
- Has cooldown
- Deals fixed damage

### Progression

Basic progression only:

- Enemy drops experience orb
- Player collects orb
- Player levels up
- On level-up, immediately apply one random upgrade
- Show a small text notification for the applied upgrade

MVP upgrades:
- Attack damage +1
- Attack speed +10%
- Move speed +10%

Upgrade choice UI is not required for the first prototype.  
For MVP 1.0, level-up can become a 3-choice upgrade screen.

### Death Loop

The player can die and restart the run.

Behavior:
- Player has HP
- Contact damage reduces HP
- At 0 HP, the run ends
- Restart returns to a fresh run quickly

### Boss

One MVP boss:

- Cyclops Boss

Behavior:
- Larger enemy
- More HP
- Simple charge attack with warning delay

Spawn condition:
- After surviving 5 minutes, briefly stop normal spawning
- Display "The Cyclops approaches..."
- Spawn Cyclops Boss
- The run ends in either victory or death

## 4. Out of Scope for MVP

Do not implement these yet:

- Multiple playable characters
- Perseus / Odysseus
- Gods as bosses
- Ares chariot attack
- Medusa petrification
- Item rarity
- Mobile build
- Save data
- Main menu polish
- Sound effects
- Monetization
- Store release
- Story cutscenes
- Localization

## 5. First Playable Target

A successful first prototype means:

- Achilles appears on screen
- Player can move Achilles
- Cyclops enemies spawn
- Achilles auto-attacks
- Enemies can die
- Player gains XP
- Player levels up
- Player can take damage
- Player can die
- Game can restart after death
- Player can survive for 5 minutes
- Cyclops Boss appears
- The run can end in victory or death

## 6. Development Order

### Step 1: Project Setup

- Create Godot project
- Create basic folder structure:
  - scenes/
  - scripts/
  - sprites/
  - ui/

### Step 2: Player Movement

- Create Player scene
- Add CharacterBody2D
- Add Sprite2D
- Add CollisionShape2D
- Add movement script

### Step 3: Enemy

- Create Enemy scene
- Enemy moves toward player
- Enemy damages player on contact

### Step 4: Auto Attack

- Create simple attack scene
- Attack nearest enemy on cooldown
- Enemy HP decreases

### Step 5: Spawner

- Spawn enemies around player
- Increase spawn count slowly over time

### Step 6: Experience and Level Up

- Enemy drops XP orb
- Player collects XP
- Level-up immediately applies one random upgrade
- Show a short text notification for the upgrade

### Step 7: Death and Restart

- Player HP can reach 0
- Show a simple death state
- Restart the run from the beginning

### Step 8: Boss Prototype

- Add Cyclops Boss
- Add delayed charge attack
- Show warning before charge
- Spawn after 5 minutes survived
- End the run after boss victory or player death

## 7. Design Principle

Keep it small.

If a feature does not help test the basic fun of moving, surviving, attacking, leveling, and fighting one boss, do not add it yet.

The MVP should answer one question:

> Would I open Godot tomorrow because I want to, not because I should?
