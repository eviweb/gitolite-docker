#! /bin/bash
# main entry point
DIR=$(dirname $(readlink -f $0))
SERVICES=$(dirname "${DIR}")/services
COMMAND="$@"

if [ -z "${COMMAND}" ]
then
    COMMAND="/bin/bash"
fi

# start needed services
function startServices
{
    for service in ${SERVICES}/*.sh
    do
        name=$(basename ${service})
        name=${name%.*}
        name=${name//-/ }
        echo "  > ${name}..."
        ${service} &> /dev/null
        echo "  ... done"
    done
}

echo "- Initialize runtime environment -"
startServices
echo "- Runtime environment ready -"

# run command
echo "Run command: ${COMMAND}"
eval ${COMMAND}
echo "Done"
