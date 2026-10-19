#!/bin/bash
# usage: build.sh WT OUT [AddressList.swift override] [PairingWindow.swift override]
WT=$1; OUT=$2; T=$(mktemp -d)
cp $WT/Sources/StreamProtocol/*.swift $T/
sed '/^import StreamProtocol$/d' ${3:-$WT/Sources/MochiHost/AddressList.swift} > $T/AddressList.swift
sed '/^import StreamProtocol$/d' ${4:-$WT/Sources/MochiHost/PairingWindow.swift} > $T/PairingWindow.swift
cp $WT/Sources/MochiHost/OriginPolicy.swift $T/
cp $(dirname $0)/main.swift $T/main.swift
swiftc -O $T/*.swift -o $OUT 2>&1 | grep -E "error" ; rm -rf $T
