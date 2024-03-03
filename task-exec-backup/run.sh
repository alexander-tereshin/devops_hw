#!/bin/bash

# Initialize variables
source_path=""
archive_name=""
compiler_commands=()

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--source)
            source_path=$2
            shift 2
            ;;
        -a|--archive)
            archive_name=$2
            shift 2
            ;;
        -c|--compiler)
            compiler_commands+=("$2")
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check for missing parameters
if [[ -z $source_path || -z $archive_name || ${#compiler_commands[@]} -eq 0 ]]; then
    missing_params=""
    if [[ -z $source_path ]]; then
        if [[ -n $missing_params ]]; then
            missing_params+=", "
        fi
        missing_params+="source_path"
    fi
    if [[ -z $archive_name ]]; then
        if [[ -n $missing_params ]]; then
            missing_params+=", "
        fi
        missing_params+="archive_name"
    fi
    if [[ ${#compiler_commands[@]} -eq 0 ]]; then
        if [[ -n $missing_params ]]; then
            missing_params+=", "
        fi
        missing_params+="compiler_commands"
    fi
    echo "Error: Missing required parameters: $missing_params"
    exit 1
fi

# Check if source directory exists
if [[ ! -d $source_path ]]; then
    echo "Source directory not found: $source_path"
    exit 1
fi

# Create temporary directory
temp_dir=$(mktemp -d)

# Compile files
for command in "${compiler_commands[@]}"; do
    # Extract compiler and extensions
    compiler=$(echo "$command" | cut -d '=' -f 1)
    extensions=$(echo "$command" | cut -d '=' -f 2-)

    # Compile files with each extension
    for extension in $(echo "$extensions" | tr ',' ' '); do
        find "$source_path" -type f -name "*.$extension" | while read -r file; do
            mkdir -p "$temp_dir/$(dirname "$file")"
            $compiler -o "$temp_dir/${file%.*}.exe" "$file"
        done
    done
done

# Create tar.gz archive of compiled files
tar -czf "$archive_name.tar.gz" -C "$temp_dir" . || { echo "Failed to create archive"; exit 1; }

# Remove temporary directory
rm -rf "$temp_dir"

echo "complete"
