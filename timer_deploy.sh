#!/bin/bash

sudo systemctl stop timer
sudo rm -rf /opt/timer
sudo cp -R _build/prod/rel/timer /opt
sudo ln -s /var/lib/timer/uploads /opt/timer/uploads
sudo chown -R timer: /opt/timer
sudo chown -R timer: /var/lib/timer
sudo systemctl start timer.service
sudo systemctl restart nginx.service
