# Dome Keeper - Custom Maps

Created by **Sachtleben**

## Overview
Custom Maps is a ModLoader extension for *Dome Keeper* that allows you to easily configure custom map boundaries before starting a run. It injects a native-styled settings menu into the Loadout screen where you can specify your exact desired map properties (Width and Depth) to challenge yourself or create massive sprawling underground worlds!

## Features
* **Full Custom Size Control**: Set your exact desired Map Width and Depth.
* **Native UI Integration**: The settings menu is seamlessly integrated and perfectly matches the base game's dark mode visual identity via palette shaders.
* **Safe Boundaries**: Hardcoded lower limits (minimum 40x40) to prevent engine crashes or soft-locks during the procedural world generation.
* **Input Isolation**: Background input blocking ensures you don't accidentally navigate the underlying loadout menus while configuring your map.

## Installation

### Steam Workshop
Simply subscribe to the mod on the Steam Workshop, and it will be downloaded and installed automatically.

### Manual Installation
1. Pack the `Sachtleben-CustomMaps` folder into a `.zip` archive.
2. Place the `.zip` file into your Dome Keeper `mods` directory (usually found in `%AppData%\Godot\app_userdata\Dome Keeper\mods`).
3. Launch the game and ensure the mod is enabled in the Mod Tool menu.

## Source Code & Developer Setup
If you are a modder looking to explore the source code, contribute, or run the mod directly from an unpacked Dome Keeper development environment:

1. **Prerequisites**: You must have a decompiled/reconstructed Dome Keeper project (e.g., via GDRE Tools) opened in Godot 4.2.2, with the Godot ModLoader initialized.
2. **Clone the Repository**: Navigate to your project's `mods-unpacked` folder and clone this repository directly into it.
   ```bash
   cd path/to/dome-keeper-recovery/mods-unpacked
   git clone https://github.com/YOUR_USERNAME/Sachtleben-CustomMaps.git Sachtleben-CustomMaps
   ```
3. **Launch**: Open the project in Godot, run the game, and the ModLoader will automatically detect and compile the unpacked source directory.

## Development Area

### Generating the Thumbnail
If you wish to update the Steam Workshop preview icon in the future, a standalone Godot script is included in the mod repository. 

To run it, execute the following command from your console using the Godot 4.2.2 executable:

```powershell
# Adjust path to the godot executable as necessary
& "path/to/godot.exe" -s mods-unpacked/Sachtleben-CustomMaps/generate_thumbnail.gd
```

This will automatically generate a perfectly crisp, 512x512 pixel-art `preview.png` inside the repository folder, featuring removed background boxes, transparent layers, and dynamically remapped UI color palettes to perfectly match the Dome Keeper theme.
