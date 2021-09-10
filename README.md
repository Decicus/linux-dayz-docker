# linux-dayz-docker

For [1.14 experimental, Linux support for servers was finally released](https://forums.dayz.com/topic/251335-experimental-update-114-changelog/?page=4&tab=comments#comment-2472603). This is my half-assed attempt at creating a Docker container for running a (barebones) DayZ server.

## Requirements

- A Steam account with DayZ
    - This is required to be able to download the server files via `steamcmd`, which is a tool used by the `download.sh` helper script.
    - Also required for DayZ workshop content
- System/server specifications matching the [minimum requirements](https://forums.dayz.com/topic/239635-dayz-server-files-documentation/?tab=comments#comment-2396573)
    - During my testing I was running a VM with 6 dedicated threads and 32 GB RAM, on Debian 11 (though OS doesn't matter much).
    - By default the `docker-compose.yml` file limits the memory usage to 8 GB (`mem_limit`). Feel free to tweak as-is.
    - From my experience: 3 threads/cores + 5 GB RAM available for the DayZ server is the absolute minimum.
- A Linux OS with `bash` installed, as I have no idea if my `download.sh` script is POSIX-compatible.
    - I use Debian 11 (Bullseye) as I'm writing, but other major OSes such as Ubuntu/CentOS will likely work just fine.
- Server also needs Docker & [Docker Compose](https://docs.docker.com/compose/) installed

## Things that need to be done manually at the moment
- Mount the `whitelist.txt` / `priority.txt` files in the Docker Compose file
- Remote access via RCON isn't enabled by default. You can configure that [by following the steps on Bohemia's wiki](https://community.bistudio.com/wiki/DayZ:Server_Configuration#BattlEye_Configuration)
    - Unless `-bePath` is used, the path for BattlEye should be: `server_files/battleye/beserver_x64.cfg`
    - You will also need to **forward** the RCON port in the `docker-compose.yml` file. By default I think it is `2303` (`gamePort + 1 = rconPort`)

## Known issues
- Crashes. Server will often crash and "hang". I haven't been able to look into _why_, nor how to detect it. You'll just have to watch logs and manually restart accordingly (`docker-compose down && docker-compose up -d`).

## Setup

1. Run `./download.sh`, which will prompt you for your Steam username + password (+ two-factor code, if you have that).
    - Unless script has been modified to, it will download into the directory: `server_files`
2. Copy `serverDZ.example.cfg` to a new file called `serverDZ.cfg`. Edit the configuration options as you see fit.
    - **Optional**: Copy extra configuration options from the `serverDZ_extra.example.cfg` file into the `serverDZ.cfg` file you created.
3. Run `docker-compose up -d` to start up the server
4. **Optional**: Run `docker-compose logs -ft` to watch the console/server logs. Hit CTRL+C to get out of the logs.

Once you're done with the server, run `docker-compose down` to shut the server/container down.  
If you wanna boot it back up, just run `docker-compose up -d` again.

## Workshop content
For workshop content, run `./download.sh -w WORKSHOP_ID_HERE`, which will prompt you for your Steam username _and_ a "Workshop mod name".  
Once again, it seems that having a Steam account with a copy of DayZ is required.

- The "Workshop mod name" is used to create a folder within `server_files/<Worshop Mod Name Here>`, where mod files are later copied into.
- All workshop content will be downloaded to the `workshop_mods` folder.

I am not entirely sure if this is the _correct_ method. I have literally zero experience with DayZ servers, so you might have to look into proper methods yourself.

## Thanks to

- Corbpie for having a pretty solid blog post on [how to set up a DayZ server on Windows](https://write.corbpie.com/dayz-server-setup-and-install-on-windows-server-2019-with-steamcmd/). While I'm doing it on Linux, it was still useful for command-line flags and whatnot.
