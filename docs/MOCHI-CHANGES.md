# Mochi implementation and validation

Mochi is a native Swift Mac and iOS project with independent branding, a matcha interface, and an iPhone layout that gives priority to the streamed app. See [NOTICE](../NOTICE) for source provenance and [the setup guide](../README.md#set-up-mochi) for current installation instructions.

## Product changes

- Replaced product names, Swift module names, Xcode targets, scripts, and connection identifiers with Mochi names.
- Added matcha-and-cream styling to connection flows, pairing, controls, settings, and Mac status views.
- Added the selected A1 matcha-dumpling character to app icons and in-app mascot views. The original image is `design/MochiCharacter.png`.
- Added an iPhone workspace with a compact toolbar, app switching, optional keyboard and trackpad controls, reading zoom, and desktop access.
- Kept the iPad layout separate from the phone workspace.
- Disabled inherited release destinations and automatic update downloads. Historical workflows are stored outside `.github/workflows` and do not run.
- Retained the Apache-2.0 license and original attribution in both application bundles.

## Connection compatibility

Both applications use Mochi's bundle, discovery, pairing, and transport identities. Update both ends together. This project does not promise wire compatibility with the original app or with unrelated forks.

The production Mac app uses encrypted connections and paired-device identities. The developer command-line host can use an unencrypted listener unless started with `--pairing`; use the packaged Mac app for normal use.

## Signing and configuration

The Mac packaging script selects a single available Apple Development identity by default. `MOCHI_SIGN_IDENTITY` overrides the choice. Multiple available identities require an explicit choice. With none available, the script reports an ad-hoc fallback.

Stable signing prevents a changed code hash from becoming the app's entire identity on each rebuild. macOS still controls privacy approval. Install and grant permissions to one copy at `/Applications/Mochi.app`.

The shared Xcode project does not contain a personal development team. Developers can select their own team in Xcode or use the ignored `iOSClient/LocalSigning.xcconfig` file. A shared Mochi scheme supports command-line builds and fresh clones.

## Verified behavior

The following checks were completed during local development:

| Check | Result |
| --- | --- |
| Native builds | Release Mac and signed Debug iPhone builds passed with Xcode 27.1. |
| Signing | Strict signature verification passed for both bundles. |
| Regression checks | All 44 suites passed after the naming update and fixture corrections. |
| Phone geometry | The phone layout suite passed 491 checks. |
| Synthetic integration | Pairing, mutual TLS, and HEVC packet reception passed on loopback with synthetic pixels. |
| Physical iPhone | Installation, launch, and wired video streaming were observed on an iPhone 15 Pro with iOS 26.1. |
| Mac character views | Native previews confirmed that the A1 image appears in settings and status cards. |
| iOS character asset | The compiled asset catalog contains the selected 1254 × 1254 character image. |
| Permission persistence | Screen Recording remained approved after a rebuild and reinstall using the same Apple Development identity. |

These results describe the tested configuration. They do not establish compatibility with every supported OS release, device, or network. Physical usability testing of all phone gestures, keyboard interactions, and app-specific window sizes is ongoing.

## Validation limits

- Cellular and external-network connectivity require a separate reachable network configuration and have not been validated for this installation.
- Foldable-specific SDK integration is disabled and has not been validated on a device.
- Mac audio, simultaneous independent streams, cloud relay service, and public release infrastructure are outside the current implementation.
- Synthetic integration checks do not validate real screen capture or physical touch behavior.
- Older engineering plans describe inherited decisions and experiments. They are historical references, not current release instructions.

## Local artifacts

Build logs, device-install records, provisioning files, personal signing settings, and machine-specific screenshots are excluded from Git. The source tree contains the character originals, reproducible build scripts, shared project files, and regression checks.

## Documentation previews

The README uses a generated banner based on the selected A1 character and native
Mac and iPhone UI captures with demo data. A Debug-only exporter in the existing
iOS layout harness writes the app window to its own Documents directory. It
refuses live sessions, requires a bounded alphanumeric filename, and does not
capture another app or the device status bar. A normal launch has no export
behavior. Reproduction steps are in [README visuals](images/README.md).
