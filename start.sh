#!/bin/sh

if [ -z "$RELEASE_NODE" ]; then
    echo "RELEASE_NODE is not set!"
    exit 1
fi

if [ -z "$RELEASE_COOKIE" ]; then
    echo "RELEASE_COOKIE is not set!"
    exit 1
fi

elixir --name $RELEASE_NODE --cookie $RELEASE_COOKIE -S mix run --no-halt
