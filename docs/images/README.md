# README visuals

The README combines a generated mascot banner with captures of the native app UI.

## Mascot banner

`mochi-banner.png` was generated with the built-in image_gen tool, using the approved A1 character in `design/MochiCharacter.png` as the reference. The image is an illustration, not a screenshot. The runtime did not expose a model identifier.

The prompt requested a wide cream-and-matcha composition with the exact text “Mochi” and “Your Mac, a little closer.”, the approved dumpling at the side, and abstract Mac-window and phone shapes connected by a dotted curve. It requested generous margins, dark tea-green type, no OS interface, no watermark, and no performance claims.

## Native screenshots

- `iphone-xcode-live.png` is an unedited screenshot of a real iPhone streaming the Mac's Xcode window over a cable, with the optional trackpad collapsed.
- `iphone-xcode-trackpad.png` captures the same live session in portrait with the trackpad open.
- `iphone-connect.png` is captured from the Debug app's existing mock layout harness on an iPhone. Demo device names are fixtures; no network browsing or real screen capture runs in that harness.
- `mac-streaming.png` is rendered from the Mac's native Streaming settings view.

The README separates live-use screenshots from setup previews with demo data. Source screenshots are kept at their original dimensions; the README scales them for display.

### Capture a live session

1. Open the Mochi project in Xcode and display a source file that is suitable for publication.
2. Connect the iPhone by cable, unlock it, and open Mochi.
3. Connect to the Mac and select the Xcode window in **Apps**.
4. Rotate the iPhone to landscape and wait for the live stream to settle.
5. Capture the device's display. These images use [pymobiledevice3's device screenshot command](https://github.com/doronz88/pymobiledevice3/blob/master/docs/guides/cli-recipes.md):

   ```sh
   uv tool run --from pymobiledevice3 pymobiledevice3 developer dvt screenshot \
     --userspace --udid DEVICE_ID iphone-xcode-live.png
   ```

6. Rotate to portrait, tap **Trackpad**, and capture a second image as `iphone-xcode-trackpad.png`.
7. Review both images before publishing. Keep account information, notifications, private source, and unrelated windows out of the screenshots.

These captures include the live video and the native iPhone controls. The mock preview exporter does not run during this process. No streamed content is generated or composited into the images.

### Reproduce the connection preview

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
