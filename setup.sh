#! /bin/bash
set -e -o pipefail

TARGET_DIR="${HOME}/bin"

main() {
    parse_arguments "${@}"
    copy_files
}

parse_arguments() {
    while getopts "hf" o; do
        case "${o}" in
        f)
            FORCE_FLAG="force"
            ;;
        h)
            usage
            exit 0
            ;;
        \? | *)
            usage
            exit 1
            ;;
        esac
    done

    shift $((OPTIND - 1))

    if [[ "${#}" -ne 0 ]]; then
        echo "Illegal number of parameters ${0}: got ${#} but expected exactly 0: ${*}" >&2
        usage
        exit 1
    fi
}

usage() {
    cat <<-EOF >&2
		Usage: ${0##*/} [-hf]
		
		Setup the configuration files by creating symboling links.
		
		    -h          display this help and exit
		    -f          force mode: this will overwrite existing symbolic links.
	EOF
}

copy_files() {
    for name in *; do
        if [[ ! -d "${name}" ]]; then
            target="${TARGET_DIR}/${name}"
            if ! [[ "${name}" =~ ^(setup.sh|README.md)$ ]]; then

                if [[ -e "${target}" ]]; then             # Does the config file already exist?
                    if [[ ! -L "${target}" ]]; then       # as a pure file?
                        mv "${target}" "${target}.backup" # Then backup it
                        echo "-----> Moved your old ${target} config file to ${target}.backup"
                    fi
                fi

                if [[ ! -e "${target}" ]]; then
                    echo "-----> Symlinking your new ${target}"
                    ln -s ${FORCE_FLAG:+-f} "${PWD}/${name}" "${target}"
                fi
            fi
        fi
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "${@}"
fi
