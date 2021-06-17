function log() {
    LOG_PATH=logs/;
    if [ ! -d "$LOG_PATH" ]; then
        echo "Prepending ${LOG_PATH} with sfdx_sandbox repository name."
        if [ -d "sfdx_sandbox/${LOG_PATH}" ]; then
            LOG_PATH="sfdx_sandbox/${LOG_PATH}";
        else
            echo "Error: Directory ${LOG_PATH} does not exist. Creating..."
        fi
    fi

    LOG_PATH="${LOG_PATH}$(date +'%Y-%m-%d')/"
    if [ ! -d "$LOG_PATH" ]; then
        mkdir -p ${LOG_PATH}
    fi

    if [ -z ${bamboo_stash_username} ]; then
        bamboo_stash_username=$(whoami)
    fi

    LOG_PATH="${LOG_PATH}/log.txt"

    echo "$(date +'%Y-%m-%d %T')|${bamboo_stash_username}|$1" >> ${LOG_PATH}

    if [ -z $2 ] && [ $2!=false ]; then
        echo $1
    fi
}

function headline {
    title="$1"
    log "${title}" false;

    len=0
    maxlen=80
    ch="~"

    if [ -n "$2" ]; then
        ch=$2
    fi
    
    headline="$ch $title "

    i=$((${#headline})) # add length of title
    while [ $i -lt $maxlen ]
    do
        headline="${headline}${ch} "
        i=$((i+2)) # add two characters
    done

    echo "${headline}";
}

function mask {
    local n=3 # number of chars to leave
    if [ -n "$2" ]; then
        n=$2
    fi

    local a="${1:0:${#1}-n}"           # take all but the last n chars
    local b="${1:${#1}-n}"             # take the final n chars 
    printf "%s%s\n" "${a//?/*}" "$b"   # substitute a with asterisks
}