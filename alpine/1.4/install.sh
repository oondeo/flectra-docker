#!/bin/bash


for req in $(ls -1d /mnt/extra-addons/*/requirements.txt)
do
    pip3 install -r $req
done 