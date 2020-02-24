#!/bin/bash

set -e

info="$(~/bin/node_modules/.bin/jira issue | grep In.Progress | cut -d ' ' -f3)"
expire="$(($(date +%s) + 10800))"
curl \
  -H 'Content-type: application/json; charset=utf-8' \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -d '{"profile":{"status_text":"Working on '"$info"' :jira:","status_expiration":"'"$expire"'"}}' \
  https://slack.com/api/users.profile.set

