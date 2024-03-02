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

# Extract compiler and extensions
compiler=$(echo "$compiler_command" | rev | cut -d '=' -f 1 | rev)
extensions=$(echo "$compiler_command" | rev | cut -d '=' -f 2- | rev)

# Compile files with each extension
for extension in $(echo "$extensions"); do
    find "$source_path" -type f -name "*.$extension" | while read -r file; do
        destination="$archive_name/$(echo "$file" | cut -d/ -f 2-)"
        mkdir -p "$(dirname "$destination")"
        sh -c "$compiler -o $archive_name/\$(echo $file | cut -d/ -f 2- | cut -d. -f 1).exe $file"
    done
done

# Create tar.gz archive of compiled files
tar -czf "$archive_name.tar.gz" $archive_name || { echo "Failed to create archive"; exit 1; }

# Eemove temporary directory
rm -rf "$archive_name"

echo "complete"
