# Agent instructions

Instructions for AI and human collaborators using tools such as **Cursor** and **Claude** in this repository.

## Project structure

The repo holds two apps for the same product, both backed by the same Supabase project:

- `flutter/`: the Flutter app (Android, iOS). Run Flutter commands from `flutter/` (prefix with `asdf exec`, see `flutter/.tool-versions`). State: `get_it` + `flutter_bloc`; routes in `lib/router.dart`; strings in `lib/l10n/app_en.arb` and `app_es.arb`.
- `swift/`: the native SwiftUI port for iOS 26 (Liquid Glass). `Packages/FamilyCore` holds the entities, scoring, standings and records (`FamilyCore`) and the Supabase repository (`FamilyData`); `FamilyGames/` is the app. Strings are generated from the Flutter `.arb` files plus `swift/scripts/swift_only_strings.json` (`python3 -I swift/scripts/arb_to_xcstrings.py`). Run the package tests with `cd swift/Packages/FamilyCore && swift test`.

The `fg_*` schema lives in the sibling `supabase` repo ([danny270793/supabase](https://github.com/danny270793/supabase)). Never add migrations here. `.env.json` (Flutter) and `swift/FamilyGames/Resources/FamilyConfig.plist` hold the project credentials; never commit them.

Keep both apps in step: a feature or a copy change lands in both, and Settings, About, Privacy and Terms stay the same as in the other Swift apps (Wallet, MMA ScoreCard, Gym Tracker).

## Git commits and branches: explicit user approval is required

**Never commit changes to git unless the user explicitly asks you to.** Make all code changes, then wait for the user to request a commit before running any `git commit` command. Proposing a commit message is fine; running the commit is not.

**Never create a git branch unless the user explicitly asks you to.** Do not run `git branch` or `git checkout -b` (or equivalent) on your own, even to prepare for a commit or Merge Request.

## Pull Requests: use the project template

When creating a GitHub Pull Request, always fill in the description using [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md). GitHub loads that file automatically. Replace each `<!-- … -->` comment with concrete content based on the actual changes. Do not leave placeholder comments in the final description.

## Commits: Conventional Commits (required)

Every commit message **must** follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

### Format

```
<type>[optional scope]: <short description>

[optional body]

[optional footer(s)]
```

- **Description:** imperative mood, lowercase start (a trailing period is not required, but stay consistent).
- **Maximum header length:** keep the first line at ≤ **72** characters when possible.

### Allowed types (common)

Use one of: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.

- **`feat`:** new user-facing behavior or capability.
- **`fix`:** a bug fix.
- **`docs`:** documentation only.
- **`chore`:** maintenance that is not a user-facing feature or fix (dependencies, configuration, tooling).
- **`ci`:** CI/CD pipeline or automation only.

### Scope (optional)

A noun in parentheses after the type, e.g. `fix(postgres): handle null connection string`.

### Breaking changes

Either of:

- add **`!`** after the type/scope: `feat(api)!: remove legacy endpoint`, or
- add a footer: `BREAKING CHANGE: <what changed and what to do>`.

### Examples (valid)

- `feat(examples): add from-code compose sample`
- `fix(ci): use non-tls dind for self-hosted runners`
- `docs: clarify WAL-G vs backup-push in readme`
- `chore: bump gitlab-ci docker image tags`

### Examples (invalid — do not use)

- `Update dockerfile` (missing type)
- `Fixed bug` (not conventional)
- `WIP` / `misc changes`

When proposing or creating commits, **always** use this format. If there are multiple unrelated changes, **split them into several commits** instead of one vague message.
