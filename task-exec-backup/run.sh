#!/bin/bash

source_path=""
archive_name=""
compiler_commands=()

while [[ $# -gt 0 ]]
do
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

if [[ -z $source_path || -z $archive_name || ${#compiler_commands[@]} -eq 0 ]]; then
    missing_params=""
    if [[ -z $source_path ]]; then
        missing_params+="source path, "
    fi
    if [[ -z $archive_name ]]; then
        missing_params+="archive name, "
    fi
    if [[ ${#compiler_commands[@]} -eq 0 ]]; then
        missing_params+="compiler commands"
    fi
    echo "Error: Missing required parameters: $missing_params"
    exit 1
fi

if [[ ! -d $source_path ]]; then
    echo "Source directory not found: $source_path"
    exit 1
fi

temp_dir=$(mktemp -d)

cp -R "$source_path"/* "$temp_dir" || { echo "Failed to copy source files"; exit 1; }

for command in "${compiler_commands[@]}"; do
    extension=$(echo "$command" | cut -d '=' -f 1)
    compiler=$(echo "$command" | cut -d '=' -f 2)
    find "$temp_dir" -type f -name "*.$extension" -exec sh -c '$compiler -o "${0%.*}.exe" "$0"' {} \; || { echo "Failed to compile files with extension $extension"; exit 1; }
done

tar -czf "$archive_name.tar.gz" -C "$(dirname "$temp_dir")" "$(basename "$temp_dir")" || { echo "Failed to create archive"; exit 1; }

rm -rf "$temp_dir"

echo "complete"
