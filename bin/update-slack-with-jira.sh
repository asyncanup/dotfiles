#!/bin/bash

set -e

info="$(ypx jira-cl:jira issue | grep In.Progress | cut -d ' ' -f3)"
curl \
  -H 'Content-type: application/json; charset=utf-8' \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -d '{"profile":{"status_text":"Want reviews on :jira: '"$info"'"}}' \
  https://slack.com/api/users.profile.set

