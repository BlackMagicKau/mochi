# README visuals

The README combines a generated mascot banner with captures of the native app UI.

## Mascot banner

`mochi-banner.png` was generated with the built-in image_gen tool, using the approved A1 character in `design/MochiCharacter.png` as the reference. The image is an illustration, not a screenshot. The runtime did not expose a model identifier.

The prompt requested a wide cream-and-matcha composition with the exact text “Mochi” and “Your Mac, a little closer.”, the approved dumpling at the side, and abstract Mac-window and phone shapes connected by a dotted curve. It requested generous margins, dark tea-green type, no OS interface, no watermark, and no performance claims.

## Native screenshots

- `iphone-connect.png` is captured from the Debug app's existing mock layout harness on an iPhone. Demo device names are fixtures; no network browsing or real screen capture runs in that harness.
- `mac-streaming.png` is rendered from the Mac's native Streaming settings view.

The README identifies these images as previews with demo data. Source screenshots are kept at their original dimensions; the README scales them for display.

### Reproduce the phone screenshot

Build and install the Debug iOS app, then run these commands with your device identifier:

```sh
xcrun devicectl device process launch --device DEVICE_ID --terminate-existing \
  dev.mochi.ios -- -MochiLayout 393x852 -MochiSafeArea 59,0,34,0 \
  -MochiConnectCase homecabledone -MochiExportPreview iphone-connect

xcrun devicectl device copy from --device DEVICE_ID \
  --domain-type appDataContainer --domain-identifier dev.mochi.ios \
  --source Documents/DocumentationPreviews/iphone-connect.png \
  --destination docs/images/iphone-connect.png
```

Leave the device unlocked and allow a few seconds for the preview to render before copying it. The exporter accepts only a short filename and runs only inside the Debug mock harness. It refuses live sessions and captures only the app's window.

After capturing the preview, terminate the app and launch it again without arguments to return to normal use.
