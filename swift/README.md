# Family Games — SwiftUI (iOS 26, Liquid Glass)

Native port of the [Flutter app](../flutter). Same Supabase project and `fg_*`
tables and functions, so both apps can be used side by side with the same account.

Requires **Xcode 26** and the **iOS 26 simulator/SDK**.

## Quick start

```sh
cp swift/FamilyConfig.example.plist swift/FamilyGames/Resources/FamilyConfig.plist   # then fill in real values
open swift/FamilyGames.xcodeproj
```

The values are the same as the Flutter `.env.json` (`SUPABASE_URL`,
`SUPABASE_ANON_KEY`). Without the file the app shows a "not configured" screen.

## Behind a corporate network

If sign-in fails with `NSURLErrorDomain -1200` / `-9802`, a corporate network
service is inspecting TLS and the simulator doesn't trust its root CA. Trust the
CA in the booted simulator (or pass `all`):

```sh
swift/scripts/trust_dev_proxy_cert.sh path/to/corporate_root_ca.pem
swift/scripts/trust_dev_proxy_cert.sh path/to/corporate_root_ca.pem all
```

Keep the certificate out of git (`*.pem` is ignored).

## Layout

| Path | What |
|---|---|
| `Packages/FamilyCore/Sources/FamilyCore` | Entities, scoring rules, standings, win series and records. No I/O. |
| `Packages/FamilyCore/Sources/FamilyData` | Supabase repository (`fg_games` queries and the `fg_*` functions). |
| `Packages/FamilyCore/Tests` | Swift Testing suites; the Flutter `test/standings_test.dart` cases are ported here. |
| `FamilyGames/App` | App entry, session and games model, preferences (language, theme, Face ID), navigation. |
| `FamilyGames/Features` | Sign-in, games, game detail with statistics, match editor, game settings, app settings and legal pages. |
| `FamilyGames/Components` | Labels, colors and small shared views. |
| `FamilyGames/Resources` | Assets and `Localizable.xcstrings` (English and Spanish). |

The project uses a synchronized folder, so new files under `FamilyGames/` are
picked up by Xcode automatically.

## Tests

```sh
cd swift/Packages/FamilyCore && swift test
```

## Strings

`Localizable.xcstrings` is generated from the Flutter `.arb` files (same keys,
ICU plurals become `key#one` variants) plus `scripts/swift_only_strings.json`.
After changing either:

```sh
python3 -I swift/scripts/arb_to_xcstrings.py
```

## Screens

- **Games** — your games with players and your record; pull to refresh, `+` to create one.
- **Game** — statistics (date range, wins over time chart, records, standings) and the match list; **New match** records one.
- **Match** — date and time, who played, and the score: one total, or the seven 7 Wonders categories.
- **Game settings** — add or remove players by email, edit or delete the game.

Settings (email, password, Face ID, language, theme), About, Privacy policy and Terms of use open from the toolbar and match the other Swift apps.
