#!/bin/bash
set -e

V=0.2.8
wget -nv -O toolbox.deb https://github.com/kgyrtkirk/hive-toolbox/releases/download/${V}/hive-toolbox_${V}_all.deb
dpkg -i toolbox.deb
rm toolbox.deb
