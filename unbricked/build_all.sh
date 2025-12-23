#!/bin/bash

# Recursively check all subdirectories (excluding the current directory) for build.sh
find . -mindepth 1 -type d | while read -r dir; do
    build_script="$dir/build.sh"

    if [ -f "$build_script" ]; then
        (cd "$dir" && bash build.sh)

        if [ $? -eq 0 ]; then
            echo "[SUCCESS] Build successful in: $dir"
        else
            echo "[FAILED] Build failed in: $dir"
        fi
    else
        echo "[FAILED] No build.sh found in: $dir"
    fi
done
