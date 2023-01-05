#!/bin/sh

local profile='spin'

if [ -z "$ENV_PROFILE" ] && [ -n "$profile" ]
  export ENV_PROFILE=$profile
fi
