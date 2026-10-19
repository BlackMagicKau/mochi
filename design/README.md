# Mochi design assets

The selected Mochi character is A1, the matcha dumpling, from the [character exploration](character-exploration/README.md). The original is `MochiCharacter.png`, a 1254 × 1254 image.

## Product artwork

- `MochiCharacter.png` supplies the Mac's in-app image and the platform icon renderer.
- `../iOSClient/Assets.xcassets/MochiCharacter.imageset` contains the matching iOS image.
- `../Scripts/render-mochi-icon.swift` resizes the original for the Mac icon set and a 1024-pixel iOS icon. It does not redraw the character.
- `../Sources/MochiMenuBar/MochiTheme.swift` and `../iOSClient/ContentView.swift` define the in-app mascot views.

To regenerate icon sizes from the repository root:

```sh
swift Scripts/render-mochi-icon.swift .build/mochi-icons
cp .build/mochi-icons/AppIcon.png iOSClient/Assets.xcassets/AppIcon.appiconset/AppIcon.png
```

The Mac packaging script runs the renderer when its source or character image changes.

## Theme

The native interface uses these colors:

| Role | Hex value |
| --- | --- |
| Cream background | `#FFFBEE` |
| Matcha surface | `#E2EBCE` |
| Tea accent | `#526D39` |
| Dark text | `#34452A` |

The streamed Mac app keeps its own colors. Decorative mascot views are hidden from VoiceOver and do not intercept input.

## Historical assets

`MochiIcon.svg` and `AppIcon.svg` are earlier smiling-window studies. `DMGBackground.svg` is packaging artwork. These files do not replace the selected character image in the current app.

The menu-bar status glyph is a separate monochrome control drawn in `Sources/MochiMenuBar/StatusGlyph.swift`. Character explorations and exact generation prompts remain available under `character-exploration`.
