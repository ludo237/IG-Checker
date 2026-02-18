#!/bin/sh

DIR="$HOME/Documents"
MODE="default"
CSV=0
COUNT=0

print_help() {
    echo "ig-checker.sh - Instagram follow diff tool"
    echo
    echo "Usage:"
    echo "  ig-checker.sh [options]"
    echo
    echo "Options:"
    echo "  --reverse        Show who follows you but you don't follow"
    echo "  --both           Show both differences"
    echo "  --csv            Export results to CSV"
    echo "  --count          Show total count"
    echo "  --dir PATH       Custom directory (default: ~/Documents)"
    echo "  --help           Show this help"
    exit 0
}

# Parse arguments (POSIX style)
while [ "$#" -gt 0 ]; do
    case "$1" in
        --reverse) MODE="reverse" ;;
        --both) MODE="both" ;;
        --csv) CSV=1 ;;
        --count) COUNT=1 ;;
        --dir)
            shift
            DIR="$1"
            ;;
        --help) print_help ;;
        *)
            echo "Unknown option: $1"
            print_help
            ;;
    esac
    shift
done

FOLLOWERS_FILE=$(find "$DIR" -type f -name "followers_*.json" 2>/dev/null | head -n 1)
FOLLOWING_FILE=$(find "$DIR" -type f -name "following.json" 2>/dev/null | head -n 1)

if [ ! -f "$FOLLOWERS_FILE" ] || [ ! -f "$FOLLOWING_FILE" ]; then
    echo "Could not locate Instagram JSON files in $DIR"
    exit 1
fi

FOLLOWERS_TMP=$(mktemp)
FOLLOWING_TMP=$(mktemp)

jq -r '.[].string_list_data[].value' "$FOLLOWERS_FILE" \
    | tr '[:upper:]' '[:lower:]' \
    | sort -u > "$FOLLOWERS_TMP"

jq -r '.relationships_following[].string_list_data[].value' "$FOLLOWING_FILE" \
    | tr '[:upper:]' '[:lower:]' \
    | sort -u > "$FOLLOWING_TMP"

output_result() {
    TITLE="$1"
    FILE1="$2"
    FILE2="$3"

    echo
    echo "$TITLE"
    echo "----------------------------------------"

    RESULT=$(comm -23 "$FILE1" "$FILE2")

    echo "$RESULT"

    if [ "$COUNT" -eq 1 ]; then
        TOTAL=$(printf "%s\n" "$RESULT" | sed '/^$/d' | wc -l | tr -d ' ')
        echo
        echo "Total: $TOTAL"
    fi

    if [ "$CSV" -eq 1 ]; then
        CSV_FILE="ig_diff_$(date +%s).csv"
        printf "%s\n" "$RESULT" > "$CSV_FILE"
        echo
        echo "Exported to $CSV_FILE"
    fi
}

case "$MODE" in
    default)
        output_result \
        "Accounts you follow that DO NOT follow you back:" \
        "$FOLLOWING_TMP" "$FOLLOWERS_TMP"
        ;;
    reverse)
        output_result \
        "Accounts that follow you but you DON'T follow back:" \
        "$FOLLOWERS_TMP" "$FOLLOWING_TMP"
        ;;
    both)
        output_result \
        "Accounts you follow that DO NOT follow you back:" \
        "$FOLLOWING_TMP" "$FOLLOWERS_TMP"

        output_result \
        "Accounts that follow you but you DON'T follow back:" \
        "$FOLLOWERS_TMP" "$FOLLOWING_TMP"
        ;;
esac

rm -f "$FOLLOWERS_TMP" "$FOLLOWING_TMP"

