#!/usr/bin/env python3
"""Pair with the built host and receive synthetic HEVC over pinned TLS, on loopback only.

Requires .build/release/MochiHost. No screen capture, real input, keychain or user clipboard.
The temporary client keys and test host's pairing secret are removed at exit.
"""
import os
from pathlib import Path
import re
import ssl
import subprocess
import sys
import tempfile
import time
import urllib.parse

ROOT = Path(__file__).resolve().parent.parent
if not ssl.HAS_TLSv1_3:
    sys.exit("This check needs a Python with TLS 1.3 support. Try python3.13 Scripts/smoke-mochi.py; Apple's bundled Python may use an older LibreSSL.")
binary = ROOT / ".build/release/MochiHost"
if not binary.exists():
    sys.exit("Build the CLI first: swift build -c release --product MochiHost")
env = dict(os.environ)
for key in list(env):
    if key.startswith("MOCHI_TEST_"):
        del env[key]
env.update(MOCHI_TEST_LOOPBACK="1", MOCHI_TEST_SOFTWARE_ENCODER="1", MOCHI_TEST_NO_ROUTER="1")
with tempfile.TemporaryDirectory(prefix="mochi-smoke-", dir=ROOT / ".build") as temporary:
    work = Path(temporary)
    host_log = work / "host.log"
    with host_log.open("w") as output:
        # The remote door binds a free port and puts that port in its QR link. A home-only
        # link intentionally carries no home address/port (normal clients already discovered it).
        host = subprocess.Popen([str(binary), "--synthetic", "--pairing", "--remote", "--no-clipboard"],
                                cwd=ROOT, env=env, stdout=output, stderr=subprocess.STDOUT)
        try:
            deadline = time.monotonic() + 25
            link = None
            while time.monotonic() < deadline and host.poll() is None:
                match = re.search(r"mochi://pair\?\S+", host_log.read_text())
                if match:
                    link = match.group(0)
                    break
                time.sleep(0.1)
            if not link:
                sys.exit("FAIL: synthetic host did not offer a Mochi pairing link within 25 seconds.")
            port = urllib.parse.parse_qs(urllib.parse.urlsplit(link).query)["p"][0]
            result = subprocess.run([
                sys.executable, str(ROOT / "Scripts/mochiclient.py"), port, "5", "desktop",
                "--host=127.0.0.1", "--pair-url=" + link, "--identity=" + str(work / "client"),
                "--expect-pair=ok", "--hello=0.1.0,1", "--fps=30",
            ], cwd=ROOT, env=env, capture_output=True, text=True, timeout=35)
            received = re.search(r"TOTAL (\d+) frames", result.stdout)
            if result.returncode or not received or int(received.group(1)) == 0:
                # Never print the ephemeral pairing link or generated client credentials.
                print("FAIL: pairing or synthetic video reception failed.")
                detail = (result.stdout + "\n" + result.stderr).replace(link, "<temporary pairing link>")
                print(detail[-6000:])
                for line in result.stdout.splitlines():
                    if line.startswith(("EXPECT", "TOTAL", "PAIR FAIL")):
                        print(line)
                sys.exit(1)
            print("PASS: Mochi QR-link pairing, mutual TLS, and synthetic HEVC reception on loopback.")
            print("Received " + received.group(1) + " encoded frames in 5 seconds (not a device latency benchmark).")
        finally:
            if host.poll() is None:
                host.terminate()
                try:
                    host.wait(timeout=8)
                except subprocess.TimeoutExpired:
                    host.kill()
                    host.wait()
