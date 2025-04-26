# Moinmoin to Mediawiki migration Manual

This guide is a collection of notes taken during the migration of some W3C wikis from the moinmoin to mediawiki engine when consolidating our wiki services under a single platform. Moinmoin and mediawiki are both excellent wiki platforms: use the one that works for you, and if you wish to migrate from the former to the latter, feel free to use or hack on our migration script, but at your own risks. This guide, just like the software, are provided *as is* and without warranty.

We will take as example the migration of a moinmoin wiki codenamed "foo" e.g for foo located at http://www.w3.org/2008/foo/wiki/. The following instructions are rather specific to the W3C setup but may be fairly easily adapted to any case.

## temporarily relocate the moinmoin wiki to a different URI

... e.g /2008/foo/wiki2/. This is necessary because the migration script talks to mediawiki via HTTP. Therefore, the mediawiki engine needs to be online and at its final URI before the migration can be made.

(the following is w3c-wiki-specific, since our moinmoin system uses a farm of wikis)
1. edit /etc/moin/farmconfig.py: change URI regexp to r"/2008/foo/wiki2" (remove the www.w3.org part)
1. edit /etc/apache2/sites-available/esw.w3.org
   * change the ScriptAlias URI
   * remove the part below about allow, deny (which is used to make sure only www.w3.org mirrors access the system)
1. /etc/apache2/sites-available/esw.w3.org, temporarily comment out the jubjub/esw "redirects" used to keep URI space under www.w3.org
1. restart apache. test the temporary wiki URI with e.g lynx http://localhost/2008/foo/wiki2/

## Create the mediawiki instance, and test it
We have [W3C-specific instructions](http://www.w3.org/Systems/Wiki), but others can find a vanilla guide over at [mediawiki.org](http://www.mediawiki.org/wiki/Installation)

Make sure that php on the server is given enough memory, and, if you are going to migrate moinmoin attachments/uploads, make sure to enable it in php, and to increase the upload size limit: this will save you trouble later.

```
    max_execution_time = 60     ; Maximum execution time of each script, in seconds
    max_input_time = 100 ; Maximum amount of time each script may spend parsing request data
    memory_limit = 32M      ; Maximum amount of memory a script may consume (16MB)
;…
    ; Temporary directory for HTTP uploaded files (will use system default if not
    ; specified).
    upload_tmp_dir = /tmp/http
;…
    ; Maximum allowed size for uploaded files.
    upload_max_filesize = 6M
```

For W3C wikis, any access-control in moinmoin needs to be mirrored in the mediawiki config.

Now, create a user on the mediawiki. Use Special:Userrights to make sure  
that this user has high credentials (or use the Sysop user). Check whether attachments are enabled via the LocalConfig.php

## Proceed with the migration
It will be assumed that you have downloaded the [script](http://dev.w3.org/cvsweb/2008/moinmoin2mediawiki/)
into ~/moinmoin2mediawiki/bin and that the moinmoin data for the wiki is in /u/wiki/foo/data/ Now go to ~/moinmoin2mediawiki, and run:

Some characters will fail the import. The script should be updated to handle them but they can be fixed manually:
  - Convert decimal 01 or \%x01 to ' '
  - Convert decimal 04 or \%x04 to 'x04'
  - Convert decimal 19 or \%x13 to '-'
  - Convert decimal 20 or \%x14 to ' '
  - Convert decimal 25 or \%x19 to '\''

``` bash
perl ./bin/mm2mw.pl

# type the following
#  make sure to use the wiki's actual URI for "url"
#  and use the temporary location of the moinmoin wiki
src /u/wiki/foo/data/
dst ./data-out/foo
url http://localhost/2008/foo/wiki/index.php
mmurl http://localhost/2008/foo/wiki2/
analyse
login
#(here you'll be prompted for login info for the sysop user)
convert
upload
```

## Post Migration Commands

``` bash
php maintenance/run.php update --conf LocalSettings.php
```

... The new mediawiki should be all set. You can now go back and reset the apache2 config appropriately... remove the temporary stuff for the moinmoin instance... and communicate with the users about their "new" wiki

# Steps to perform after a migration from Moin Moin

## Update the landing page to Frontpage.

Search for: 'MediaWiki:Mainpage'
Edit with: FrontPage

## Interwiki links

During the conversion, interwikilinks.txt gets generated. Add them in the Special:Interwiki page. Then refresh the links with: 

``` bash
php maintenance/run.php update --conf LocalSettings.php
php maintenance/refreshLinks.php update --conf LocalSettings.php
```

## Review Quality

Most problems have to do with indented code blocks, review the pages in indentedcodeblocks.txt.


## Setup the logo

