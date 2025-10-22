# MediaWiki Runner for local module development in VSCode

Clone this package into your local installation of MediaWiki w/ Scribunto, and you can debug your lua modules locally, using the same exact code as in your deployed modules, like "Module:" namespace. The main file (mw_runner.lua) looks for this namespace and replaces it with your paths as set in your launch environment variables.

This performs NO remote/server requests; all content must be on your local filesystem. It currently does not make any API calls to your local MediaWiki database either, although I'd like to in the future so this can support expanding templates.

To access any files through the mw library (not an API call), the Mediawiki server much be running. If no content files are required, editing can happen offline. When you save your module files, and refresh your browser, changes should be reflected immediately, because your code editor and the MediaWiki server are accessing the same files.

Examples of things this can do:
* load any data files (.csv, .json, or a lua module) from the database through mw.title.new, like Module:MyModule/Data.csv
* import other modules via the same code as on your production server, require("Module:MyModule")
* return html with the mw.html library
* step through Lua code and examine variables for debugging


## 21 Oct 2025
Now emulates setting the frame for mw.getCurrentFrame calls to work inside modules.

Can also serve both direct-debugging of modules exactly as-is on your live MW production site (but without invoking their functions) and test script files. An example script file is provided that requires a module and calls its main function just like a template call from a page on a wiki site.

Note that you do not need to (and cannot) require("mw_runner") in the test script or it will cause an infinite loop of invoking itself.


## 21 Oct 2025
I skipped writing a template auto-updater that would publish updates to template (or content I suppose) files via your MW localhost's API.

The mw_runner now wraps title.new, json.decode, and the basic require to properly inject your path. be sure your path is set in launch settings. example paths are provided (and required for mw_runner to work).


## 19 Oct 2025
The .vscode/settings.json Removes all superfluous folders and files from the VSCode explorer. If you ever can't find a file (or I suppose try to create a file but are told it already exists), this is the first place to look.

.cursorignore does not have the token file
.gitignore does not have LocalSettings or token file

Be sure to have launch.json env set all three MW_PATH and LUA_LIB_PATH and MODULE_PATH that identify your local paths.

Note for later if I ever get to using the API, you need to store your token in plain text in csrftoken.txt
You can find your token by: http://localhost:4000/api.php?action=query&meta=tokens&type=csrf&format=json

In your LocalSettings.php, make sure you add this so template saves in VSCode can be automatically pushed to the local database for testing:
Disable requiring login since this is local, so the API can be used directly without a session
$wgGroupPermissions['*']['edit'] = true;


## About MediaWiki

MediaWiki is a free and open-source wiki software package written in PHP. It
serves as the platform for Wikipedia and the other Wikimedia projects, used
by hundreds of millions of people each month. MediaWiki is localised in over
350 languages and its reliability and robust feature set have earned it a large
and vibrant community of third-party users and developers.

MediaWiki is:

* feature-rich and extensible, both on-wiki and with hundreds of extensions;
* scalable and suitable for both small and large sites;
* simple to install, working on most hardware/software combinations; and
* available in your language.

For system requirements, installation, and upgrade details, see the files
RELEASE-NOTES, INSTALL, and UPGRADE.

* Ready to get started?
  * https://www.mediawiki.org/wiki/Special:MyLanguage/Download
* Setting up your local development environment?
  * https://www.mediawiki.org/wiki/Local_development_quickstart
* Looking for the technical manual?
  * https://www.mediawiki.org/wiki/Special:MyLanguage/Manual:Contents
* Seeking help from a person?
  * https://www.mediawiki.org/wiki/Special:MyLanguage/Communication
* Looking to file a bug report or a feature request?
  * https://bugs.mediawiki.org/
* Interested in helping out?
  * https://www.mediawiki.org/wiki/Special:MyLanguage/How_to_contribute

MediaWiki is the result of global collaboration and cooperation. The CREDITS
file lists technical contributors to the project. The COPYING file explains
MediaWiki's copyright and license (GNU General Public License, version 2 or
later). Many thanks to the Wikimedia community for testing and suggestions.



