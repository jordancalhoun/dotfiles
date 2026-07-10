# Helper: add existing directories to PATH without duplicates.
function path_add
    for dir in $argv
        test -d "$dir"; or continue
        fish_add_path --global --append --move "$dir"
    end
end
