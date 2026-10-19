# Security policy

Mochi captures screen content and can inject input into a paired Mac. Treat pairing codes, device identities, and captured content as private.

## Report a vulnerability

Do not include exploit details, credentials, or private screen content in a regular issue. If GitHub displays **Report a vulnerability** on this repository's **Security** tab, use that private reporting flow. Otherwise, contact a repository maintainer through an existing private channel before sharing details.

This project has no dedicated security mailbox or guaranteed response schedule. Do not send reports about Mochi to the original project's support service.

## Security boundaries

- The packaged Mac app uses TLS and device pairing. Keep pairing required.
- The developer command-line host can use an unencrypted listener unless started with `--pairing`.
- Screen Recording and Accessibility permissions are controlled by macOS.
- Remote access requires your own permitted network configuration. The project does not provide a cloud relay.
- Development builds are not a notarized public release.

Before submitting logs or screenshots, remove pairing codes, private addresses, tokens, keys, device names, and confidential window content.
