# Troubleshoot Mochi

Start with the symptom that matches your problem. Keep the Mac and iPhone or iPad builds at the same revision when testing.

## Mochi keeps requesting a permission

A permission belongs to the app's code-signing identity. An ad-hoc signature identifies one particular build, so rebuilding can invalidate an earlier approval. Apple describes this behavior in [Inside Code Signing: Requirements](https://developer.apple.com/documentation/technotes/tn3127-inside-code-signing-requirements).

To repair a stale approval:

1. Quit all copies of Mochi.
2. Build with a stable Apple Development identity and install the app at `/Applications/Mochi.app`. Use the same identity for later updates.
3. Open **System Settings > Privacy & Security** and select the affected permission.
4. Remove the existing **Mochi** entry with **−**.
5. Select **+**, choose `/Applications/Mochi.app`, and enable it. You can also drag that exact app from Finder into the list.
6. Open Mochi. For Screen Recording, choose **Quit & Reopen** if macOS prompts you.

Screen Recording permits video capture. Accessibility permits input. Enabling one does not grant the other. Do not change permissions for unrelated apps.

The Mac log reports permission status at launch:

```text
Permissions: Screen Recording allowed; Accessibility allowed.
```

If the settings are disabled by your organization, contact its device administrator. See Apple's [screen recording permission guide](https://support.apple.com/guide/mac-help/mchld6aa7d23/mac).

## The screen is visible, but taps or typing do nothing

1. On the Mac, enable Mochi in **Privacy & Security > Accessibility**.
2. On the iPhone, select **Control** if you are in **Zoom** reading mode.
3. Test pointer movement with **Trackpad**.

Reading mode uses gestures to navigate the picture instead of sending them to the Mac.

## Nothing answers at an address

1. Confirm that Mochi is running on the Mac and that the Mac is awake.
2. Check the connection type. For local Wi-Fi, both devices need to reach each other on the local network. For cellular, configure a permitted remote network path first.
3. Check that the address belongs to an interface reachable from the phone. A Mac-only corporate VPN address is not automatically reachable from cellular.
4. If you are beside the Mac, retry with a cable or use direct wireless discovery.

Do not use an old saved IP address after changing networks without checking that it is still correct. A successful Xcode installation does not prove that the app has a working network connection.

## The Mac does not appear

1. Allow **Local Network** access for Mochi on each device where the option is available.
2. Unlock the iPhone or iPad and confirm that the cable carries data, not only power.
3. Accept the device trust prompt if it appears.
4. For Wi-Fi, avoid guest networks that isolate clients.
5. For nearby direct wireless, enable **Direct Wireless Connection** on the Mac and select **Search Nearby** on the device.

A managed firewall or VPN can affect discovery. Use a network configuration permitted by your organization instead of disabling managed security controls.

## The app stops working when the MacBook closes

Mochi needs a running, awake Mac. A closed lid can put the MacBook to sleep. Leave the lid open for initial testing. If you use a closed-display setup, confirm that the Mac stays awake in that supported setup before testing Mochi.

Mochi does not provide a power-on, wake-on-demand, or pre-login service.

## Xcode cannot sign or install the iPhone app

1. Add your Apple Account in **Xcode > Settings > Accounts**.
2. Select the **Mochi** target and choose your team in **Signing & Capabilities**.
3. Leave **Automatically manage signing** enabled.
4. If the bundle identifier is unavailable to your team, choose a unique identifier that you control.
5. Connect and unlock the device, enable Developer Mode, and accept the computer trust prompt.
6. Run the app from Xcode. If iOS requests developer trust, use **Settings > General > VPN & Device Management**.

If a previously installed development app no longer opens, check whether its provisioning profile expired. Rebuild and reinstall to refresh the development installation.

## The picture is too small to read

1. Use **Apps** to select one window instead of the full desktop.
2. Rotate the phone to landscape when the app needs more width.
3. Use **Zoom** to read, then select **Control** to interact.
4. Use the text-size controls in **More** when appropriate.

Some Mac apps enforce minimum window sizes. The app's window size and Mochi's reading zoom are separate controls.

## Collect diagnostics

In the Mac app, select **Settings > General > Show Log** or **Reveal Log File**. The log is stored at `~/Library/Logs/Mochi/Mochi.log`.

For a bug report, include:

- The source revision from `git rev-parse --short HEAD`.
- The Mac and iPhone or iPad models and OS versions.
- Whether you used a cable, local Wi-Fi, direct wireless, or a remote network.
- The steps that reproduce the problem and the expected result.
- Relevant log lines with private information removed.

Logs and screenshots can contain device names, network addresses, and window titles. Do not include pairing codes, identity keys, private tokens, or confidential screen content.
