# NetWars: Cyber Card Battles

A cybersecurity-themed educational desktop card game built in Godot 4.6.
Players battle using cybersecurity concepts as cards — attackers (VOID) vs defenders (SENTINEL).
Designed for non-technical users as an educational tool.

---

## Project Status

| System | Status |
|---|---|
| UI (Title, Settings, Credits) | ✅ Complete |
| Offline vs AI | ✅ Complete |
| Online Matchmaking | ✅ Complete |
| Lobby Hosting and Joining | ✅ Complete |
| Card Drag and Drop | ✅ Complete |
| Card Database (CSV) | ✅ Complete |
| Firebase Auth (Login/Register) | ✅ Complete |
| Match History and Winrate | ✅ Complete |
| Core Game Loop | 🔧 In Progress |
| Card Effects Logic | 🔧 In Progress |
| Rule-Based AI | 🔧 In Progress |

---

## Objectives

1. Identify cybersecurity threats and defense concepts suitable for non-technical users and implement them as 100 playable cards.
2. Develop core gameplay mechanics including turn-based gameplay, card deployment rules, Energy system, and rule-based AI opponent behavior.
3. Implement login and register using Firebase Authentication with hashed, salted, and peppered passwords. Each player has a match history showing wins, losses, and a percentage-based winrate for data mining purposes.
4. Implement online play with random matchmaking, public and private lobby hosting, and lobby invite by code.

---

## Tech Stack

| Technology | Purpose |
|---|---|
| Godot 4.6 | Game engine and all game logic |
| GDScript | Primary scripting language |
| GD-Sync | Multiplayer networking, matchmaking, and lobbies |
| Firebase Authentication | User login and registration |
| Firebase Firestore | Cloud storage for player profiles, match history, winrate |
| LibreSprite | Pixel art card sprites (40x56px base, scaled 3x to 120x168px in Godot) |
| CSV | Local card database loaded at runtime |

---

## Project Structure

```
res://
├── assets/
│   ├── sprites/
│   │   ├── cards/          ← 40x56px pixel art card sprites
│   │   └── ui/             ← UI elements, icons, backgrounds
│   └── fonts/              ← Pixel bitmap fonts
│
├── data/
│   └── cards.csv           ← Full 100-card database (see Card CSV Format below)
│
├── scenes/
│   ├── menus/
│   │   ├── TitleMenu.tscn  ← Play, Settings, Credits, Exit
│   │   ├── PlayMenu.tscn   ← Offline or Online choice
│   │   ├── OfflineMenu.tscn ← AI difficulty selection
│   │   ├── OnlineMenu.tscn ← Matchmaking, Host Lobby, Join Lobby
│   │   ├── LobbyMenu.tscn  ← Lobby room screen (public/private toggle, room code)
│   │   ├── Settings.tscn
│   │   └── Credits.tscn
│   ├── auth/
│   │   ├── Login.tscn
│   │   └── Register.tscn
│   ├── game/
│   │   ├── Board.tscn      ← Main game board
│   │   ├── Card.tscn       ← Individual card scene
│   │   ├── CardSlot.tscn   ← Board slot for placing cards
│   │   └── HandSlot.tscn   ← Player hand display
│   └── ui/
│       ├── HUD.tscn        ← In-game HUD (HP, Energy, turn indicator)
│       └── Tooltip.tscn    ← Card tooltip popup on hover
│
└── scripts/
    ├── autoload/
    │   ├── CardDatabase.gd ← Loads cards.csv, global singleton
    │   ├── GameState.gd    ← Holds current match state, global singleton
    │   └── FirebaseManager.gd ← Handles all Firebase calls, global singleton
    ├── menus/
    │   ├── TitleMenu.gd
    │   ├── PlayMenu.gd
    │   ├── OfflineMenu.gd
    │   └── OnlineMenu.gd
    ├── auth/
    │   ├── Login.gd
    │   └── Register.gd
    ├── game/
    │   ├── Board.gd        ← Game loop, turn management, win condition
    │   ├── Card.gd         ← Card display, drag and drop, hover
    │   ├── CardSlot.gd     ← Slot logic, accepts/rejects dropped cards
    │   ├── HandManager.gd  ← Player hand management
    │   ├── DeckManager.gd  ← Deck shuffling, drawing
    │   ├── CombatManager.gd ← Attack resolution, damage calculation
    │   ├── EffectManager.gd ← Card effect execution
    │   └── ProtocolManager.gd ← Face-down Protocol trigger checking
    └── ai/
        └── AIOpponent.gd   ← Rule-based AI (Easy, Medium, Hard)
```

---

## Card CSV Format

File location: `res://data/cards.csv`

```
id,name,faction,type,energy,atk,hp,effect,tooltip
VD-A01,Virus,VOID,AGENT,1,2,1,"On play: deal 1 damage to opponent HP","A virus is malicious code that spreads by attaching itself to other programs"
SN-A01,Firewall,SENTINEL,AGENT,3,0,6,"Taunt. Blocks the first Exploit played against you each turn","A firewall filters network traffic using rules to block unauthorized access"
```

### CSV Column Reference

| Column | Type | Description |
|---|---|---|
| id | String | Unique card ID e.g. VD-A01, SN-P15 |
| name | String | Display name of the card |
| faction | String | VOID or SENTINEL |
| type | String | AGENT, EXPLOIT, or PROTOCOL |
| energy | int | Energy cost to play |
| atk | int | Attack stat (0 for non-AGENT cards) |
| hp | int | HP stat (0 for non-AGENT cards) |
| effect | String | One-line mechanic description |
| tooltip | String | Plain English educational description |

### Loading Cards in GDScript

```gdscript
# CardDatabase.gd (Autoload)
extends Node

var all_cards: Array = []

func _ready():
    _load_csv()

func _load_csv():
    var file = FileAccess.open("res://data/cards.csv", FileAccess.READ)
    var headers = file.get_csv_line()
    while not file.eof_reached():
        var row = file.get_csv_line()
        if row.size() < 9: continue
        all_cards.append({
            "id": row[0], "name": row[1], "faction": row[2],
            "type": row[3], "energy": int(row[4]), "atk": int(row[5]),
            "hp": int(row[6]), "effect": row[7], "tooltip": row[8]
        })

func get_faction(faction: String) -> Array:
    return all_cards.filter(func(c): return c.faction == faction)

func get_by_id(id: String) -> Dictionary:
    return all_cards.filter(func(c): return c.id == id).front()
```

---

## UI Flow

```
Launch
  └── TitleMenu
        ├── Play
        │     ├── Offline
        │     │     ├── Easy
        │     │     ├── Medium
        │     │     └── Hard → Board.tscn (vs AI)
        │     └── Online
        │           ├── Matchmaking → auto-paired → Board.tscn
        │           ├── Host Lobby
        │           │     ├── Public (visible in lobby list)
        │           │     └── Private (room code required)
        │           └── Join Lobby → enter room code → Board.tscn
        ├── Settings
        ├── Credits
        └── Exit
```

---

## Game Rules Summary

### Win Condition
Reduce opponent HP from 30 to 0.

### Turn Structure
1. Draw 1 card
2. Gain 1 Energy (max 10, increases each round)
3. Play cards by spending Energy
4. Attack with Agents
5. End turn

### Card Types

| Type | Behavior |
|---|---|
| AGENT | Stays on board. Has ATK and HP. Cannot attack the turn it is played (summoning sickness). Both Agents deal damage to each other simultaneously on attack. |
| EXPLOIT | One-time use. Effect resolves immediately. Goes to discard. |
| PROTOCOL | Set face-down on board. Activates automatically when its trigger condition is met. Goes to discard after triggering. |

### Combat Rules
- Agents cannot attack the turn they are played
- Each Agent attacks once per turn
- If a Taunt Agent is on opponent's board, all attacks must target it first
- Attacking opponent HP directly is only allowed if no Taunt Agents are present
- Both Agents deal their ATK to each other simultaneously
- Agents at 0 HP go to discard

### Deck Rules
- Exactly 30 cards per deck
- Maximum 2 copies of any card
- Faction locked (VOID only or SENTINEL only)
- Starting hand: 5 cards

---

## Card Factions

| Faction | Theme | Background Color | Border Color |
|---|---|---|---|
| VOID | Attacker / malware side | #cf98ff | #3c008f |
| SENTINEL | Defender / security side | #79b1ff | #00219e |

### Card Type Colors (both factions)

| Type | Border | Art Box | Text Box |
|---|---|---|---|
| AGENT | #FF3300 | #FF8070 | #CC3322 |
| EXPLOIT | #FF8800 | #FFD080 | #CC7700 |
| PROTOCOL | #00CC66 | #80FFB8 | #229955 |

### Universal Energy Icon Color
#00E5FF (cyan) — used across all cards and factions

---

## Authentication

Uses Firebase Authentication for login and registration.

### Password Security
Passwords are hashed using SHA-256 with both salt (random per user, stored in Firestore) and pepper (hardcoded app-level secret, not stored in database).

```gdscript
func hash_password(password: String, salt: String) -> String:
    var pepper = "NETWARS_PEPPER_KEY"
    var salted = password + salt + pepper
    return salted.sha256_text()
```

### Firestore User Document Structure

```
users/{uid}/
    username: String
    email: String
    password_hash: String
    salt: String
    created_at: Timestamp
    wins: int
    losses: int
    winrate: float        ← recalculated after every match (wins / total * 100)
    match_history: Array
        └── { opponent: String, result: "win"/"loss", date: Timestamp }
```

---

## Multiplayer (GD-Sync)

GD-Sync is built on top of Godot's High-Level Networking API using ENet as the transport layer.

```
GD-Sync (matchmaking, lobbies, sync)
        ↓
Godot High-Level Networking API (RPCs)
        ↓
ENet (data transport)
```

### Matchmaking

```gdscript
func find_match():
    var lobbies = await GDSync.get_lobby_list()
    if lobbies.size() > 0:
        GDSync.join_lobby(lobbies[0]["id"])
    else:
        GDSync.create_lobby("public_match", {"max_players": 2, "visible": true})
```

### Host Lobby

```gdscript
# Public lobby
GDSync.create_lobby("host_match", {"max_players": 2, "visible": true})

# Private lobby (room code generated by GD-Sync)
GDSync.create_lobby("private_match", {"max_players": 2, "visible": false})
```

### Join by Code

```gdscript
GDSync.join_lobby_by_code(room_code)
```

---

## Rule-Based AI

Located at `res://scripts/ai/AIOpponent.gd`

The AI evaluates the board state each turn and picks actions using priority rules.

### Difficulty Levels

| Difficulty | Behavior |
|---|---|
| Easy | Plays cards randomly. Attacks randomly. Does not consider Taunt. |
| Medium | Plays highest ATK Agent available. Targets lowest HP enemy Agent. Uses Exploits when advantageous. |
| Hard | Prioritizes removing Taunt Agents first. Plays Protocols defensively. Calculates lethal damage. Saves high-cost Exploits for key targets. |

### AI Decision Order (Medium and Hard)

```
1. Check for lethal — can I win this turn?
2. Remove Taunt Agents blocking my attacks
3. Play the strongest Agent I can afford
4. Use Exploits to remove threatening enemy Agents
5. Set Protocols face-down if Energy remains
6. Attack with all available Agents
```

---

## Sprite Specifications

- Base canvas: 40x56 pixels (LibreSprite)
- Display size in Godot: 120x168 pixels (3x scale)
- Import filter: Nearest (no blurring)
- Format: PNG

### Card Layout at 40x56

```
┌──────────────────────────────────────┐
│ [TYPE]                      [ENERGY] │  rows 1-4
│  ┌──────────────────────────────┐    │
│  │                              │    │
│  │          ART BOX             │    │  rows 5-30
│  │                              │    │
│  └──────────────────────────────┘    │
│ [ CARD NAME ]                        │  rows 31-34
│ ┌────────────────────────────────┐   │
│ │  effect text                   │   │  rows 35-50
│ └────────────────────────────────┘   │
│ [ATK]                        [HP]    │  rows 51-56
└──────────────────────────────────────┘
```

---

## Known Conventions

- All card IDs follow the format `FACTION_PREFIX-TYPE_PREFIX+TWO_DIGIT_NUMBER`
  - VOID Agents: VD-A01 to VD-A20
  - VOID Exploits: VD-E01 to VD-E15
  - VOID Protocols: VD-P01 to VD-P15
  - SENTINEL Agents: SN-A01 to SN-A20
  - SENTINEL Exploits: SN-E01 to SN-E15
  - SENTINEL Protocols: SN-P01 to SN-P15
- GDScript follows Godot 4.x syntax (not Godot 3)
- All Firebase calls go through `FirebaseManager.gd` autoload only
- All card data reads go through `CardDatabase.gd` autoload only
- Scene transitions use `get_tree().change_scene_to_file()`
- Nearest-neighbor scaling must be set on all card sprite imports

---

## Team

- Fudo (Iyashmar M. Abdullah)
- Christan Dave R. Castillo
- Rafael A. Marsaga

Institute of Computing, Davao del Norte State College (DNSC), Panabo City
