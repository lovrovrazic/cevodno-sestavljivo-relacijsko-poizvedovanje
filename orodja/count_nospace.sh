count_nospace() {
    local target_dir="${1:-.}" # Defaults to current directory if no path is given
    find "$target_dir" -type f -exec sh -c 'printf "%s: " "$1"; tr -d "[:space:]" < "$1" | wc -m' _ {} \;
}
