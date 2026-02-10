# Changelog

All notable changes to CombatTextLite will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3] - 2026-02-10

### Note
- **Changes**: No changes to the structure of the code.
  - Version bump: Version was bumped from 0.2 to 0.3.
  - TOC update: Updated `Interface` line in `.toc` file to reflect the current version of WoW Retail.

## [0.2] - 2026-02-02

### Fixed
- **Critical**: Resolved taint errors when opening Edit Mode or clicking ExtraActionButton1
  - Error message: "CombatTextLite has been blocked from an action only available to the Blizzard UI"
  - Root cause: `Settings.RegisterVerticalLayoutCategory` uses Blizzard-managed widgets that internally interact with protected frames
  
### Changed
- **Settings API Implementation**: Switched from `Settings.RegisterVerticalLayoutCategory` to `Settings.RegisterCanvasLayoutCategory`
  - Removed: `Settings.RegisterCVarSetting`, `Settings.RegisterProxySetting`, `Settings.CreateCheckbox`
  - Added: Manual frame creation with `CreateFrame("CheckButton")` for all UI elements
  - Reason: Canvas layout displays custom frames directly without Blizzard's Settings widget intermediaries that cause taint
- **Code structure**: Refactored `CreateSettingsPanel()` to build custom UI instead of using Blizzard's layout system
  - Added `settingsFrame` variable to store custom frame reference
  - Implemented manual checkbox positioning and callbacks
  - Maintained identical SetCVar logic and suppressCallbacks behavior

### Technical Notes
- Investigation process: Analyzed AdvancedInterfaceOptions addon which uses AceConfig framework
- AceConfig also uses `RegisterCanvasLayoutCategory` with custom frames to avoid taint
- Key insight: Blizzard's Settings API widget system interacts with protected frames; custom frames do not
- All functionality remains identical to v0.1 - purely an implementation change to avoid taint

## [0.1] - 2026-02-01

### Added
- Initial release of CombatTextLite
- Master toggle functionality to enable/disable all combat text at once
- Individual CVar controls for:
  - `floatingCombatTextCombatDamage_v2` (Combat Damage)
  - `floatingCombatTextCombatHealing_v2` (Combat Healing)
  - `floatingCombatTextPetMeleeDamage_v2` (Pet Melee Damage)
  - `floatingCombatTextPetSpellDamage_v2` (Pet Spell Damage)
  - `floatingCombatTextCombatLogPeriodicSpells_v2` (Periodic Spells/DoTs/HoTs)
- Settings panel integration using Blizzard's Settings API
- Slash commands: `/ctl toggle`, `/ctl config`, `/ctl help`
- Reload UI button in settings panel
- UI reload notifications when settings change
- Callback suppression to prevent duplicate notifications when master toggle fires
- Localization structure (L table) for future i18n support
- TOC metadata: IconTexture, X-Category, X-Website
- Comprehensive README documentation
- MIT License

### Technical Details
- Used `Settings.RegisterVerticalLayoutCategory` for settings panel (later found to cause taint)
- Used `Settings.RegisterProxySetting` for master toggle
- Used `Settings.RegisterCVarSetting` for individual CVar controls
- Event-driven initialization with `ADDON_LOADED` event
- pcall error handling for settings panel creation
- Event cleanup: Unregisters `ADDON_LOADED` after initialization

### Known Issues (Fixed in v0.2)
- Taint warnings when opening Edit Mode
- Taint warnings when using ExtraActionButton1
- Root cause: Blizzard's Settings API widget system
