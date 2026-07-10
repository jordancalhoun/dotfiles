status is-interactive; or return

if command -q starship
    starship init fish | source
end
