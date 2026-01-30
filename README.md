# CombatTextLite

A lightweight World of Warcraft addon that provides simple, streamlined control over floating combat text settings. Reduce visual noise and keep your screen clear during high-intensity encounters.

## Features

- **Master Toggle**: Enable or disable all combat text options with a single click or command
- **Individual Control**: Fine-tune which types of combat text you want to see
- **Clean Interface**: Integrated settings panel in the Blizzard Options menu
- **Quick Commands**: Easy-to-use slash commands for on-the-fly adjustments
- **One-Click Reload**: Built-in UI reload button to apply changes instantly

## Installation

1. Download the latest release
2. Extract the `CombatTextLite` folder to your WoW AddOns directory:
   - `World of Warcraft\_retail_\Interface\AddOns\`
3. Restart World of Warcraft or reload your UI with `/reload`
4. The addon will confirm it's loaded in your chat window

## Usage

### Slash Commands

CombatTextLite supports the following commands using `/ctl`:

- `/ctl toggle` - Toggle all floating combat text on or off
- `/ctl config` or `/ctl settings` - Open the settings panel
- `/ctl help` - Display available commands
- `/ctl` - Display available commands

### Settings Panel

Access the settings panel via:
- `/ctl config` command
- ESC → Options → AddOns → CombatTextLite

The settings panel includes:
- **Toggle All Combat Text** - Master switch for all combat text
- **Individual Settings**:
  - Combat Damage - Show damage you deal
  - Combat Healing - Show healing you receive
  - Pet Melee Damage - Show pet melee damage
  - Pet Spell Damage - Show pet spell damage
  - Periodic Spells - Show DoT/HoT damage and healing
- **Reload UI Button** - One-click UI reload to apply changes

### Combat Text Options

Each option directly controls Blizzard's native CVars:
- `floatingCombatTextCombatDamage_v2`
- `floatingCombatTextCombatHealing_v2`
- `floatingCombatTextPetMeleeDamage_v2`
- `floatingCombatTextPetSpellDamage_v2`
- `floatingCombatTextCombatLogPeriodicSpells_v2`

> **Note**: After changing settings, you must reload your UI (`/reload`) for changes to take effect. CombatTextLite will remind you when changes are made.

## Requirements

- World of Warcraft: The War Within (Interface 120000+)
- No additional dependencies required

## Development

### File Structure
```
CombatTextLite/
├── CombatTextLite.lua    # Main addon code
├── CombatTextLite.toc    # Addon metadata
├── README.md             # This file
├── LICENSE               # MIT License
└── deploy.bat            # Development deployment script
```

### Building
For development, use the included `deploy.bat` script to copy files to your WoW AddOns directory.

## Known Limitations

- Settings changes require a UI reload (`/reload`) to take effect - this is a Blizzard CVar limitation, not an addon limitation
- The master toggle uses the first CVar (Combat Damage) to determine the current state of all options

## Version History

### v0.1 (Current)
- Initial release
- Master toggle functionality
- Individual combat text controls
- Integrated settings panel
- Slash command support
- UI reload notifications

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Paradox.Actual**

## Acknowledgments

- Built using the Blizzard Settings API for seamless integration
- Thanks to the WoW addon development community for documentation and support

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests on the [GitHub repository](https://github.com/iccugs/CombatTextLite).

## Support

If you encounter any issues or have suggestions:
1. Check that you're running the latest version
2. Try `/reload` to ensure the addon is properly loaded
3. Submit an issue on GitHub with details about your problem

---

**CombatTextLite** - Keep combat readable and your screen clear.
