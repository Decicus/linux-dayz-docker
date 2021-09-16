# linux-dayz-docker
For [1.14 experimental, Linux support for servers was finally released](https://forums.dayz.com/topic/251335-experimental-update-114-changelog/?page=4&tab=comments#comment-2472603). This is my half-assed attempt at creating a Docker container for running a (barebones) DayZ server.

Please keep in mind that this **hasn't** been tested with more than maybe 3 players and shouldn't be considered stable at all.  
Crashes will occur, especially in experimental. Modding support probably isn't as stable as the Windows version etc.  
This has all been written/tested by an amateur when it comes to DayZ server hosting, so it's likely some information is inaccurate.

## Requirements
- System/server specifications matching the [minimum requirements](https://forums.dayz.com/topic/239635-dayz-server-files-documentation/?tab=comments#comment-2396573)
    - During my testing I was running a VM with 6 dedicated threads and 32 GB RAM, on Debian 11 (though OS doesn't matter much).
    - By default the `docker-compose.yml` file limits the memory usage to 8 GB (`mem_limit`). Feel free to tweak as you see fit for your system.
    - From my testing with the mentioned specs and monitoring the server's resource usage: 3 threads/cores + 5 GB RAM available for the DayZ server is the absolute minimum.
- A Linux OS with `bash` installed, as I have no idea if my `download.sh` script is POSIX-compatible.
    - I use Debian 11 (Bullseye) as I'm writing, but other major OSes such as Ubuntu/CentOS will likely work just fine.
- Familiarity with the Linux commandline is a "must", as this isn't really intended for "Linux newbies".
- Server also needs Docker & [Docker Compose](https://docs.docker.com/compose/) installed
- **Workshop content only**: A Steam account with DayZ
    - It seems Steam does not allow downloading workshop content "anonymously", nor can you download workshop content for games you do not own on Steam.

## Useful resources
1. [DayZ Server Files Documentation on DayZ Forums](https://forums.dayz.com/topic/239635-dayz-server-files-documentation/)
2. [DayZ Server Configuration on Bohemia's wiki](https://community.bistudio.com/wiki/DayZ:Server_Configuration)
    - Some duplicate information that's also included in #1.

## Things that need to be done manually at the moment
- Mount the `whitelist.txt` / `priority.txt` files in the Docker Compose file
- Remote access via RCON isn't enabled by default. You can configure that [by following the steps on Bohemia's wiki](https://community.bistudio.com/wiki/DayZ:Server_Configuration#BattlEye_Configuration)
    - Unless `-bePath` is used, the path for BattlEye should be: `server_files/battleye/beserver_x64.cfg`
    - You will also need to **forward** the RCON port in the `docker-compose.yml` file. By default I think it is `2303` (`gamePort + 1 = rconPort`)

## Known issues
- Crashes. Server will often crash and "hang". I haven't been able to look into _why_, nor how to detect it. You'll just have to watch logs and manually restart accordingly (`docker-compose down && docker-compose up -d`).
    - There doesn't seem to be a good way to really detect it, as the server seems to still respond to "queries" and acting responsive, even if it has crashed.

## Setup
1. Copy `serverDZ.example.cfg` to a new file called `serverDZ.cfg`. Edit the configuration options as you see fit.
    - **Optional**: Copy extra configuration options from the `serverDZ_extra.example.cfg` file into the `serverDZ.cfg` file you created.
2. Edit the file `docker-compose.yml` to match your server specs/needs.
    - Make sure all the paths (volumes), environment variables (for extra configuring) and memory limit matches what you want to limit your system to.
    - `CPU_COUNT` is practically "thread count" from what I understand. Easiest way to get that number is running `nproc`.
3. Run `docker-compose up -d` to start up the server. It will download the server files into `server_files` (unless changed in `docker-compose.yml`).
4. **Optional**: Run `docker-compose logs -ft` to watch the console/server logs. Hit CTRL+C to get out of the logs.

Once you're done with the server, run `docker-compose down` to shut the server/container down.  
If you wanna boot it back up, just run `docker-compose up -d` again.

Server updates will run using [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD) every time the server is started back up, so it might take a few extra seconds.

### Modifications to startup script
If you have modified the startup script (`run_server.sh`), you'll have to rebuild the container for script changes to apply.

Assuming you already have a running server while modifying the script:
1. `docker-compose down` to stop the server
2. `docker-compose build` to rebuild the container
3. `docker-compose up -d` to start the server back up again.

## Workshop content
For workshop content, run `./download.sh -w WORKSHOP_ID_HERE`, which will prompt you for your Steam username _and_ a "Workshop mod name".  
Specifically for DayZ workshop content you need a Steam account that owns DayZ.

- The "Workshop mod name" is used to create a folder within `server_files/<Workshop Mod Name Here>`, where mod files are later copied into.
- All workshop content will be downloaded to the `workshop_mods` folder.

I am not entirely sure if this is the _correct_ method. I have literally zero experience with DayZ servers, so you might have to look into proper methods yourself.

### Mod support
For mod support you will have to investigate yourself. You'll have to modify the launch options in `run_server.sh`, then rebuild the container using `docker-compose build` before (re)starting the server.

## Thanks to

- Corbpie - For having a pretty solid blog post on [how to set up a DayZ server on Windows](https://write.corbpie.com/dayz-server-setup-and-install-on-windows-server-2019-with-steamcmd/). While I'm doing it on Linux, it was still useful for command-line flags and whatnot.
