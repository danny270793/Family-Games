# Family Games

Track shared board-game matches and scores with family members. 7 Wonders matches store seven score categories; other games store one point value.

## Quick start

```sh
cp .env.example.json .env.json   # then fill in SUPABASE_URL / SUPABASE_ANON_KEY
./scripts/start.sh
```

Build with `./scripts/build.sh --platform android|ios --mode debug|release`.

## Database

Family Games shares one Supabase project with Wallet, Habit Tracker, and Hangman. Its `fg_*` tables and RPCs live in [danny270793/supabase](https://github.com/danny270793/supabase). Create and apply migrations there, not in this repo.
