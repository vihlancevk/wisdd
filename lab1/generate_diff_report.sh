#!/usr/bin/env bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <repo_url> <branch1> <branch2>"
  exit 1
fi

REPO_URL=$1
BRANCH1=$2
BRANCH2=$3
REPORT_FILE="diff_report_${BRANCH1}_vs_${BRANCH2}.txt"
TMP_DIR=$(mktemp -d)
ORIGINAL_DIR=$(pwd)

echo "Cloning repository..."
git clone --quiet "$REPO_URL" "$TMP_DIR" || { echo "Error: failed to clone repository."; exit 1; }

cd "$TMP_DIR" || exit 1

echo "Fetching all branches..."
git fetch --all --quiet

echo "Checking if branches exist..."
if ! git rev-parse --verify "origin/$BRANCH1" >/dev/null 2>&1; then
  echo "Error: branch $BRANCH1 not found."
  rm -rf "$TMP_DIR"
  exit 1
fi

if ! git rev-parse --verify "origin/$BRANCH2" >/dev/null 2>&1; then
  echo "Error: branch $BRANCH2 not found."
  rm -rf "$TMP_DIR"
  exit 1
fi

echo "Calculating differences..."
DIFF_OUTPUT=$(git diff --name-status "origin/$BRANCH1" "origin/$BRANCH2")

TOTAL=$(echo "$DIFF_OUTPUT" | wc -l)
ADDED=$(echo "$DIFF_OUTPUT" | grep -c '^A' || true)
DELETED=$(echo "$DIFF_OUTPUT" | grep -c '^D' || true)
MODIFIED=$(echo "$DIFF_OUTPUT" | grep -c '^M' || true)

echo "Generating report file..."
{
  echo "Branch Difference Report"
  echo
  echo "================================"
  echo "Repository:     $REPO_URL"
  echo "Branch 1:       $BRANCH1"
  echo "Branch 2:       $BRANCH2"
  echo "Generated at:   $(date '+%Y-%m-%d %H:%M:%S')"
  echo "================================"
  echo
  echo "CHANGED FILES:"
  echo "$DIFF_OUTPUT"
  echo
  echo "STATISTICS:"
  echo "Total changed files: $TOTAL"
  echo "Added (A):    $ADDED"
  echo "Deleted (D):  $DELETED"
  echo "Modified (M): $MODIFIED"
} > "$ORIGINAL_DIR/$REPORT_FILE"

echo "Cleaning up temporary files..."
rm -rf "$TMP_DIR"

echo "Report successfully generated: $REPORT_FILE"
