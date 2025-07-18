#!/bin/bash

# Function to print usage
usage() {
    echo "Usage: $0 [--all|--fix] [--file FILE]"
    echo "  --all      Check all links in the file (not just new changes)"
    echo "  --fix      Check all links and remove broken ones from the file"
    echo "  --file     Specify file to check (default: README.md)"
    exit 1
}

# Default values
CHECK_ALL=false
FIX_MODE=false
TARGET_FILE="README.md"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            CHECK_ALL=true
            shift
            ;;
        --fix)
            FIX_MODE=true
            shift
            ;;
        --file)
            TARGET_FILE="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

# Function to check if a URL is accessible
check_url() {
    local url=$1
    # Skip internal anchors
    if [[ $url == \#* ]]; then
        return 0
    fi
    # Skip empty URLs
    if [ -z "$url" ]; then
        return 0
    fi
    # Skip URLs without protocol
    if [[ ! $url =~ ^https?:// ]]; then
        return 0
    fi
    if ! curl -s -f -o /dev/null --head "$url"; then
        return 1
    fi
    return 0
}

# Function to extract URLs and line numbers based on mode
extract_urls_and_line_numbers() {
    local file=$1
    if [ "$CHECK_ALL" = true ] || [ "$FIX_MODE" = true ]; then
        # In all/fix mode, get URLs from list items in the file with line numbers
        grep -n '\[.*\](http[^)]*)' "$file" | sed -E 's/([0-9]+):.*\[.*\]\(([^)]+)\).*/\1 \2/'
    else
        # In changes mode, get only new URLs from diff with line numbers
        if [[ "$(uname)" == "Darwin" ]]; then
            # Use gawk on macOS
            git diff -U0 HEAD^ HEAD "$file" | gawk '/^@@/ { split($0, a, " "); split(a[2], b, ","); line=substr(b[1], 2); next } /^\+/ && !/^\+\+\+/ { if ($0 ~ /\[.*\]\(http[^)]+\)/) { match($0, /\[.*\]\((http[^)]+)\)/, arr); print line " " arr[1]; line++ } }'
        else
            # Use awk assuming GNU awk
            git diff -U0 HEAD^ HEAD "$file" | awk '/^@@/ { split($0, a, " "); split(a[2], b, ","); line=substr(b[1], 2); next } /^\+/ && !/^\+\+\+/ { if ($0 ~ /\[.*\]\(http[^)]+\)/) { match($0, /\[.*\]\((http[^)]+)\)/, arr); print line " " arr[1]; line++ } }'
        fi
    fi
}

# Function to remove broken links from file
remove_broken_links() {
    local file=$1
    local broken_urls=$2
    local temp_file="${file}.tmp"
    
    # Create a temporary file
    cp "$file" "$temp_file"
    
    # For each broken URL, remove its line from the file
    while IFS= read -r url; do
        if [ ! -z "$url" ]; then
            # Escape special characters in URL for sed
            escaped_url=$(echo "$url" | sed 's/[\/&]/\\&/g')
            # Remove the line containing the broken URL
            sed -i.tmp "/$escaped_url/d" "$temp_file"
        fi
    done <<< "$broken_urls"
    
    # Replace original file with fixed version
    mv "$temp_file" "$file"
    rm -f "${temp_file}.tmp"
}

# Function to report broken links
report_broken_links() {
    local broken_urls=$1
    if [ "$FIX_MODE" = true ]; then
        echo "Removed the following broken links:"
        echo "$broken_urls"
    elif [ "$CHECK_ALL" = true ]; then
        echo "⚠️ The following links appear to be broken:"
        echo "$broken_urls"
    else
        echo "⚠️ The following newly added links appear to be broken:$broken_urls"
    fi
}

# Main script
echo "Checking links in $TARGET_FILE..."

# Extract URLs and line numbers
NEW_URLS_AND_LINES=$(extract_urls_and_line_numbers "$TARGET_FILE")

if [ -z "$NEW_URLS_AND_LINES" ]; then
    echo "No URLs found"
    exit 0
fi

# Check each URL
BROKEN_URLS=""
while IFS= read -r line; do
    LINE_NUMBER=$(echo "$line" | awk '{print $1}')
    URL=$(echo "$line" | awk '{print $2}')
    echo "Checking $URL at line $LINE_NUMBER..."
    if ! check_url "$URL"; then
        BROKEN_URLS="$BROKEN_URLS\nLine $LINE_NUMBER: $URL"
    fi
    
    # Annotate PR if URL is broken
    if [ ! -z "$BROKEN_URLS" ]; then
        echo "::error file=$TARGET_FILE,line=$LINE_NUMBER::Broken link: $URL"
    fi

done <<< "$NEW_URLS_AND_LINES"

# Report results
if [ ! -z "$BROKEN_URLS" ]; then
    if [ "$FIX_MODE" = true ]; then
        remove_broken_links "$TARGET_FILE" "$BROKEN_URLS"
    fi
    report_broken_links "$BROKEN_URLS"
    exit 1
else
    echo "All links are working!"
    exit 0
fi 