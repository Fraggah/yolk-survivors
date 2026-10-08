# Current weapon artwork

Ten original weapon drawings generated and edited with the built-in image_gen tool. Players/Player_1.png provides the bold charcoal outline reference. Characters and weapon gameplay were not changed.

- InGame/: current horizontal, right-facing sprites on a 200x100 canvas.
- Icons/: the exact game sprites, rotated 35 degrees counterclockwise and fitted to 200x200.
- Source/: current full-resolution drawings, retained for future editing.
- Tools/: current build script, canvas bounds, outline adjustments and generation prompts.

Obsolete original textures and discarded redesign images were removed after approval. Historical scene snapshots and restoration scripts remain in art_backups/weapons_before_redesign, but restoring the old appearance now requires recovering the removed images separately. Weapons/Icons/weapon_punch_icon.png remains because shop and inventory card scenes reference it. The separate chainsaw icon was not part of the ten redesigned weapons.

Rebuild the current pairs from the project directory:

```powershell
& './assets/sprites/Weapons/Redesign/Tools/build_weapon_assets.ps1'
```

This current builder uses stored bounds and requires no old textures. It fits each source, applies the ink underlay and rotates the finished game sprite into its UI icon. Scene anchors, animation scripts, muzzle markers, collision shapes and balance values are preserved. Tools/outline_character_match.json records the current generation prompts and output paths.
