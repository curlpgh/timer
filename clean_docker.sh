#!/bin/bash

# stop and remove all containers 
# docker stop $(docker ps -a -q)
# docker rm $(docker ps -a -q)

# Stop and remove just the timer container
docker stop timer-app-1
docker rm timer-app-1

# remove all images
# docker rmi $(docker images -a -q)

# Remove just the timer image
docker rmi pghcc/timer:0.1.0

# remove all timer volumes
docker volume rm timer_db-data timer_uploads timer_error_logs