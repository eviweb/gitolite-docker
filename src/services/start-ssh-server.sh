#! /bin/bash
# start ssh server
if ! sudo service ssh status &> /dev/null
then
    sudo service ssh start
fi
