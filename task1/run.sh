#!/bin/bash

input_folder=""
backup_folder=""
extension=""
backup_archive_name=""

while [[ $# -gt 0 ]]
do
    case $1 in
        --input_folder)
            input_folder=$2
            shift 2
            ;;
        --backup_folder)
            backup_folder=$2
            shift 2
            ;;
        --extension)
            extension=$2
            shift 2
            ;;
        --backup_archive_name)
            backup_archive_name=$2
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ -z $input_folder || -z $backup_folder || -z $extension || -z $backup_archive_name ]]; then
    missing_params=""
    if [[ -z $input_folder ]]; then
        missing_params+="input_folder"
    fi
    if [[ -z $backup_folder ]]; then
        if [[ -n $missing_params ]]; then
            missing_params+=", "
        fi
        missing_params+="backup_folder"
    fi
    if [[ -z $extension ]]; then
        if [[ -n $missing_params ]]; then
            missing_params+=", "
        fi
        missing_params+="extension"
    fi
    if [[ -z $backup_archive_name ]]; then
        if [[ -n $missing_params ]]; then
            missing_params+=", "
        fi
        missing_params+="backup_archive_name"
    fi
    echo "Error: Missing required parameters: $missing_params"
    exit 1
fi

if [[ ! -d $input_folder ]]; then
    echo "Input directory not found: $input_folder"
    exit 1
fi

if [[ -d $backup_folder ]]; then
    echo "Backup folder already exists: $backup_folder"
    exit 1
fi

mkdir "$backup_folder"

# Create a temporary directory
temp_dir=$(mktemp -d)

# Copy files to the temporary directory
find "$input_folder" -name "*.$extension" -exec cp {} "$temp_dir" \;

# Create the tar.gz archive
tar -czf "$backup_archive_name.tar.gz" -C "$temp_dir" .

# Move the archive to the backup folder
mv "$backup_archive_name.tar.gz" "$backup_folder/"

# Clean up the temporary directory
rm -r "$temp_dir"

echo "done"
