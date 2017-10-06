#!/bin/bash
# install packages needed to clone and build SPDK project
set -e
yum -y install git vim pciutils
cd /vagrant
git clone https://github.com/spdk/spdk.git
cd spdk
git submodule update --init
./scripts/pkgdep.sh
# ./configure
# make
# ./unittest.sh
