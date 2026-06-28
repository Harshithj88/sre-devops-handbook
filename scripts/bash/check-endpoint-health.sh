#!/usr/bin/env bash
#
# check-endpoint-health.sh
# Checks HTTP health of a list of endpoints and reports status.
#
# Usage:
#   ./check-endpoint-health.sh urls.txt
#   echo "https://api.example.com/health" | ./check-endpoint-health.sh -
#   ./check-endpoint-health.sh -u https://api.example.com/health -u https://web.example.com/health

set -euo pipefail

TIMEOUT=10
URLS=()
INPUT_FILE=""

usage() {
    cat <<EOF
Usage: $(basename "$0") [-u <url>]... [<file>]

Options:
  -u, --url       URL to check (can be specified multiple times)
  -t, --timeout   Timeout in seconds per request (default: 10)
  <file>          File containing one URL per line (use - for stdin)

Examples:
  $(basename "$0") -u https://api.example.com/health
  $(basename "$0") -u https://api.example.com/health -u https://web.example.com/health
  $(basename "$0") urls.txt
  $(basename "$0") -t 5 urls.txt
EOF
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|--url)     URLS+=("$2"); shift 2 ;;
        -t|--timeout) TIMEOUT="$2"; shift 2 ;;
        -h|--help)    usage ;;
        -*)           echo "Unknown option: $1" >&2; usage ;;
        *)            INPUT_FILE="$1"; shift ;;
    esac
done

if [[ -n "$INPUT_FILE" ]]; then
    if [[ "$INPUT_FILE" == "-" ]]; then
        while IFS= read -r line; do
            [[ -n "$line" && ! "$line" =~ ^# ]] && URLS+=("$line")
        done
    elif [[ -f "$INPUT_FILE" ]]; then
        while IFS= read -r line; do
            [[ -n "$line" && ! "$line" =~ ^# ]] && URLS+=("$line")
        done < "$INPUT_FILE"
    else
        echo "File not found: $INPUT_FILE" >&2
        exit 1
    fi
fi

if [[ ${#URLS[@]} -eq 0 ]]; then
    echo "No URLs provided." >&2
    usage
fi

HEALTHY=0
UNHEALTHY=0
TOTAL=${#URLS[@]}

printf "\n%-60s %-10s %-10s\n" "URL" "STATUS" "TIME"
printf "%-60s %-10s %-10s\n" "$(printf '%0.s-' {1..60})" "----------" "----------"

for url in "${URLS[@]}"; do
    START=$(date +%s%N)

    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
        --connect-timeout "$TIMEOUT" \
        --max-time "$TIMEOUT" \
        "$url" 2>/dev/null || echo "000")

    END=$(date +%s%N)
    ELAPSED_MS=$(( (END - START) / 1000000 ))

    if [[ "$HTTP_CODE" =~ ^2 ]]; then
        STATUS="HEALTHY"
        COLOR="\033[0;32m"
        ((HEALTHY++))
    elif [[ "$HTTP_CODE" == "000" ]]; then
        STATUS="UNREACHABLE"
        COLOR="\033[0;31m"
        ((UNHEALTHY++))
    else
        STATUS="HTTP $HTTP_CODE"
        COLOR="\033[0;33m"
        ((UNHEALTHY++))
    fi

    printf "${COLOR}%-60s %-10s %6dms\033[0m\n" "$url" "$STATUS" "$ELAPSED_MS"
done

printf "\n"
echo "=== Summary ==="
echo "Total: $TOTAL | Healthy: $HEALTHY | Unhealthy: $UNHEALTHY"

if [[ $UNHEALTHY -gt 0 ]]; then
    exit 1
fi
exit 0
