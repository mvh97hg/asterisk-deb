# asterisk-deb

```
#!/bin/bash

sudo apt install -y \
  build-essential \
  devscripts \
  debhelper \
  dh-make \
  fakeroot \
  lintian \
  quilt \
  git

VERSION="22.7.0"

mkdir -p /opt/build/asterisk_${VERSION}

cd /opt/build/asterisk_${VERSION}

curl -fsSL https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${VERSION}.tar.gz | tar --strip-components=1 -xz

git clone https://github.com/mvh97hg/asterisk-deb.git
sudo contrib/scripts/get_mp3_source.sh

sudo contrib/scripts/install_prereq install
chmod +x debian/asterisk.postinst debian/asterisk.postrm

dpkg-buildpackage -us -uc -b
```