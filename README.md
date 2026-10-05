# Family Games

Track shared board-game matches and scores with family members. 7 Wonders matches store seven score categories; other games store one point value.

## Quick start

```sh
cp .env.example.json .env.json   # then fill in SUPABASE_URL / SUPABASE_ANON_KEY
./scripts/start.sh
```

Build with `./scripts/build.sh --platform android|ios --mode debug|release`.

## Database

This repo has the app only. The `fg_*` schema lives in [danny270793/supabase](https://github.com/danny270793/supabase), the source of truth for migrations. Family Games shares that Supabase project with the other apps. To change the database you need both repos:

```sh
git clone git@github.com:danny270793/Family-Games.git
git clone git@github.com:danny270793/supabase.git
```

Create, test, and push migrations from the `supabase` repo. This repo ignores any `supabase/` folder, and `.env.json` holds the project credentials, so never commit it.
