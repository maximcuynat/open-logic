# Security Policy

## Supported versions

open-logic is pre-1.0: only the latest release receives fixes.

## Reporting a vulnerability

Please **do not open a public issue**. Use GitHub's
[private vulnerability reporting](https://github.com/maximcuynat/open-logic/security/advisories/new)
instead. You should get an acknowledgement within 7 days.

Relevant areas include loading untrusted `.olc` files (the parser must reject
any malformed input safely) and the integrity of release artifacts (every
release ships `SHA256SUMS`).
