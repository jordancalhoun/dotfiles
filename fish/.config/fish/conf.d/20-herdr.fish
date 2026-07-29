# Fish only autoloads functions directly under functions/, so load the grouped
# Herdr functions explicitly.
for herdr_function in "$__fish_config_dir"/functions/herdr/*.fish
    source "$herdr_function"
end
set --erase herdr_function
