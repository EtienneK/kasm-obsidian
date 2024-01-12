#!/usr/bin/env bash
set -ex

# Install Obsidian
apt-get update
apt-get install -y xdg-utils

if [ -z ${OBSIDIAN_VERSION+x} ] 
then
    OBSIDIAN_VERSION=$(curl -sX GET "https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest" \
      | awk '/tag_name/{print $4;exit}' FS='[""]' | cut -c2-) 
fi

cd /tmp
curl -o \
    /tmp/obsidian.deb -L \
    "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.deb"
dpkg -i /tmp/obsidian.deb

# Desktop Icon
sed -i 's#/opt/Obsidian/obsidian#/opt/Obsidian/obsidian --no-sandbox#g' /usr/share/applications/obsidian.desktop
cp /usr/share/applications/obsidian.desktop $HOME/Desktop/
chmod +x $HOME/Desktop/obsidian.desktop

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z ${SKIP_CLEAN+x} ]; then
    apt-get autoclean
    rm -rf \
      /var/lib/apt/lists/* \
      /var/tmp/* \
      /tmp/*
fi
