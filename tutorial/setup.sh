#!/usr/bin/env bash
wget -O dataset.zip https://github.com/talmolab/sleap-datasets/releases/download/dm-courtship-v1/drosophila-melanogaster-courtship.zip
mkdir dataset
unzip dataset.zip -d dataset
rm dataset.zip
