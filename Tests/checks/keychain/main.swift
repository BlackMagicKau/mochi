// Modified for Mochi; see docs/MOCHI-CHANGES.md. Original license and attribution retained in LICENSE and NOTICE.
import Foundation

// Checks IdentityStorePlan.choose (docs/keychain-plan.md §4): which identity store the menu-bar host
// uses for every combination of the four launch facts. The one rule that carries the hardening: an
// entitled real Mochi.app uses the data-protection keychain and never the legacy one; an unentitled
// real Mochi.app uses the legacy keychain; a test host (synthetic, or the bare binary) never touches
// a keychain. Pure, so it runs with no bundle, signature or keychain.

var failures = 0
func check(_ desc: String, _ got: IdentityStoreChoice, _ want: IdentityStoreChoice) {
    if got == want { return }
    failures += 1
    print("FAIL: \(desc): got \(got), want \(want)")
}

let group = "TESTTEAM01.dev.mochi.mac"

// A real Mochi.app (bundled, not synthetic).
check("entitled real app → data-protection under its group",
      IdentityStorePlan.choose(bundled: true, synthetic: false, entitledAccessGroup: group, testRemoteDir: nil),
      .dataProtection(accessGroup: group))
check("entitled app carries the exact access group",
      IdentityStorePlan.choose(bundled: true, synthetic: false, entitledAccessGroup: "TESTTEAM02.dev.mochi.mac", testRemoteDir: nil),
      .dataProtection(accessGroup: "TESTTEAM02.dev.mochi.mac"))
check("unentitled real app → legacy login keychain",
      IdentityStorePlan.choose(bundled: true, synthetic: false, entitledAccessGroup: nil, testRemoteDir: nil),
      .legacy)
check("an empty entitlement is no entitlement → legacy",
      IdentityStorePlan.choose(bundled: true, synthetic: false, entitledAccessGroup: "", testRemoteDir: nil),
      .legacy)
check("a real app ignores MOCHI_TEST_REMOTE_DIR (entitled)",
      IdentityStorePlan.choose(bundled: true, synthetic: false, entitledAccessGroup: group, testRemoteDir: "/tmp/x"),
      .dataProtection(accessGroup: group))
check("a real app ignores MOCHI_TEST_REMOTE_DIR (unentitled)",
      IdentityStorePlan.choose(bundled: true, synthetic: false, entitledAccessGroup: nil, testRemoteDir: "/tmp/x"),
      .legacy)

// Mochi.app run with --synthetic is a test host: never a keychain, even if somehow entitled, and it
// ignores MOCHI_TEST_REMOTE_DIR (only the bare binary takes the file store).
check("Mochi.app --synthetic → memory, never a keychain",
      IdentityStorePlan.choose(bundled: true, synthetic: true, entitledAccessGroup: group, testRemoteDir: nil),
      .memory)
check("Mochi.app --synthetic ignores the test directory",
      IdentityStorePlan.choose(bundled: true, synthetic: true, entitledAccessGroup: nil, testRemoteDir: "/tmp/x"),
      .memory)

// The bare MochiMenuBar binary (not bundled).
check("bare binary → memory",
      IdentityStorePlan.choose(bundled: false, synthetic: false, entitledAccessGroup: nil, testRemoteDir: nil),
      .memory)
check("bare binary ignores an entitlement it should never have → memory",
      IdentityStorePlan.choose(bundled: false, synthetic: false, entitledAccessGroup: group, testRemoteDir: nil),
      .memory)
check("bare binary, not synthetic, with a test dir → still memory (the file store is --synthetic only)",
      IdentityStorePlan.choose(bundled: false, synthetic: false, entitledAccessGroup: nil, testRemoteDir: "/tmp/x"),
      .memory)
check("bare --synthetic with a test dir → the file store",
      IdentityStorePlan.choose(bundled: false, synthetic: true, entitledAccessGroup: nil, testRemoteDir: "/tmp/x"),
      .testDirectory("/tmp/x"))
check("bare --synthetic without a test dir → memory",
      IdentityStorePlan.choose(bundled: false, synthetic: true, entitledAccessGroup: nil, testRemoteDir: nil),
      .memory)

if failures == 0 {
    print("keychain: every case passed (IdentityStorePlan.choose)")
    exit(0)
} else {
    print("keychain: \(failures) FAILED")
    exit(1)
}
