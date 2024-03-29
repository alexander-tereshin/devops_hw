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
        missing_params+="source_path, "
    fi
    if [[ -z $archive_name ]]; then
        missing_params+="archive_name, "
    fi
    if [[ ${#compiler_commands[@]} -eq 0 ]]; then
        missing_params+="compiler_commands, "
    fi
    echo "Error: Missing required parameters: ${missing_params%, }"
    exit 1
fi

# Check if source directory exists
if [[ ! -d $source_path ]]; then
    echo "Source directory not found: $source_path"
    exit 1
fi

# Create directory for compiled files
mkdir -p "$archive_name" || { echo "Failed to create directory for compiled files"; exit 1; }

# Compile files with each compiler command
for command in "${compiler_commands[@]}"; do
    # Extract compiler and extensions
    compiler=$(echo "$command" | rev | cut -d '=' -f 1 | rev)
    extensions=$(echo "$command" | rev | cut -d '=' -f 2- | rev)
    # Split extensions into an array
    IFS=',' read -ra extension_array <<< "$extensions"
    # Compile files with each specified extension
    for extension in "${extension_array[@]}"; do
        find "$source_path" -type f -name "*.$extension" -print0 | while IFS= read -r -d '' file; do
            relative_path="${file#$source_path/}"
            compiled_file="$archive_name/${relative_path%.*}.exe" 
            # Ensure directory structure exists for compiled file
            mkdir -p "$(dirname "$compiled_file")"
            # Execute compiler command
            $compiler -o "$compiled_file" "$file" || { echo "Failed to compile $file"; exit 1; }
        done
    done
done

# Create tar.gz archive of compiled files
tar -czf "$archive_name.tar.gz" "$archive_name" || { echo "Failed to create archive"; exit 1; }

# Remove compiled files directory
rm -rf "$archive_name"

echo "complete"
