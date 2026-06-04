# Asset Sourcing Plan

## General Policy
The game will use exclusively free, open-source, public-domain, CC0, or permissively licensed assets that allow commercial use and Steam release.

## Primary Sources
- **Poly Haven**: CC0 textures, HDRIs, and models.
- **ambientCG**: CC0 PBR textures.
- **Kenney.nl**: CC0 3D assets, UI, and audio.
- **OpenGameArt**: Verified CC0/CC-BY assets only.

## Asset Rules
- **Prefer CC0**: No attribution required, maximum freedom.
- **Strict Commercial Check**: No GPL or ShareAlike licenses.
- **Parody Only**: No real-world fast-food branding.
- **No AI Assets**: Unless commercial rights are explicitly clear and local.
- **No Paid Assets**: All assets must be zero-cost.

## Needed Asset Categories
- **Restaurant**: Low-poly walls, floors, counters, and lighting.
- **Equipment**: Grills, fryers, drink machines, and registers.
- **Food**: Burger patties, buns, fries, soda cups, sauce packets.
- **Environment**: Parking lot, customer cars, street lamps.
- **Characters**: Stylized cartoon humans.
- **UI**: Clean, goofy icons and buttons.
- **Audio**: Sizzling, car engines, buzzer, cash register, voice clips.

## Procedural Fallbacks
If a specific asset cannot be found under a CC0 license:
- Use `CSG` nodes in Godot to build a "blocky" version.
- Use `StandardMaterial3D` with solid colors.
- Log the fallback in `ASSET_VALIDATION.md`.
