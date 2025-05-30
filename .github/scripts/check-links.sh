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

# Function to extract URLs from diff
extract_urls_from_diff() {
    local file=$1
    if [ "$CHECK_ALL" = true ] || [ "$FIX_MODE" = true ]; then
        # In all/fix mode, get all URLs from the file
        grep -o '\[.*\]([^)]*)' "$file" | sed -E 's/.*\[.*\]\((.*)\)/\1/'
    else
        # In changes mode, get only new URLs from diff
        git diff HEAD^ HEAD "$file" | grep -o '\[.*\]([^)]*)' | grep '^+' | sed -E 's/^\+.*\[.*\]\((.*)\)/\1/'
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
        echo "⚠️ The following newly added links appear to be broken:$broken_urls" > comment.txt
        echo "" >> comment.txt
        echo "Please fix these links before merging." >> comment.txt
        gh pr comment ${{ github.event.pull_request.number }} --body-file comment.txt
    fi
}

# Main script
echo "Checking links in $TARGET_FILE..."

# Extract URLs
NEW_URLS=$(extract_urls_from_diff "$TARGET_FILE")

if [ -z "$NEW_URLS" ]; then
    echo "No URLs found"
    exit 0
fi

echo "Found URLs to check:"
echo "$NEW_URLS"

# Check each URL
BROKEN_URLS=""
for URL in $NEW_URLS; do
    echo "Checking $URL..."
    if ! check_url "$URL"; then
        BROKEN_URLS="$BROKEN_URLS\n$URL"
    fi
done

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