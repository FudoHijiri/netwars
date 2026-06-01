# NetWars - Project Handoff

## Project Overview
NetWars is a **Godot 4.6 cybersecurity education card game** with two factions: **VOID** (red/dark) and **SENTINEL** (blue/light). Players engage in turn-based card battles using Agent, Exploit, and Protocol card types. The game includes Firebase authentication for user accounts and matchmaking/lobbies (currently in progress).

## Current Architecture

### Core Navigation Flow
```
TitleMenu (entry point)
├── Play Button → PlaySelectionMenu (Offline/Online)
├── Login Button → LoginRegister (Firebase auth)
├── Settings Button → SettingsMenu (volume, difficulty)
└── Exit Button → Quit game

During Gameplay (GameBoard)
└── ESC or Pause Button → PauseMenu (overlay, not scene change)
    ├── Resume → Return to game
    ├── Settings → SettingsPanel (overlay within PauseMenu)
    └── Quit Match → TitleMenu
```

### Key Architectural Decisions
- **PauseMenu as CanvasLayer overlay**: Preserves GameBoard state when accessing in-game settings
- **Settings split**: TitleMenu has SettingsMenu.tscn; gameplay has PauseMenu settings panel overlay
- **Firebase signals**: Uses signal connections (not await) with proper signatures: `login_succeeded(auth)`, `login_failed(error_code, message)`
- **Dynamic card assets**: Cards load textures based on faction/type: `"Void Agent Card.png"`, `"Sentinel Protocol Card.png"`, etc.
- **MenuManager singleton**: Centralized navigation with load_menu() function

## Current State

### ✅ Completed Features
- Card template system with dynamic faction/type-specific visuals
- Card drag-and-drop mechanics with collision detection
- Turn-based battle system with AI difficulty levels (Easy/Medium/Hard)
- Pause/Main Menu system during gameplay
- Settings menu with volume control and difficulty selection
- Firebase Authentication (login/register flow working)
- Dedicated LoginRegister scene separate from title menu
- PauseMenu with in-game settings overlay
- Card CSV database system
- Proper navigation flow across all menus

### ⚠️ Known Issues / Pending Tasks
1. **Matchmaking/Lobbies**: User wants only hosting and join lobbies (not matchmaking)
   - Remove MatchmakingQueue.tscn
   - Implement simple hosting/join UI instead
2. **MainMenu.tscn**: Deprecated and removed from navigation but may still exist in project
   - Consider deleting if not being used elsewhere
3. **Firebase state persistence**: Auth state not persisted across scene changes
   - May need to store in MenuManager or autoload
4. **Online mode**: PlaySelectionMenu routes to Online but no scene exists
   - Need to create OnlineMenu.tscn or hosting/lobby scene

## File Structure

### Scenes (Godot 4.6 .tscn files)
- **Scenes/TitleMenu.tscn** - Entry point with 4 buttons (Play, Login, Settings, Exit)
- **Scenes/LoginRegister.tscn** - TabContainer with Login and Register tabs
- **Scenes/PlaySelectionMenu.tscn** - Offline/Online game mode selection
- **Scenes/SettingsMenu.tscn** - Title menu settings (volume, difficulty)
- **Scenes/PauseMenu.tscn** - In-game pause overlay + settings panel
- **Scenes/GameBoard.tscn** - Main game board
- **Scenes/Card.tscn** - Card template (drag-and-drop, texture loading)
- **Scenes/Menus/OnlineMenu.tscn** - Placeholder for online mode (needs implementation)
- **Scenes/Menus/MatchmakingQueue.tscn** - Deprecated (scheduled for removal)

### Scripts (GDScript)
- **Scripts/MenuManager.gd** - Singleton, centralized navigation
- **Scripts/TitleMenuController.gd** - Button handlers for title menu
- **Scripts/LoginRegisterController.gd** - Firebase authentication
- **Scripts/PlaySelectionMenuController.gd** - Game mode selection
- **Scripts/SettingsMenuController.gd** - Title menu settings
- **Scripts/PauseMenuController.gd** - Pause menu + settings overlay
- **Scripts/GameBoardController.gd** - Game board management
- **Scripts/Card.gd** - Player card logic (drag, place, asset loading)
- **Scripts/OpponentCard.gd** - Opponent card logic
- **Scripts/BattleManager.gd** - Turn-based battle logic

### Firebase Configuration
- **addons/godot-firebase/.env** - Firebase credentials (apiKey, projectId, etc.)
- **addons/godot-firebase/** - GodotFirebase addon (pre-installed)
- Reference example: **GodotFirebaseTutorial-master/** (for API validation)

## Critical Code Patterns

### Firebase Authentication (Godot 4.6 Correct API)
```gdscript
# Login (NOT sign_in)
Firebase.Auth.login_with_email_and_password(email, password)
Firebase.Auth.login_succeeded.connect(_on_login_succeeded)

# Signup (NOT sign_up)
Firebase.Auth.signup_with_email_and_password(email, password)
Firebase.Auth.signup_succeeded.connect(_on_signup_succeeded)

# Handlers
func _on_login_succeeded(auth):  # auth object passed
    pass

func _on_login_failed(error_code: String, message: String):  # error info passed
    pass
```

### Audio Volume Control (Godot 4.6)
```gdscript
# Use linear_to_db() NOT linear2db()
AudioServer.set_bus_volume_db(bus_index, linear_to_db(slider_value))
```

### Card Dynamic Asset Loading
```gdscript
func _load_card_template():
    var faction = card_data.faction  # "Void" or "Sentinel"
    var card_type = card_data.type   # "Agent", "Exploit", or "Protocol"
    var asset_name = "{faction} {card_type} Card.png".format({
        "faction": faction,
        "card_type": card_type
    })
    var path = "res://Assets/{asset_name}".format({"asset_name": asset_name})
    $TextureRect.texture = load(path)
```

### Menu Navigation Pattern
```gdscript
# In MenuManager
func go_to_title_menu():
    load_menu("res://Scenes/TitleMenu.tscn")

func load_menu(scene_path: String):
    if current_menu:
        current_menu.queue_free()
    current_menu = load(scene_path).instantiate()
    add_child(current_menu)
```

## How to Test

### Firebase Login/Register
1. Open TitleMenu
2. Click "Login" button
3. Switch between Login and Register tabs
4. Test with valid Firebase credentials
5. Verify back button returns to TitleMenu

### In-Game Pause Menu
1. Start a game (Offline mode)
2. Press ESC or click Pause button
3. Verify Resume resumes game
4. Click Settings, verify overlay shows
5. Click Back in Settings, verify returns to pause menu
6. Click Quit Match, verify returns to TitleMenu

### Card Gameplay
1. Start game, verify cards load with correct faction textures
2. Drag cards to hand and board
3. Verify AI takes turns
4. Test difficulty levels affect AI behavior

## Next Steps (Priority Order)

1. **Remove Matchmaking** - Delete MatchmakingQueue.tscn, implement simple hosting/join UI
2. **Test Firebase End-to-End** - Verify login/register flow works with real Firebase project
3. **Online Mode** - Implement lobby/hosting scene for OnlineMenu
4. **Game Logic Polish** - Balance AI difficulty, card effects, win conditions
5. **UI Polish** - Refine visuals, animations, responsiveness

## Important Gotchas

1. **PauseMenu is CanvasLayer**: Uses `process_mode = 3` (PROCESS_MODE_ALWAYS) to pause everything else
2. **Settings duplication**: Two separate settings implementations (TitleMenu vs in-game)
   - TitleMenu: SettingsMenu.tscn (scene change, returns to title)
   - In-game: PauseMenu settings panel (overlay, stays in-game)
3. **Back button behavior varies**:
   - From Title menus: `MenuManager.go_to_title_menu()`
   - From gameplay: `_open_pause_menu()` NOT `go_to_title_menu()`
4. **Firebase state not persisted**: Logging out then back won't restore previous session
5. **Signal names differ from Web SDK**: Use `login_with_email_and_password()` not `signInWithEmailAndPassword()`

## Git Status
Current branch: `main`
Modified files include scene changes and script fixes (see `git status` for full list).

## Contact / Questions
- Project uses Godot 4.6 with GodotFirebase addon
- Reference example code: `GodotFirebaseTutorial-master/` for Firebase API validation
- Card asset naming: `{Faction} {Type} Card.png` e.g., "Void Agent Card.png"
