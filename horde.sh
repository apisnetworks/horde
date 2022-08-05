#!/bin/bash -i
set -euo pipefail
TMPFILE="$(mktemp)"
yum install -y rpm-build
trap 'rm -f $TMPFILE' EXIT
VERSION=${VERSION:-5.2.22}
pear list -c horde | grep -A9999 -m1 -e '===' | tail -n+3 | while IFS=$' ' read -r -a PKG ; do echo ${PKG[0]} ; pear list-files horde/${PKG}  ; done  | awk '$2 ~ /^\// {print $2}' | sort | uniq > $TMPFILE
echo "/usr/share/pear/.registry/.channel.pear.horde.org" >> $TMPFILE
rbenv exec gem install --no-rdoc --no-ri fpm
rbenv exec fpm -t rpm -a noarch --rpm-use-file-permissions -s dir -m '<build@apisnetworks.com>' --epoch 1 --iteration 3.apnscp -v $VERSION --license 'OSI certified' -n horde-groupware -v${VERSION} -s dir -t rpm --inputs $TMPFILE
