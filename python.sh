#!/usr/bin/env bash
# set -e

# Copyright 2017 Eduardo A. Paris Penas <edward2a@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

python_version=3.6.1
python_source_url="https://www.python.org/ftp/python/${python_version}/Python-${python_version}.tgz"

if [[ $UID != 0 ]]; then
    printf "You are UID %i, you need to be 0. Bye...\n" $UID
    exit 1
fi

cd /usr/local/src
wget ${python_source_url}
wget https://bootstrap.pypa.io/get-pip.py
tar xf Python-${python_version}.tgz
cd Python-${python_version}

./configure --enable-shared --prefix=/usr --enable-ipv6 --enable-loadable-sqlite-extensions --with-dbmliborder=bdb:gdbm --with-computed-gotos --without-ensurepip --with-system-expat --with-system-libmpdec --with-system-ffi --with-fpectl CC=x86_64-linux-gnu-gcc CFLAGS="-g -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security"  LDFLAGS="-Wl,-Bsymbolic-functions -Wl,-z,relro" CPPFLAGS="-D_FORTIFY_SOURCE=2" --enable-optimizations

make -j4
make altinstall

cd ..
if $(which pip &>/dev/null); then
    old_pip=$(which pip)
    cp ${old_pip} /tmp/pip
    python${python_version%.*} get-pip.py
    cp /tmp/pip ${old_pip}
    rm -f /tmp/pip
else
    python${python_version%.*} get-pip.py
fi

[[ -x /usr/bin/apt-get ]] && apt-get remove -qq --purge command-not-found command-not-found-data python3-commandnotfound

if [[ -L /usr/bin/python3 ]]; then
    _link=$(readlink -f /usr/bin/python3)
    if [[ $link != /usr/bin/python${python_version%.*} ]]; then
        update-alternatives --install /usr/bin/python3 python3 $_link 1
        update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${python_version%.*} 2
        update-alternatives --set python3 /usr/bin/python${python_version%.*}
    fi
fi
