#!/bin/bash

# Description:
# Starts a docker registry and an
# Nginx as a reverse proxy with
# basic authentication for the docker registry

# Get the current directory
DIR=$(dirname $0)
if [ "$DIR" = "." ]; then
	DIR=$(pwd)
fi

# Get the AWS S3 Parameters
AWS_BUCKET=$1
if [ -z "$AWS_BUCKET" ]; then
    >&2 echo 'Please specify a name for the AWS Bucket you want to use for the registry (e.g. "docker-registry-xyz")'
	exit 1
fi

AWS_KEY=$2
if [ -z "$AWS_KEY" ]; then
    >&2 echo 'Please specify a AWS Key for the registry (e.g. "JKHJHIUIH3232HJH")'
	exit 1
fi

AWS_SECRET=$3
if [ -z "$AWS_SECRET" ]; then
    >&2 echo 'Please specify a AWS Secret for the registry (e.g. "dksadjkljsa/DSKHdsalkdjklas2dsajkjlkKLJLKHG")'
	exit 1
fi

containerNamePrefix="docker-registry"

# kill running containers
runningContainers=$(docker ps -q "$containerNamePrefix-*")
if [ ! -z "$runningContainers" ]; then
    killResult=$(docker kill $runningContainers)
fi

# remove existing containers
stoppedContainers=$(docker ps -q -a "$containerNamePrefix-*")
if [ ! -z "$stoppedContainers" ]; then
    removeResut=$(docker rm $stoppedContainers)
fi

# Start the registry
docker run -d --name docker-registry-1 -e SETTINGS_FLAVOR=s3 -e STORAGE_PATH=/registry -e AWS_BUCKET=$AWS_BUCKET -e AWS_KEY=$AWS_KEY -e AWS_SECRET=$AWS_SECRET -e SEARCH_BACKEND=sqlalchemy registry
if [[ $? != 0 ]]; then
    >&2 echo 'Could not start the docker registry.'
	exit 1
fi


# Start Nginx with the registry linked to it
docker run -d --name docker-registry-nginx --link docker-registry-1:BACKEND -p 80:80 -p 443:443 -v "$DIR/sites:/etc/nginx/conf.d" andreaskoch/reverse-proxy
if [[ $? != 0 ]]; then
    >&2 echo 'Could not start the reverse proxy.'
	exit 1
fi

# Success
exit 0
