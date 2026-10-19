# Mochi development

Read README.md and docs/MOCHI-CHANGES.md for current fork scope and validation.
Historical upstream notes are in docs/upstream/ENGINEERING-NOTES.md; these are adapted engineering history, not current release instructions.

- Native Swift/Apple frameworks only; no third-party runtime dependencies.
- Preserve latency-sensitive capture, transport and input behavior.
- Matcha and cream UI; readable deep tea-green controls; keep video pixels unaltered.
- Keep Mochi identity separate from the original project. Never offer an upstream release as a Mochi update.
- Use Scripts/make-mochi.sh for Mac packaging. It builds locally, does not install or publish.
- Run Scripts/check-mochi.sh after behavior changes. Full iOS validation needs Xcode; do not equate parser checks with compilation.
- Preserve Apache-2.0 license/attribution. Mark modified source files and record changes in docs/MOCHI-CHANGES.md.
