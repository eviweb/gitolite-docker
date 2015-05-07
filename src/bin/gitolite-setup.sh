#! /bin/bash
# gitolite setup
SSH_DIR=${HOME}/.ssh
BIN_DIR=${HOME}/bin
DEFAULT_SSH_KEY=${SSH_DIR}/id_rsa
GITOLITE_REPO="https://github.com/sitaramc/gitolite.git"

[ ! -e ${SSH_DIR} ] && mkdir ${SSH_DIR} # should already exists
[ ! -e ${BIN_DIR} ] && mkdir ${BIN_DIR} # should already exists

function installGitolite()
{
    cd ${HOME}
    echo "Clone gitolite repository from: ${GITOLITE_REPO}"
    git clone "${GITOLITE_REPO}"
    echo "Install gitolite and link binaries to ${BIN_DIR}"
    gitolite/install -ln ${BIN_DIR}
}

function setupGitolite()
{
    echo "Setup gitolite using ssh public key: $1"
    gitolite setup -pk "$1"
}

function generateSshKey()
{
    cd ${HOME}
    echo "Generate defaut ssh key for default admin user: ${USER}"
    ssh-keygen -t rsa -C "${USER}@gitolite-docker" -N "" -f ${DEFAULT_SSH_KEY}
}

function getAdminSshKey()
{
    local keys=( $(readlink -e ${SSH_DIR}/*.pub) )
    local key

    if [ ${#keys[@]} -lt 1 ]
    then
        generateSshKey
        key="${DEFAULT_SSH_KEY}.pub"
    else
        key="${keys[0]}"
    fi

    echo "${key}"
}

# install gitolite
installGitolite

sshpubkey="$(getAdminSshKey)"
keycopy=""
if [ "${sshpubkey}" == "${DEFAULT_SSH_KEY}.pub" ]
then
    echo -e "Rename default ssh public key\n> from:\t${DEFAULT_SSH_KEY}.pub\n> to:\t${SSH_DIR}/${USER}.pub"
    cp ${DEFAULT_SSH_KEY}.pub ${SSH_DIR}/${USER}.pub
    sshpubkey=${SSH_DIR}/${USER}.pub
    keycopy=${sshpubkey}
fi

setupGitolite "${sshpubkey}"

if [ -e "${keycopy}" ]
then
    echo "Remove the temp ssh public key: ${keycopy}"
    rm "${keycopy}"
fi
