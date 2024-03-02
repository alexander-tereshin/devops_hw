#!/bin/bash

source_path=""
archive_name=""
compiler_command=""

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
            compiler_command=$2
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ -z $source_path || -z $archive_name || -z $compiler_command ]]; then
    missing_params=""
    if [[ -z $source_path ]]; then
        missing_params+="source path, "
    fi
    if [[ -z $archive_name ]]; then
        missing_params+="archive name, "
    fi
    if [[ -z $compiler_command ]]; then
        missing_params+="compiler commands"
    fi
    echo "Error: Missing required parameters: $missing_params"
    exit 1
fi

if [[ ! -d $source_path ]]; then
    echo "Source directory not found: $source_path"
    exit 1
fi

mkdir temporary

cp -R $source_path/* temporary || { echo "Failed to copy source files"; exit 1; }

compiler=$(echo "$compiler_command" | rev | cut -d '=' -f 1 | rev)

extensions=$(echo "$compiler_command" | rev | cut -d '=' -f 2- | rev)

old_IFS=$IFS

IFS='='
for extension in $(echo "$extensions"); do
    find temporary -type f -name "*.$extension" -exec sh -c '$compiler "$0" -o "$0.exe"' {} \; || { echo "Failed to compile files with extension $extension"; exit 1;}
    done

IFS=$old_IFS

tar -czf "$archive_name.tar.gz" temporary || { echo "Failed to create archive"; exit 1; }

rm -rf temporary

echo "complete"
