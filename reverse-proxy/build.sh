#!/bin/bash

# Get the current directory
DIR=$(dirname $0)
if [ "$DIR" = "." ]; then
	DIR=$(pwd)
fi

docker build -t=andreaskoch/reverse-proxy $DIR
