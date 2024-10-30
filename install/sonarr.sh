#!/usr/bin/env bash

## 影音模组

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

set +e

## Usenet Provider

## https://www.newsgroup.ninja/en/landing/usenet-promotion?utm_source=reddit&utm_medium=organicsocial&utm_campaign=BlackFriday2020

## Standalone用法

# password1="adminadmin"

# install_sonarr

uid=$(id -u root)
gid=$(id -g root)

## 资源文件夹

## 一级子目录(sonarr,radarr)
mkdir /data/
## 二级子目录(qbt,emby,bazarr)
mkdir /data/torrents/
mkdir /data/usenet/
mkdir /data/media/
## BT/PT qBittorrent
mkdir /data/torrents/Movies/
mkdir /data/torrents/Series/
mkdir /data/torrents/Music/
mkdir /data/torrents/Books/
mkdir /data/torrents/XXX/
mkdir /data/torrents/Others/
## Usenet NZBGet
mkdir /data/usenet/Movies/
mkdir /data/usenet/Series/
mkdir /data/usenet/Music/
mkdir /data/usenet/Books/
mkdir /data/usenet/XXX/
mkdir /data/usenet/Others/
## Sonarr Radarr Lidarr Readarr
mkdir /data/media/Movies/
mkdir /data/media/Series/
mkdir /data/media/Music/
mkdir /data/media/Books/
mkdir /data/media/XXX/
mkdir /data/media/Others/

apt-get install xml-twig-tools -y
apt-get install sqlite3 -y
apt-get install jq -y

## PRAGMA table_info(NamingConfig);

## 配置文件夹

mkdir /usr/share/nginx/nzbget
mkdir /usr/share/nginx/nzbget/config
mkdir /usr/share/nginx/sonarr
mkdir /usr/share/nginx/sonarr/config
mkdir /usr/share/nginx/radarr
mkdir /usr/share/nginx/radarr/config
mkdir /usr/share/nginx/lidarr
mkdir /usr/share/nginx/lidarr/config
mkdir /usr/share/nginx/readarr
mkdir /usr/share/nginx/readarr/config
mkdir /usr/share/nginx/prowlarr
mkdir /usr/share/nginx/prowlarr/config
mkdir /usr/share/nginx/jackett
mkdir /usr/share/nginx/jackett/config
mkdir /usr/share/nginx/bazarr
mkdir /usr/share/nginx/bazarr/config
mkdir /usr/share/nginx/chinesesubfinder
mkdir /usr/share/nginx/chinesesubfinder/app/
mkdir /usr/share/nginx/chinesesubfinder/app/cache
mkdir /usr/share/nginx/chinesesubfinder/config
mkdir /usr/share/nginx/ombi
mkdir /usr/share/nginx/ombi/config

## Redis

mkdir /data/redis

add_sonarr_ombi(){
    cat > "add.sh" << "EOF"
#!/usr/bin/env bash
  sqlite3 /usr/share/nginx/ombi/config/OmbiSettings.db  "insert into GlobalSettings values ('2','{\"Enabled\":true,\"ApiKey\":\"adminadmin\",\"QualityProfile\":\"1\",\"SeasonFolders\":false,\"RootPath\":\"1\",\"QualityProfileAnime\":\"1\",\"RootPathAnime\":\"2\",\"AddOnly\":false,\"V3\":true,\"LanguageProfile\":2,\"LanguageProfileAnime\":2,\"ScanForAvailability\":false,\"Ssl\":false,\"SubDir\":\"/sonarr\",\"Ip\":\"127.0.0.1\",\"Port\":8989,\"Id\":0}','SonarrSettings');"
EOF
sed -i "s/adminadmin/${sonarr_api}/g" add.sh
bash add.sh
rm add.sh
}

add_radarr_ombi(){
    cat > "add.sh" << "EOF"
#!/usr/bin/env bash
  sqlite3 /usr/share/nginx/ombi/config/OmbiSettings.db  "insert into GlobalSettings values ('3','{\"Enabled\":true,\"ApiKey\":\"adminadmin\",\"DefaultQualityProfile\":\"1\",\"DefaultRootPath\":\"/data/media/movies\",\"AddOnly\":false,\"MinimumAvailability\":\"Announced\",\"ScanForAvailability\":false,\"Ssl\":false,\"SubDir\":\"/radarr\",\"Ip\":\"127.0.0.1\",\"Port\":7878,\"Id\":0}','RadarrSettings');"
EOF
sed -i "s/adminadmin/${radarr_api}/g" add.sh
bash add.sh
rm add.sh
}

add_lidarr_ombi(){
    cat > "add.sh" << "EOF"
#!/usr/bin/env bash
  sqlite3 /usr/share/nginx/ombi/config/OmbiSettings.db  "insert into GlobalSettings values ('4','{\"Enabled\":true,\"ApiKey\":\"adminadmin\",\"DefaultQualityProfile\":\"1\",\"DefaultRootPath\":\"/data/media/Music/\",\"AlbumFolder\":true,\"MetadataProfileId\":1,\"AddOnly\":false,\"Ssl\":false,\"SubDir\":\"/lidarr\",\"Ip\":\"127.0.0.1\",\"Port\":8686,\"Id\":0}','LidarrSettings');"
EOF
sed -i "s/adminadmin/${lidarr_api}/g" add.sh
bash add.sh
rm add.sh
}

add_download_client_sonarr(){
    cat > "add.sh" << "EOF"
#!/usr/bin/env bash
  ## Qbt Series
  sqlite3 /usr/share/nginx/sonarr/config/sonarr.db  "insert into DownloadClients values ('1','1','qBittorrent_Series','QBittorrent','{
  \"host\": \"127.0.0.1\",
  \"port\": 8080,
  \"useSsl\": false,
  \"username\": \"admin\",
  \"password\": \"adminadmin\",
  \"tvCategory\": \"Series\",
  \"recentTvPriority\": 0,
  \"olderTvPriority\": 0,
  \"initialState\": 0,
  \"sequentialOrder\": false,
  \"firstAndLast\": false
}','QBittorrentSettings','1','1','1');"
  ## nzbget Series
  sqlite3 /usr/share/nginx/sonarr/config/sonarr.db  "insert into DownloadClients values ('2','1','NZBGet_Series','Nzbget','{
  \"host\": \"127.0.0.1\",
  \"port\": 6789,
  \"useSsl\": false,
  \"username\": \"admin\",
  \"password\": \"adminadmin\",
  \"tvCategory\": \"Series\",
  \"recentTvPriority\": 0,
  \"olderTvPriority\": 0,
  \"addPaused\": false
}','NzbgetSettings','1','1','1');"
EOF
sed -i "s/adminadmin/${password1}/g" add.sh
bash add.sh
rm add.sh
}

add_download_client_radarr(){
    cat > "add.sh" << "EOF"
#!/usr/bin/env bash
  sqlite3 /usr/share/nginx/radarr/config/radarr.db  "insert into DownloadClients values ('1','1','qBittorrent','QBittorrent','{
  \"host\": \"127.0.0.1\",
  \"port\": 8080,
  \"useSsl\": false,
  \"username\": \"admin\",
  \"password\": \"adminadmin\",
  \"movieCategory\": \"Movies\",
  \"recentTvPriority\": 0,
  \"olderTvPriority\": 0,
  \"initialState\": 0
}','QBittorrentSettings','1','1','1');"

sqlite3 /usr/share/nginx/radarr/config/radarr.db  "insert into DownloadClients values ('2','1','NZBGet','Nzbget','{
  \"host\": \"127.0.0.1\",
  \"port\": 6789,
  \"useSsl\": false,
  \"username\": \"admin\",
  \"password\": \"adminadmin\",
  \"movieCategory\": \"Movies\",
  \"recentMoviePriority\": 0,
  \"olderMoviePriority\": 0,
  \"addPaused\": false
}','NzbgetSettings','1','1','1');"
EOF
sed -i "s/adminadmin/${password1}/g" add.sh
bash add.sh
rm add.sh
}

add_download_client_lidarr(){
    cat > "add.sh" << "EOF"
#!/usr/bin/env bash
  sqlite3 /usr/share/nginx/lidarr/config/lidarr.db  "insert into DownloadClients values ('1','1','qBittorrent','QBittorrent','{
  \"host\": \"127.0.0.1\",
  \"port\": 8080,
  \"username\": \"admin\",
  \"password\": \"adminadmin\",
  \"musicCategory\": \"Music\",
  \"recentTvPriority\": 0,
  \"olderTvPriority\": 0,
  \"initialState\": 0,
  \"useSsl\": false
}','QBittorrentSettings','1');"

sqlite3 /usr/share/nginx/lidarr/config/lidarr.db  "insert into DownloadClients values ('2','1','NZBGet','Nzbget','{
  \"host\": \"127.0.0.1\",
  \"port\": 6789,
  \"username\": \"admin\",
  \"password\": \"adminadmin\",
  \"musicCategory\": \"Music\",
  \"recentTvPriority\": 0,
  \"olderTvPriority\": 0,
  \"addPaused\": false,
  \"useSsl\": false
}','NzbgetSettings','1');"
EOF
sed -i "s/adminadmin/${password1}/g" add.sh
bash add.sh
rm add.sh
}

add_download_client_readarr(){
    cat > "add.sh" << "EOF"
#!/usr/bin/env bash
  sqlite3 /usr/share/nginx/readarr/config/readarr.db  "insert into DownloadClients values ('1','1','qBittorrent','QBittorrent','{
  \"host\": \"127.0.0.1\",
  \"port\": 8080,
  \"useSsl\": false,
  \"username\": \"admin\",
  \"password\": \"adminadmin\",
  \"musicCategory\": \"Books\",
  \"recentTvPriority\": 0,
  \"olderTvPriority\": 0,
  \"initialState\": 0
}','QBittorrentSettings','1');"

sqlite3 /usr/share/nginx/readarr/config/readarr.db  "insert into DownloadClients values ('2','1','NZBGet','Nzbget','{
  \"host\": \"127.0.0.1\",
  \"port\": 6789,
  \"useSsl\": false,
  \"username\": \"admin\",
  \"password\": \"adminadmin\",
  \"musicCategory\": \"Books\",
  \"recentTvPriority\": 0,
  \"olderTvPriority\": 0,
  \"addPaused\": false
}','NzbgetSettings','1');"
EOF
sed -i "s/adminadmin/${password1}/g" add.sh
bash add.sh
rm add.sh
}

add_download_client_prowlarr(){
    cat > "add.sh" << "EOF"
#!/usr/bin/env bash
  sqlite3 /usr/share/nginx/prowlarr/config/prowlarr.db  "insert into DownloadClients values ('1','1','qBittorrent','QBittorrent','{
  \"host\": \"127.0.0.1\",
  \"port\": 8080,
  \"useSsl\": false,
  \"username\": \"admin\",
  \"password\": \"adminadmin\",
  \"category\": \"Others\",
  \"priority\": 0,
  \"initialState\": 0
}','QBittorrentSettings','1');"

sqlite3 /usr/share/nginx/prowlarr/config/prowlarr.db  "insert into DownloadClients values ('2','1','NZBGet','Nzbget','{
  \"host\": \"127.0.0.1\",
  \"port\": 6789,
  \"useSsl\": false,
  \"username\": \"admin\",
  \"password\": \"adminadmin\",
  \"category\": \"Others\",
  \"priority\": 0,
  \"addPaused\": false
}','NzbgetSettings','1');"
EOF
sed -i "s/adminadmin/${password1}/g" add.sh
bash add.sh
rm add.sh
}

add_prowlarr_sonarr_radarr_lidarr_readarr(){
    cat > "add1.sh" << "EOF"
#!/usr/bin/env bash
  sqlite3 /usr/share/nginx/prowlarr/config/prowlarr.db  "insert into Applications values ('1','Sonarr','Sonarr','{
  \"prowlarrUrl\": \"http://127.0.0.1:9696\",
  \"baseUrl\": \"http://127.0.0.1:8989/sonarr\",
  \"apiKey\": \"adminadmin\",
  \"syncCategories\": [
    5000,
    5010,
    5020,
    5030,
    5040,
    5045,
    5050
  ],
  \"animeSyncCategories\": [
    5070
  ]
}','SonarrSettings','2','[]');"
EOF
sed -i "s/adminadmin/${sonarr_api}/g" add1.sh
bash add1.sh
rm add1.sh

    cat > "add2.sh" << "EOF"
#!/usr/bin/env bash
  sqlite3 /usr/share/nginx/prowlarr/config/prowlarr.db  "insert into Applications values ('2','Radarr','Radarr','{
  \"prowlarrUrl\": \"http://127.0.0.1:9696\",
  \"baseUrl\": \"http://127.0.0.1:7878/radarr\",
  \"apiKey\": \"adminadmin\",
  \"syncCategories\": [
    2000,
    2010,
    2020,
    2030,
    2040,
    2045,
    2050,
    2060,
    2070,
    2080
  ]
}','RadarrSettings','2','[]');"
EOF
sed -i "s/adminadmin/${radarr_api}/g" add2.sh
bash add2.sh
rm add2.sh

    cat > "add3.sh" << "EOF"
#!/usr/bin/env bash
  sqlite3 /usr/share/nginx/prowlarr/config/prowlarr.db  "insert into Applications values ('3','Lidarr','Lidarr','{
  \"prowlarrUrl\": \"http://127.0.0.1:9696\",
  \"baseUrl\": \"http://127.0.0.1:8686/lidarr\",
  \"apiKey\": \"adminadmin\",
  \"syncCategories\": [
    3000,
    3010,
    3030,
    3040,
    3050,
    3060
  ]
}','LidarrSettings','2','[]');"
EOF
sed -i "s/adminadmin/${lidarr_api}/g" add3.sh
bash add3.sh
rm add3.sh

    cat > "add4.sh" << "EOF"
#!/usr/bin/env bash
  sqlite3 /usr/share/nginx/prowlarr/config/prowlarr.db  "insert into Applications values ('4','Readarr','Readarr','{
  \"prowlarrUrl\": \"http://127.0.0.1:9696\",
  \"baseUrl\": \"http://127.0.0.1:8787/readarr\",
  \"apiKey\": \"adminadmin\",
  \"syncCategories\": [
    3030,
    7000,
    7010,
    7020,
    7030,
    7040,
    7050,
    7060
  ]
}','ReadarrSettings','2','[]');"
EOF
sed -i "s/adminadmin/${readarr_api}/g" add4.sh
bash add4.sh
rm add4.sh
}

install_sonarr(){

cd /data/

    cat > "docker-compose.yml" << EOF
version: "3.8"
services:
  nzbget: # 6789
    network_mode: host 
    #image: lscr.io/linuxserver/nzbget
    image: johnrosen/nzbget:latest
    container_name: nzbget
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai
    volumes:
      - /usr/share/nginx/nzbget/config:/config
      - /data/usenet:/data/usenet:rw
    restart: unless-stopped
  sonarr: # 8989
    network_mode: host 
    image: lscr.io/linuxserver/sonarr
    container_name: sonarr
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai
    volumes:
      - /usr/share/nginx/sonarr/config:/config
      - /data:/data
    restart: unless-stopped
  radarr: # 7878
    network_mode: host 
    image: lscr.io/linuxserver/radarr
    container_name: radarr
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai
    volumes:
      - /usr/share/nginx/radarr/config:/config
      - /data:/data
    restart: unless-stopped
  lidarr: # 8686
    network_mode: host 
    image: lscr.io/linuxserver/lidarr
    container_name: lidarr
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai
    volumes:
      - /usr/share/nginx/lidarr/config:/config
      - /data:/data
    restart: unless-stopped
  readarr: # 8787
    network_mode: host 
    image: lscr.io/linuxserver/readarr:develop
    container_name: readarr
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai
    volumes:
      - /usr/share/nginx/readarr/config:/config
      - /data:/data
    restart: unless-stopped    
  prowlarr: # 9696
    network_mode: host
    image: lscr.io/linuxserver/prowlarr:develop
    container_name: prowlarr
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai
    volumes:
      - /usr/share/nginx/prowlarr/config:/config
    restart: unless-stopped
  # jackett: #9117
  #   network_mode: host
  #   image: lscr.io/linuxserver/jackett
  #   container_name: jackett
  #   environment:
  #     - PUID=0
  #     - PGID=0
  #     - TZ=Asia/Shanghai
  #   volumes:
  #     - /usr/share/nginx/jackett/config:/config
  #   restart: unless-stopped
  # rsshub: # 1200
  #   image: diygod/rsshub
  #   container_name: rsshub
  #   ports:
  #     - '1200:1200'
  #   environment:
  #     # PROXY_URI: 'http://127.0.0.1:8080'
  #     NODE_ENV: production
  #     CACHE_TYPE: redis
  #     REDIS_URL: 'redis://redis:6379/'
  #     PUPPETEER_WS_ENDPOINT: 'ws://browserless:3000'
  #   depends_on:
  #     - browserless
  #     - redis
  #   restart: unless-stopped
  # browserless: # 3000
  #   image: browserless/chrome
  #   container_name: browserless
  #   restart: unless-stopped
  #   ports:
  #     - 127.0.0.1:3000:3000
  # redis: # 6379
  #   image: "redis:latest"
  #   container_name: redis
  #   ports:
  #     - "6379:6379"
  #   volumes:
  #     - "/data/redis:/data"
  flaresolverr: # 8191
    network_mode: host 
    image: flaresolverr/flaresolverr
    container_name: flaresolverr
    environment:
      - LOG_LEVEL=\${LOG_LEVEL:-info}
      - LOG_HTML=\${LOG_HTML:-false}
      - CAPTCHA_SOLVER=\${CAPTCHA_SOLVER:-none}
      - TZ=Asia/Shanghai
    restart: unless-stopped
  bazarr: # 6767
    network_mode: host
    image: lscr.io/linuxserver/bazarr
    container_name: bazarr
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai
    volumes:
      - /usr/share/nginx/bazarr/config:/config
      - /data/media/:/data/media
    restart: unless-stopped
  chinesesubfinder: # 19035
    network_mode: host
    image: allanpk716/chinesesubfinder:latest
    container_name: chinesesubfinder
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai    
    volumes:
      - /usr/share/nginx/chinesesubfinder/app/cache:/app/cache
      - /usr/share/nginx/chinesesubfinder/config:/config
      - /data:/data
    restart: unless-stopped
  ombi: # 3579
    network_mode: host
    image: lscr.io/linuxserver/ombi
    container_name: ombi
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai
      - BASE_URL=/ombi
    volumes:
      - /usr/share/nginx/ombi/config:/config
    restart: unless-stopped
  watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    environment: 
        - TZ=Asia/Shanghai
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --cleanup --schedule "0 0 3 * * *"
    restart: unless-stopped
EOF

docker-compose up -d
sleep 60s;
docker-compose down

## nzbget
sed -i "s/MainDir=\/downloads/MainDir=\/data\/usenet\//g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/DestDir=\${MainDir}\/completed/DestDir=\${MainDir}/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/ControlIP=0.0.0.0/ControlIP=127.0.0.1/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/ControlUsername=nzbget/ControlUsername=admin/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/FormAuth=no/FormAuth=yes/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/AuthorizedIP=127.0.0.1/AuthorizedIP=/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/ControlPassword=tegbzn6789/ControlPassword=${password1}/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/Server1.Port=119/Server1.Port=563/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/Server1.Cipher=/Server1.Cipher=ECDHE-ECDSA-AES128-GCM-SHA256/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/Server1.Encryption=no/Server1.Encryption=yes/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/Server1.Connections=4/Server1.Connections=50/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/UrlConnections=4/UrlConnections=1/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/Category4.Name=Software/Category4.Name=Books/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i '/^Category4.Name=Books/a Category5.Name=XXX' /usr/share/nginx/nzbget/config/nzbget.conf
sed -i '/^Category5.Name=XXX/a Category6.Name=Others' /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/PostStrategy=sequential/PostStrategy=rocket/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/PostStrategy=balanced/PostStrategy=rocket/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/PostStrategy=aggressive/PostStrategy=rocket/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/DirectUnpack=no/DirectUnpack=yes/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/DirectRename=no/DirectRename=yes/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/ArticleCache=0/ArticleCache=200/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/WriteBuffer=0/WriteBuffer=1024/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/ArticleRetries=3/ArticleRetries=99/g" /usr/share/nginx/nzbget/config/nzbget.conf
sed -i "s/UrlRetries=3/UrlRetries=99/g" /usr/share/nginx/nzbget/config/nzbget.conf

## sonarr
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/sonarr\/<\/UrlBase>/g" /usr/share/nginx/sonarr/config/config.xml
sed -i '$d' /usr/share/nginx/sonarr/config/config.xml
echo '  <AnalyticsEnabled>False</AnalyticsEnabled>' >> /usr/share/nginx/sonarr/config/config.xml
echo '</Config>' >> /usr/share/nginx/sonarr/config/config.xml
sqlite3 /usr/share/nginx/sonarr/config/sonarr.db  "insert into RootFolders values ('1','/data/media/Series/');"
sqlite3 /usr/share/nginx/sonarr/config/sonarr.db  "DELETE FROM Metadata WHERE Id = 1;"
sqlite3 /usr/share/nginx/sonarr/config/sonarr.db  "insert into Metadata values ('1','1','Kodi (XBMC) / Emby','XbmcMetadata','{
  \"seriesMetadata\": true,
  \"seriesMetadataUrl\": false,
  \"episodeMetadata\": true,
  \"seriesImages\": true,
  \"seasonImages\": true,
  \"episodeImages\": true,
  \"isValid\": true
}','XbmcMetadataSettings');"
sqlite3 /usr/share/nginx/sonarr/config/sonarr.db  "DELETE FROM LanguageProfiles WHERE Id = 1;"
sqlite3 /usr/share/nginx/sonarr/config/sonarr.db  "insert into LanguageProfiles values ('1','Chinese','[
  {
    \"language\": 0,
    \"allowed\": false
  },
  {
    \"language\": 13,
    \"allowed\": false
  },
  {
    \"language\": 17,
    \"allowed\": false
  },
  {
    \"language\": 14,
    \"allowed\": false
  },
  {
    \"language\": 3,
    \"allowed\": false
  },
  {
    \"language\": 11,
    \"allowed\": false
  },
  {
    \"language\": 18,
    \"allowed\": false
  },
  {
    \"language\": 12,
    \"allowed\": false
  },
  {
    \"language\": 15,
    \"allowed\": false
  },
  {
    \"language\": 24,
    \"allowed\": false
  },
  {
    \"language\": 21,
    \"allowed\": false
  },
  {
    \"language\": 5,
    \"allowed\": false
  },
  {
    \"language\": 9,
    \"allowed\": false
  },
  {
    \"language\": 22,
    \"allowed\": false
  },
  {
    \"language\": 27,
    \"allowed\": false
  },
  {
    \"language\": 23,
    \"allowed\": false
  },
  {
    \"language\": 20,
    \"allowed\": false
  },
  {
    \"language\": 4,
    \"allowed\": false
  },
  {
    \"language\": 2,
    \"allowed\": false
  },
  {
    \"language\": 19,
    \"allowed\": false
  },
  {
    \"language\": 16,
    \"allowed\": false
  },
  {
    \"language\": 7,
    \"allowed\": false
  },
  {
    \"language\": 6,
    \"allowed\": false
  },
  {
    \"language\": 25,
    \"allowed\": false
  },
  {
    \"language\": 28,
    \"allowed\": false
  },
  {
    \"language\": 26,
    \"allowed\": false
  },
  {
    \"language\": 8,
    \"allowed\": true
  },
  {
    \"language\": 1,
    \"allowed\": true
  },
  {
    \"language\": 10,
    \"allowed\": true
  }
]','10','0');"

sqlite3 /usr/share/nginx/sonarr/config/sonarr.db  "DELETE FROM NamingConfig WHERE Id = 1;"
sqlite3 /usr/share/nginx/sonarr/config/sonarr.db  "insert into NamingConfig values ('1','0','1','{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Full}','{Series Title} - {Air-Date} - {Episode Title} {Quality Full}','Season {season}','{Series Title}','{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Full}','1','Specials');"
add_download_client_sonarr
sonarr_api=$(xml_grep 'ApiKey' /usr/share/nginx/sonarr/config/config.xml --text_only)

## radarr
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/radarr\/<\/UrlBase>/g" /usr/share/nginx/radarr/config/config.xml
sed -i '$d' /usr/share/nginx/radarr/config/config.xml
echo '  <AnalyticsEnabled>False</AnalyticsEnabled>' >> /usr/share/nginx/radarr/config/config.xml
echo '</Config>' >> /usr/share/nginx/radarr/config/config.xml
sqlite3 /usr/share/nginx/radarr/config/radarr.db  "insert into RootFolders values ('1','/data/media/Movies/');"
sqlite3 /usr/share/nginx/radarr/config/radarr.db  "insert into Config values ('6','movieinfolanguage','10');"
sqlite3 /usr/share/nginx/radarr/config/radarr.db  "insert into Config values ('7','uilanguage','10');"
sqlite3 /usr/share/nginx/radarr/config/radarr.db  "UPDATE Metadata SET Enable = 1 WHERE Id = 1;"
sqlite3 /usr/share/nginx/radarr/config/radarr.db  "DELETE FROM Metadata WHERE Id = 1;"
sqlite3 /usr/share/nginx/radarr/config/radarr.db  "insert into Metadata values ('1','1','Kodi (XBMC) / Emby','XbmcMetadata','{
  \"movieMetadata\": true,
  \"movieMetadataURL\": false,
  \"movieMetadataLanguage\": 10,
  \"movieImages\": true,
  \"useMovieNfo\": false,
  \"isValid\": true
}','XbmcMetadataSettings');"
sqlite3 /usr/share/nginx/radarr/config/radarr.db  "DELETE FROM NamingConfig WHERE Id = 1;"
sqlite3 /usr/share/nginx/radarr/config/radarr.db  "insert into NamingConfig values ('1','0','1','{Movie Title} ({Release Year}) {Quality Full}','{Movie Title} ({Release Year})','0','1');"
add_download_client_radarr
radarr_api=$(xml_grep 'ApiKey' /usr/share/nginx/radarr/config/config.xml --text_only)

## lidarr
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/lidarr\/<\/UrlBase>/g" /usr/share/nginx/lidarr/config/config.xml
sed -i '$d' /usr/share/nginx/lidarr/config/config.xml
echo '  <AnalyticsEnabled>False</AnalyticsEnabled>' >> /usr/share/nginx/lidarr/config/config.xml
echo '</Config>' >> /usr/share/nginx/lidarr/config/config.xml
sqlite3 /usr/share/nginx/lidarr/config/lidarr.db  "insert into RootFolders values ('1','/data/media/Music/','music','1','1','0','[]');"
sqlite3 /usr/share/nginx/lidarr/config/lidarr.db  "DELETE FROM Metadata WHERE Id = 1;"
sqlite3 /usr/share/nginx/lidarr/config/lidarr.db  "insert into Metadata values ('1','1','Kodi (XBMC) / Emby','XbmcMetadata','{
  \"artistMetadata\": true,
  \"albumMetadata\": true,
  \"artistImages\": true,
  \"albumImages\": true,
  \"isValid\": true
}','XbmcMetadataSettings');"
sqlite3 /usr/share/nginx/lidarr/config/lidarr.db  "DELETE FROM NamingConfig WHERE Id = 1;"
sqlite3 /usr/share/nginx/lidarr/config/lidarr.db  "insert into NamingConfig values ('1','1','{Artist Name}','1','{Album Title} ({Release Year})/{Artist Name} - {Album Title} - {track:00} - {Track Title}','{Album Title} ({Release Year})/{Medium Format} {medium:00}/{Artist Name} - {Album Title} - {track:00} - {Track Title}');"
add_download_client_lidarr
lidarr_api=$(xml_grep 'ApiKey' /usr/share/nginx/lidarr/config/config.xml --text_only)

## readarr
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/readarr\/<\/UrlBase>/g" /usr/share/nginx/readarr/config/config.xml
sed -i '$d' /usr/share/nginx/readarr/config/config.xml
echo '  <AnalyticsEnabled>False</AnalyticsEnabled>' >> /usr/share/nginx/readarr/config/config.xml
echo '</Config>' >> /usr/share/nginx/readarr/config/config.xml
# sqlite3 /usr/share/nginx/readarr/config/readarr.db  "insert into RootFolders values ('1','/data/media/Books/','Books','1','1','0','[]','0','','0');"
sqlite3 /usr/share/nginx/readarr/config/readarr.db  "DELETE FROM NamingConfig WHERE Id = 1;"
sqlite3 /usr/share/nginx/readarr/config/readarr.db  "insert into NamingConfig values ('1','1','{Author Name}','1','{Book Title}/{Author Name} - {Book Title}{ (PartNumber)}');"
sqlite3 /usr/share/nginx/readarr/config/readarr.db  "insert into Config values ('6','uilanguage','10');"
add_download_client_readarr
readarr_api=$(xml_grep 'ApiKey' /usr/share/nginx/readarr/config/config.xml --text_only)

## prowlarr 8191
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/prowlarr\/<\/UrlBase>/g" /usr/share/nginx/prowlarr/config/config.xml
sed -i '$d' /usr/share/nginx/prowlarr/config/config.xml
echo '  <AnalyticsEnabled>False</AnalyticsEnabled>' >> /usr/share/nginx/prowlarr/config/config.xml
echo '</Config>' >> /usr/share/nginx/prowlarr/config/config.xml
add_prowlarr_sonarr_radarr_lidarr_readarr
sqlite3 /usr/share/nginx/prowlarr/config/prowlarr.db  "insert into Tags values ('1','flaresolverr');"
sqlite3 /usr/share/nginx/prowlarr/config/prowlarr.db  "insert into IndexerProxies values ('1','FlareSolverr','{
  \"host\": \"http://127.0.0.1:8191/\",
  \"requestTimeout\": 60
}','FlareSolverr','FlareSolverrSettings','[
  1
]');"
sqlite3 /usr/share/nginx/prowlarr/config/prowlarr.db  "insert into Config values ('6','uilanguage','10');"
add_download_client_prowlarr

## Jackett 9696
# cat '/usr/share/nginx/jackett/config/Jackett/ServerConfig.json' | jq '.BasePathOverride |= "/jackett/"' >> /usr/share/nginx/jackett/config/Jackett/tmp.json
# cp -f /usr/share/nginx/jackett/config/Jackett/tmp.json /usr/share/nginx/jackett/config/Jackett/ServerConfig.json
# rm /usr/share/nginx/jackett/config/Jackett/tmp.json
# cat '/usr/share/nginx/jackett/config/Jackett/ServerConfig.json' | jq '.AllowExternal |= false' >> /usr/share/nginx/jackett/config/Jackett/tmp.json
# cp -f /usr/share/nginx/jackett/config/Jackett/tmp.json /usr/share/nginx/jackett/config/Jackett/ServerConfig.json
# rm /usr/share/nginx/jackett/config/Jackett/tmp.json
# cat '/usr/share/nginx/jackett/config/Jackett/ServerConfig.json' | jq '.FlareSolverrUrl |= "http://127.0.0.1:8191"' >> /usr/share/nginx/jackett/config/Jackett/tmp.json
# cp -f /usr/share/nginx/jackett/config/Jackett/tmp.json /usr/share/nginx/jackett/config/Jackett/ServerConfig.json
# rm /usr/share/nginx/jackett/config/Jackett/tmp.json

## bazarr
sed -i "0,/base_url \=/s//base_url \= \/bazarr/g" /usr/share/nginx/bazarr/config/config/config.ini
sed -i '/^\[sonarr\]$/,/^\[/ s/^base_url = \//base_url = \/sonarr\//' /usr/share/nginx/bazarr/config/config/config.ini
sed -i "/^\[sonarr\]$/,/^\[/ s/^apikey =/apikey = ${sonarr_api}/" /usr/share/nginx/bazarr/config/config/config.ini
sed -i '/^\[radarr\]$/,/^\[/ s/^base_url = \//base_url = \/radarr\//' /usr/share/nginx/bazarr/config/config/config.ini
sed -i "/^\[radarr\]$/,/^\[/ s/^apikey =/apikey = ${radarr_api}/" /usr/share/nginx/bazarr/config/config/config.ini
sed -i '/^\[analytics\]$/,/^\[/ s/^enabled = True/enabled = False/' /usr/share/nginx/bazarr/config/config/config.ini
sed -i "s/use_sonarr = False/use_sonarr = True/g" /usr/share/nginx/bazarr/config/config/config.ini
sed -i "s/use_radarr = False/use_radarr = True/g" /usr/share/nginx/bazarr/config/config/config.ini
sed -i "s/serie_default_enabled = False/serie_default_enabled = True/g" /usr/share/nginx/bazarr/config/config/config.ini
sed -i "s/serie_default_profile =/serie_default_profile = 1/g" /usr/share/nginx/bazarr/config/config/config.ini
sed -i "s/movie_default_enabled = False/movie_default_enabled = True/g" /usr/share/nginx/bazarr/config/config/config.ini
sed -i "s/movie_default_profile =/movie_default_profile = 1/g" /usr/share/nginx/bazarr/config/config/config.ini
sed -i '/^\[assrt\]$/,/^\[/ s/^token =/token = oHwtSNdY1aQe1qwRSZVo70SqNW0Pu1AM/' /usr/share/nginx/bazarr/config/config/config.ini ## 5次/分钟
sed -i '/^\[betaseries\]$/,/^\[/ s/^token =/token = ecd1f45f3036/' /usr/share/nginx/bazarr/config/config/config.ini
sed -i "s/enabled_providers = \[\]/enabled_providers = \['zimuku', 'assrt', 'yifysubtitles', 'betaseries', 'opensubtitlescom', 'supersubtitles', 'tvsubtitles', 'subscenter'\]/g" /usr/share/nginx/bazarr/config/config/config.ini
sqlite3 /usr/share/nginx/bazarr/config/db/bazarr.db  "insert into table_languages_profiles values ('1','','[{\"id\": 1, \"language\": \"zh\", \"audio_exclude\": \"False\", \"hi\": \"False\", \"forced\": \"False\"}, {\"id\": 2, \"language\": \"zt\", \"audio_exclude\": \"False\", \"hi\": \"False\", \"forced\": \"False\"}, {\"id\": 3, \"language\": \"en\", \"audio_exclude\": \"False\", \"hi\": \"False\", \"forced\": \"False\"}]','Chinese','[]','[]');"

## chinesesubfinder 19035
#     cat > "/usr/share/nginx/chinesesubfinder/config/ChineseSubFinderSettings.json" << EOF
# {"user_info":{"username":"admin","password":"${password1}"},"common_settings":{"scan_interval":"6h","threads":1,"run_scan_at_start_up":false,"movie_paths":["/media/Movies/"],"series_paths":["/media/Series/"]},"advanced_settings":{"proxy_settings":{"use_http_proxy":false,"http_proxy_address":""},"debug_mode":false,"save_full_season_tmp_subtitles":false,"sub_type_priority":0,"sub_name_formatter":0,"save_multi_sub":false,"custom_video_exts":[],"fix_time_line":false,"topic":1},"emby_settings":{"enable":true,"address_url":"http://127.0.0.1:8096","api_key":"","max_request_video_number":3000,"skip_watched":true,"movie_paths_mapping":{"/media/Movies/":"/data/media/Movies/"},"series_paths_mapping":{"/media/Series/":"/data/media/Series/"}},"developer_settings":{"enable":false,"bark_server_address":""},"timeline_fixer_settings":{"max_offset_time":120,"min_offset":0.1},"experimental_function":{"auto_change_sub_encode":{"enable":false,"des_encode_type":0}}}
# EOF

## ombi 3579
add_sonarr_ombi
add_radarr_ombi
add_lidarr_ombi
sqlite3 /usr/share/nginx/ombi/config/OmbiSettings.db  "DELETE FROM GlobalSettings WHERE Id = 1;"
sqlite3 /usr/share/nginx/ombi/config/OmbiSettings.db  "insert into GlobalSettings values ('1','{\"BaseUrl\":\"/ombi\",\"CollectAnalyticData\":false,\"Wizard\":false,\"ApiKey\":\"dfbcab4789604b4289b3cdc71aa41bf6\",\"DoNotSendNotificationsForAutoApprove\":false,\"HideRequestsUsers\":false,\"DisableHealthChecks\":false,\"DefaultLanguageCode\":\"zh\",\"AutoDeleteAvailableRequests\":false,\"AutoDeleteAfterDays\":0,\"Branch\":0,\"HasMigratedOldTvDbData\":false,\"Set\":false,\"Id\":1}','OmbiSettings');"
docker-compose up -d
}