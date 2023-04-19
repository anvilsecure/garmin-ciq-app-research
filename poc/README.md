# Proof-of-concept CIQ Apps

This folder contains PoC apps to demonstrate various vulnerabilities that we identified during the research:

- GRMN-01: Low - Unexpected Object Type with `toString`
- GRMN-04 (CVE-2023-23298): Medium - Integer Overflows in `BufferedBitmap` Initialization
- GRMN-05 (CVE-2023-23304): Medium - `SensorHistory` Permission Bypass
- GRMN-06 (CVE-2023-23305): High - Buffer Overflows in Font Resources
- GRMN-08 (CVE-2023-23303): High - Buffer Overflows in `Toybox.Ant.GenericChannel.enableEncryption`
- GRMN-09 (CVE-2023-23306): High - Relative Out-of-bound Write in `Toybox.Ant.BurstPayload`
- GRMN-10 (CVE-2023-23300): High - Buffer Overflows in `Toybox.Cryptography.Cipher.initialize`
- GRMN-11 (CVE-2023-23306): High - Type Confusion in `Toybox.Ant.BurstPayload`
- GRMN-13 (CVE-2023-23299): High - Permission Bypass via Field Definition Manipulation