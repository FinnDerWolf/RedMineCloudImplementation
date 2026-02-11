#!/usr/bin/env bash
set -euo pipefail

MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-180}"

check_instance() {
  BASE_URL="$1"

  echo "==> Waiting for Redmine at: $BASE_URL"

  end=$((SECONDS + MAX_WAIT_SECONDS))
  until curl -fsS "$BASE_URL" >/dev/null 2>&1; do
    if (( SECONDS >= end )); then
      echo "ERROR: $BASE_URL did not become ready within ${MAX_WAIT_SECONDS}s"
      exit 1
    fi
    sleep 2
  done

  echo "==> $BASE_URL is responding"

  echo "==> Test: Homepage reachable"
  curl -fsS "$BASE_URL" >/dev/null

  echo "==> Test: Login page contains expected content"
  curl -fsS "$BASE_URL/login" | grep -qi "login"

  echo "==> Test: API endpoint responds"
  code="$(curl -sS -o /dev/null -w "%{http_code}" "$BASE_URL/projects.json")"
  if [[ "$code" != "200" && "$code" != "401" && "$code" != "403" ]]; then
    echo "ERROR: Unexpected status for $BASE_URL/projects.json: $code"
    exit 1
  fi

  echo "Tests passed for $BASE_URL"
  echo ""
}

# Test both instances
check_instance "http://localhost:3001"
check_instance "http://localhost:3002"

echo "All Redmine instances passed integration tests."
