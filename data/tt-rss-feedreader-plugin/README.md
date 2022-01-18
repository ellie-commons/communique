# TT-RSS Communique plugin

This is a plugin for [Tiny-Tiny-RSS](http://tt-rss.org) web based news feed reader and aggregator.

It adds a new API calls to allow better interaction of Tiny-Tiny-RSS and clients (in this case Communique).

## API Reference


**addLabel**

Returns a JSON-encoded ID of the added label.

Parameters:
 * caption (string) - the caption of the label


**removeLabel**

Parameters:
 * label_id (int) - the id of the label


**renameLabel**

Parameters:
 * label_id (int) - the id of the label
 * caption (string) - new name of the label


**addCategory**

Returns a JSON-encoded ID of the added category.

Parameters:
 * caption (string) - the caption of the category
 * parent_id (int, optional) - id of the category the new one should be placed into


**removeCategory**

Parameters:
 * cateogry_id (int) - the id of the category


**moveCategory**

Parameters:
 * cateogry_id (int) - the id of the category
 * parent_id (int) - cateogry id of the new parent


**renameCategory**

Parameters:
 * cateogry_id (int) - the id of the category
 * caption (string) - new name of the category


**renameFeed**

Parameters:
 * feed_id (int) - the id of the feed
 * caption (string)  - new name of the feed


**moveFeed**

Parameters:
 * feed_id (int) - the id of the feed
 * category_id (int)  - id of category the feed will be moved to


## Installation
1. Install tt-rss in a docker container. Official tt-rss instructions can be found [here](https://tt-rss.org/wiki/InstallationNotes). 
2. Download the ZIP file for the latest release of Communique from [here](https://github.com/suzie97/communique/releases).
3. Copy the `data/tt-rss-feedreader-plugin/api_feedreader` folder inside the Communique archive to your clipboard.
4. Once you've set up your tt-rss container and got it runnung, check where the code of the tt-rss container is mounted: `docker volume inspect ttrss-docker_app | grep Mountpoint`. Your directory might be somewhat similar to this: `/var/lib/docker/volumes/ttrss-docker_app/_data`.
5. Navigate to the `tt-rss/plugins.local` folder within that folder. Eg: `/var/lib/docker/volumes/ttrss-docker_app/_data/tt-rss/plugins.local/`.
6. Paste the `api_feedreader` folder that was copied on step 2 here. You'll need `sudo` priviledges for this.
7. As this is a system-enabled plugin for the server, not an "user" plugin (that one would activate from withing the web interface), you will need to add it to a global configuration directive instead. How can you do it? The [recommended way on tt-rss wiki](https://tt-rss.org/wiki/GlobalConfig) is to _"adjust tt-rss global configuration through the environment (...) when using docker-compose setup"_:
    1. Edit the the environment file of the docker (the file named `.env` within the folder you had git cloned when you [installed TT-RSS server](https://git.tt-rss.org/fox/ttrss-docker-compose/src/branch/static-dockerhub/README.md)).
    2. Search for the line that starts with `TTRSS_PLUGINS=`
    2. Uncomment that line.
    3. Add `api_feedreader` to it. Eg: `TTRSS_PLUGINS=auth_internal,note,nginx_xaccel,api_feedreader`.

## License
This code is licensed under GPLv3.
