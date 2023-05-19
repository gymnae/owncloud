#!/bin/bash

nc -zU "/var/run/postgresql" || exit 0

if ! nc -z localhost 9000 then
    exit 1
fi
