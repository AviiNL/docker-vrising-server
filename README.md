# V Rising Dedicated Server - Docker

Adjust Environment variables accordingly

docker-compose.yml
```
version: '3.3'

services:
  vrising:
    container_name: vrising_server
    image: aviinl/vrising-server
    restart: unless-stopped
    ports:
      - "9876:9876/udp"
      - "9877:9877/udp"
    environment:
      - APP_ID=1829350
      - AUTO_UPDATE=true
      - ENABLE_BEPINEX=true
      - SERVER_NAME=V Rising Docker
      - WORLD_NAME=world1
    volumes:
      - ./steamcmd:/serverdata/steamcmd
      - ./vrising:/serverdata/serverfiles
```

Start as service:

```
docker-compose up -d
```

Show Logs (and follow):

```
docker-compose logs -f
```