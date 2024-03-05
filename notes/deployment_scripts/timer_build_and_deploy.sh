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
sudo rm -rf /opt/timer
sudo cp -R _build/prod/rel/timer /opt
sudo ln -s /var/lib/timer/uploads /opt/timer/uploads
sudo chown -R timer: /opt/timer
sudo chown -R timer: /var/lib/timer
sudo systemctl start timer.service
sudo systemctl restart nginx.service
