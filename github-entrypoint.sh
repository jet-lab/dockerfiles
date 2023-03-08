#!/usr/bin/env bash

# Github breaks things by setting a bunch of weird state. This entrypoint is
# intended to override that state back to the way things normally should work in
# this container. Do not use this entrypoint outside of a github workflow, as it
# may have unintended consequences.

export HOME=/home/tools

echo "running command in github-entrypoint.sh: $@"

$@
