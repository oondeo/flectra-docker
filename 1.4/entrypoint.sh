#!/bin/bash

set -e

if [ -n ${TZ} ]; then
  rm /etc/localtime
  ln -sf /usr/share/zoneinfo/${TZ}  /etc/localtime
fi

#Openshift fix
if [ `id -u` -ge 10000 ]; then
#install nss_wrapper gettext
# export USER_ID=$(id -u)
# export GROUP_ID=$(id -g)
# envsubst < ${HOME}/passwd.template > /tmp/passwd
# export LD_PRELOAD=libnss_wrapper.so
# export NSS_WRAPPER_PASSWD=/tmp/passwd
# export NSS_WRAPPER_GROUP=/etc/group
    cat /etc/passwd | sed -e "s/^$NB_USER:/builder:/" > /tmp/passwd
    echo "$NB_USER:x:`id -u`:`id -g`:,,,:/var/lib/flectra:/bin/false" >> /tmp/passwd
    cat /tmp/passwd > /etc/passwd
    rm /tmp/passwd
fi

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the flectra process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='flectra'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='flectra'}}}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if ! grep -q -E "^\s*\b${param}\b\s*=" "$FLECTRA_RC" ; then
        DB_ARGS+=("--${param}")
        DB_ARGS+=("${value}")
   fi;
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

addons=$(ls -1d /mnt/* ${XDG_DATA_HOME:="/var/lib/flectra"}/addons/$FLECTRA_VERSION \
   /usr/lib/python3/dist-packages/flectra | tr '\n' ',' | sed s/,$//)

EXTRA_ARGS=()
env -0 | while IFS='=' read -r -d '' n v; do
    if [ "${n:0:8}" == "FLECTRA_" ]
    then
        n=${n:8}
        n=${n,,}
        n=${n/_/-}
        EXTRA_ARGS+=("--$n")
        EXTRA_ARGS+=("$v")
        if [ "$n" == "addons-path" ]
        then
            addons=""
        fi
    fi
done

if [ "$addons" != "" ]
then
    EXTRA_ARGS+="--addons-path"
    EXTRA_ARGS+="$addons"
fi
case "$1" in
    -- | flectra)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec flectra "$@"
        else
            exec flectra "$@" "${DB_ARGS[@]}" "${EXTRA_ARGS[@]}"
        fi
        ;;
    -*)
        exec flectra "$@" "${DB_ARGS[@]}" "${EXTRA_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1

