# IG Follow Checker (POSIX Version)

A lightweight POSIX-compliant shell tool to compare your Instagram followers and following lists locally.

No API. No scraping. No authentication. Pure JSON processing.

---

## Requirements

- POSIX shell (`/bin/sh`)
- jq
- sort
- comm
- mktemp
- find

Install jq if missing:

Debian/Ubuntu:
    sudo apt install jq

Arch:
    sudo pacman -S jq

Alpine:
    apk add jq

macOS:
    brew install jq

---

## How to Obtain Your Instagram Data

1. Open Instagram.
2. Go to:
   Profile → Settings and privacy → Your activity → Download your information
3. Choose:
   - "Some of your information"
   - Select "Followers and following"
   - Format: JSON
4. Submit the request.
5. Download the ZIP file from the email you receive.
6. Extract it.

Inside the extracted folder you should find:

    connections/followers_1.json
    connections/following.json

Move the extracted folder into:

    ~/Documents

Or pass a custom directory using --dir.

---

## Installation

Make the script executable:

    chmod +x ig-checker.sh

Optionally move it to your PATH:

    sudo mv ig-checker.sh /usr/local/bin/ig-checker

---

## Usage

Default (who you follow that doesn't follow you back):

    ./ig-checker.sh

Reverse:

    ./ig-checker.sh --reverse

Both directions:

    ./ig-checker.sh --both

Show counts:

    ./ig-checker.sh --both --count

Export to CSV:

    ./ig-checker.sh --csv

Custom directory:

    ./ig-checker.sh --dir ~/Downloads/instagram-export

Show help:

    ./ig-checker.sh --help

---

## What It Does

- Extracts usernames from JSON
- Normalizes case
- Sorts and deduplicates
- Uses `comm` to compute set differences

All processing is done locally.

---

## Why No API?

The official Instagram Graph API:
- Does not expose follower lists for personal accounts
- Requires app registration
- Has strict permission scopes

This tool avoids all that by using your official data export.

---

## License

This project is for personal use. No affiliation with Instagram.
It's licensed under MIT just in case.
