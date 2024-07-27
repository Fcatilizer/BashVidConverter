#!/bin/bash

# Function to display video files and prompt for selection
select_files() {
    echo "Available video files:"
    local i=1
    for file in *.mp4; do
        echo "$i) $file"
        files[i]=$file
        ((i++))
    done

    read -p "Enter the number(s) of the file(s) you want to transcode (e.g., 1 2 3): " -a selections
}

# Function to prompt for the output folder
select_output_folder() {
    read -p "Do you want to save the files in a different folder? (y/n): " save_different
    if [ "$save_different" == "y" ]; then
        read -p "Enter the folder name: " output_folder
        mkdir -p "$output_folder"
    else
        output_folder="transcode"
    fi
}

# Function to check for existing file and prompt for renaming
check_and_rename() {
    local output_path="$1"
    if [ -f "$output_path" ]; then
        read -p "File $output_path already exists. Enter a new name (without extension): " new_name
        output_path="${output_path%/*}/$new_name.mov"
    fi
    echo "$output_path"
}

# Main script
mkdir -p transcode
select_files
select_output_folder

for i in "${selections[@]}"; do
    file=${files[i]}
    output_path="$output_folder/${file%.*}.mov"
    output_path=$(check_and_rename "$output_path")

    ffmpeg -i "$file" -vcodec mjpeg -q:v 2 -acodec pcm_s16be -q:a 0 -f mov "$output_path"
done

