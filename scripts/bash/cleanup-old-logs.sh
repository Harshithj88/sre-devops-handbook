#!/usr/bin/env bash
#
# cleanup-old-logs.sh
# Finds and removes log files older than a specified number of days.
#
# Usage:
#   ./cleanup-old-logs.sh -d /var/log/myapp -a 30
#   ./cleanup-old-logs.sh -d /var/log/myapp -a 30 --dry-run

set -euo pipefail

LOG_DIR=""
MAX_AGE_DAYS=30
DRY_RUN=false
PATTERN="*.log"

usage() {
    cat <<EOF
Usage: $(basename "$0") -d <directory> [-a <days>] [-p <pattern>] [--dry-run]

Options:
  -d, --directory   Directory to search for log files (required)
  -a, --age         Maximum age in days (default: 30)
  -p, --pattern     File name pattern to match (default: *.log)
  --dry-run         Show what would be deleted without deleting

Examples:
  $(basename "$0") -d /var/log/myapp -a 14
  $(basename "$0") -d /var/log/myapp -a 7 -p "*.log.gz" --dry-run
EOF
    exit 1
}

log_info()  { echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]  $*"; }
log_warn()  { echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN]  $*" >&2; }
log_error() { echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" >&2; }

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--directory) LOG_DIR="$2"; shift 2 ;;
        -a|--age)       MAX_AGE_DAYS="$2"; shift 2 ;;
        -p|--pattern)   PATTERN="$2"; shift 2 ;;
        --dry-run)      DRY_RUN=true; shift ;;
        -h|--help)      usage ;;
        *)              log_error "Unknown option: $1"; usage ;;
    esac
done

if [[ -z "$LOG_DIR" ]]; then
    log_error "Directory is required."
    usage
fi

if [[ ! -d "$LOG_DIR" ]]; then
    log_error "Directory does not exist: $LOG_DIR"
    exit 1
fi

log_info "Searching for '$PATTERN' files older than $MAX_AGE_DAYS days in $LOG_DIR"

FILES=$(find "$LOG_DIR" -type f -name "$PATTERN" -mtime +"$MAX_AGE_DAYS" 2>/dev/null || true)

if [[ -z "$FILES" ]]; then
    log_info "No files found matching criteria."
    exit 0
fi

FILE_COUNT=$(echo "$FILES" | wc -l | tr -d ' ')
TOTAL_SIZE=$(echo "$FILES" | xargs du -ch 2>/dev/null | tail -1 | awk '{print $1}')

if [[ "$DRY_RUN" == true ]]; then
    log_warn "DRY RUN — the following $FILE_COUNT file(s) ($TOTAL_SIZE) would be deleted:"
    echo "$FILES"
    exit 0
fi

log_info "Deleting $FILE_COUNT file(s) ($TOTAL_SIZE)..."

DELETED=0
FAILED=0
while IFS= read -r file; do
    if rm -f "$file" 2>/dev/null; then
        ((DELETED++))
    else
        log_warn "Failed to delete: $file"
        ((FAILED++))
    fi
done <<< "$FILES"

log_info "Cleanup complete. Deleted: $DELETED, Failed: $FAILED"

if [[ $FAILED -gt 0 ]]; then
    exit 1
fi
exit 0
