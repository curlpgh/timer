#!/bin/bash

sudo ls ~/build/timer
cd ~/build/timer
mix deps.get --only prod
MIX_ENV=prod mix compile
cd assets
npm install
npx update-browserslist-db@latest
cd ..
npm run deploy --prefix ./assets
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release timer --overwrite

sudo systemctl stop timer

# Before continuing migrate database if necessary:
# > cd ~
# > PORT=4010  _build/prod/rel/timer/bin/timer start_iex
# > Timer.Release.migrate

