#!/bin/bash
#
# Script Name: archive_extractor.sh
# Description: This script extracts the major supported archives in given directory.
# Author: Stathis Lytras
# Date: 2026-07-14
# Version: 1.2
#
# Usage:
#   ./archive_extractor.sh "/path/to/archives"
#
# Parameters:
#   A path containing archives as string.
#
# Notes:
#   - Files supported: 7z, rar, zip, gz, tar.gz, tar.bz2, tar.xz.
#   - For 7z, zip and rar password protected can be used.


set -euo pipefail

SCAN_DIR="${1:-.}"  # Default to current directory
EXTRACT_DIR="$SCAN_DIR/extracted"
PASSWORD=""  # REMEMBER to set a password if the archives are protected!!!
VERBOSE=false

# Create extraction directory
mkdir -p "$EXTRACT_DIR"

detect_file_type() {
  local file="$1"
    
  case "${file##*.}" in
    7z) echo "7z" ;;
    rar) echo "rar" ;;
    zip) echo "zip" ;;
    gz) 
      if [[ "$file" == *.tar.gz ]]; then
        echo "tar.gz"
      else
        echo "gz"
      fi
      ;;
    bz2)
      if [[ "$file" == *.tar.bz2 ]]; then
        echo "tar.bz2"
      else
        echo "bz2"
      fi
      ;;
    xz)
      if [[ "$file" == *.tar.xz ]]; then
        echo "tar.xz"
      else
        echo "xz"
      fi
      ;;
    tar) echo "tar" ;;
    *) echo "unknown" ;;
  esac
}

needs_password() {
  local file="$1"
  local type="$2"
    
  case "$type" in
    7z)
      7z l "$file" 2>&1 | grep -q "encrypted" && echo "yes" || echo "no"
      ;;
    rar)
      unrar l "$file" 2>&1 | grep -q "encrypted" && echo "yes" || echo "no"
      ;;
    zip)
      unzip -t "$file" 2>&1 | grep -q "encrypted\|password" && echo "yes" || echo "no"
      ;;
    *)
      echo "no"
      ;;
    esac
}

extract_file() {
  local file="$1"
  local type="$2"
  local pwd="$3"
  local filename=$(basename "$file")
  local output_dir="$EXTRACT_DIR/${filename%.*}"
    
  mkdir -p "$output_dir"
    
  if [ "$VERBOSE" = true ]; then
    echo "📦 Extracting: $filename ($type)"
  fi
    
  case "$type" in
    7z)
      if [ -z "$pwd" ]; then
        7z x "$file" -o"$output_dir" > /dev/null 2>&1
      else
        7z x -y -p"$pwd" "$file" -o"$output_dir" > /dev/null 2>&1
      fi
      ;;
    rar)
      if [ -z "$pwd" ]; then
        unrar x "$file" "$output_dir/" > /dev/null 2>&1
      else
        unrar x -p"$pwd" "$file" "$output_dir/" > /dev/null 2>&1
      fi
      ;;
    zip)
      if [ -z "$pwd" ]; then
        unzip -q "$file" -d "$output_dir"
      else
        unzip -P "$pwd" -q "$file" -d "$output_dir"
      fi
      ;;
    tar.gz)
      tar -xzf "$file" -C "$output_dir" 2>/dev/null
      ;;
    tar.bz2)
      tar -xjf "$file" -C "$output_dir" 2>/dev/null
      ;;
    tar.xz)
      tar -xJf "$file" -C "$output_dir" 2>/dev/null
      ;;
    tar)
      tar -xf "$file" -C "$output_dir" 2>/dev/null
      ;;
    *)
      echo "❌ Unknown file type: $type"
      return 1
      ;;
  esac
    
  if [ $? -eq 0 ]; then
    echo "✅ $filename"
    return 0
  else
    echo "❌ Failed: $filename"
    return 1
  fi
}

scan_directory() {
  local dir="$1"
  local count=0
  local success=0
  
  echo "🔍 Scanning: $dir"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
  # Find all archive files
  while IFS= read -r file; do
    ((++count))
        
    file_type=$(detect_file_type "$file")
        
    if [ "$file_type" = "unknown" ]; then
      continue
    fi
        
    # Check if password needed
    if [ -z "$PASSWORD" ]; then
      needs_pwd=$(needs_password "$file" "$file_type")
      if [ "$needs_pwd" = "yes" ]; then
        if [ "$VERBOSE" = true ]; then
          echo "🔒 $(basename "$file") - Password protected"
        fi
        
        # Only ask once if multiple files need password
        if [ -z "$PASSWORD" ]; then
          read -sp "Enter password for protected files: " PASSWORD
          echo
        fi
      fi
    fi
    
    if extract_file "$file" "$file_type" "$PASSWORD"; then
      ((++success))
    fi

    done < <(
        find "$dir" -maxdepth 1 -type f \
          \( -iname "*.7z" \
          -o -iname "*.rar" \
          -o -iname "*.zip" \
          -o -iname "*.tar.gz" \
          -o -iname "*.tar.bz2" \
          -o -iname "*.tar.xz" \
          -o -iname "*.tar" \
          \)
    )

    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Archives found : $count"
    echo "Extracted      : $success"
    echo "Extracted to   : $EXTRACT_DIR"
}

scan_directory "$SCAN_DIR"
