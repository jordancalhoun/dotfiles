# Helper: add existing directories to PATH without duplicates.
set --global fish_greeting

function path_add
    for dir in $argv
        test -d "$dir"; or continue
        fish_add_path --global --append --move "$dir"
    end
end
