#!/bin/bash

## install openvpn base apps from the other repo ##
curl -o /install_openvpn.sh -L "https://raw.githubusercontent.com/testdasi/openvpn-client-aio-base/master/install.sh"
source /install_openvpn.sh

## NZB and TOR ##
source /install_nzb.sh
source /install_tor.sh

## mono-arr section ##
# add mono repo
apt-get -y update \
    && apt-get -y install apt-transport-https dirmngr gnupg gnupg2 gnupg1 ca-certificates \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && echo "deb https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list \
    && apt-get -y update
# install more packages
apt-get -y install wget curl dnsutils sipcalc jq libicu63 libssl1.1
apt-get -y install mono-complete
apt-get -y install --no-install-recommends --no-install-suggests bzip2 ca-certificates-mono libcurl4-openssl-dev mediainfo mono-devel mono-vbnc python sqlite3 unzip
# install sonarr
SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases | jq -r ".[] | select(.branch==\"main\") | .version")
curl -o /tmp/sonarr.tar.gz -L "https://download.sonarr.tv/v3/main/${SONARR_VERSION}/Sonarr.main.${SONARR_VERSION}.linux.tar.gz" \
    && mkdir -p /app/sonarr \
    && tar xf /tmp/sonarr.tar.gz -C /app/sonarr --strip-components=1 \
    && rm -f /tmp/sonarr.tar.gz \
    && echo "$(date "+%d.%m.%Y %T") Added sonarr version ${SONARR_VERSION} from master branch" >> /build_date.info
# install radarr
RADARR_RELEASE=$(curl -sL "https://radarr.servarr.com/v1/update/master/changes?os=linux&runtime=netcore&arch=x64" | jq -r '.[0].version')
curl -o /tmp/radarr.tar.gz -L "https://radarr.servarr.com/v1/update/master/updatefile?version=${RADARR_RELEASE}&os=linux&runtime=netcore&arch=x64" \
    && mkdir -p /app/radarr \
    && tar ixzf /tmp/radarr.tar.gz -C /app/radarr --strip-components=1 \
    && rm -f /tmp/radarr.tar.gz \
    && echo "$(date "+%d.%m.%Y %T") Added radarr version ${RADARR_RELEASE} from master branch" >> /build_date.info
# install prowlarr - will use master branch once prowlarr stable is available
PROWLARR_BRANCH="develop"
PROWLARR_RELEASE=$(curl -sL "https://prowlarr.servarr.com/v1/update/${PROWLARR_BRANCH}/changes?runtime=netcore&os=linux" | jq -r '.[0].version')
curl -o /tmp/prowlarr.tar.gz -L "https://prowlarr.servarr.com/v1/update/${PROWLARR_BRANCH}/updatefile?version=${PROWLARR_RELEASE}&os=linux&runtime=netcore&arch=x64" \
    && mkdir -p /app/prowlarr \
    && tar ixzf /tmp/prowlarr.tar.gz -C /app/prowlarr --strip-components=1 \
    && rm -f /tmp/prowlarr.tar.gz \
    && rm -rf /app/prowlarr/prowlarr.Update \
    && echo "$(date "+%d.%m.%Y %T") Added prowlarr version ${RADARR_RELEASE} from ${PROWLARR_BRANCH} branch" >> /build_date.info

## Remaining apps ##
# install torsocks and privoxy
apt-get -y install torsocks privoxy \
    && mkdir -p /etc/tor \
    && rm -rf /etc/tor/* \
    && mkdir -p /etc/privoxy \
    && rm -rf /etc/privoxy/*
# install my BrowserStartPage fork
cd /tmp \
    && curl -L "https://github.com/testdasi/BrowserStartPage/archive/master.zip" -o /tmp/launcher.zip \
    && mkdir -p /app \
    && unzip /tmp/launcher.zip \
    && mv /tmp/BrowserStartPage-master /app/launcher \
    && chmod +x /app/launcher/launcher-python2.sh \
    && chmod +x /app/launcher/launcher-python3.sh \
    && rm -f /tmp/launcher.zip

## Clean up ##
apt-get -y autoremove \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*
