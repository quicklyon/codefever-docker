#!/bin/bash

function check_storage_dir {
    local target_directory="$1"
    local template_directory="$2"
    local symlink_location="$3"

    if [ ! -d "$target_directory" ]; then
        echo "$target_directory not existed, copy $template_directory to $target_directory"
        
        cp -r "$template_directory" "$target_directory"
        chown -R git:git "$target_directory"
        chmod -R 0777 "$target_directory"
    else
        echo "$target_directory existed"
    fi

    if [ ! -L "$symlink_location" ]; then
        echo "$symlink_location not existed, link $symlink_location to $target_directory"
        
        ln -s "$target_directory" "$symlink_location"
        chown -R git:git "$symlink_location"
        chmod -R 0777 "$symlink_location"
    else
        echo "$symlink_location existed"
    fi
}

if [ ! -d "/data/codefever" ]; then
        echo "/data/codefever not existed, creating"
        
        mkdir -p "/data/codefever"
    else
        echo "/data/codefever existed"
fi

check_storage_dir "/data/codefever/git-storage" "/apps/codefever/storage-template/git-storage" "/apps/codefever/git-storage"
check_storage_dir "/data/codefever/file-storage" "/apps/codefever/storage-template/file-storage" "/apps/codefever/file-storage"
check_storage_dir "/data/codefever/logs" "/apps/codefever/storage-template/logs" "/apps/codefever/application/logs"