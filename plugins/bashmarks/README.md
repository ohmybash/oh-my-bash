# Bashmarks plugin

The Bashmarks plugin allows you to create and use bookmarks for directories on your filesystems. 

## Quickstart

Create a new bookmark using the *bm -a* command:

`$ bm -a mydir`

The command above creates a bookmark for the current directory with the name *mydir*. 

You can navigate to the location of a bookmark using the *bm -g* command: 

`$ bm -g mydir`

You can also supply just any bookmark name and the *-g* option will be assumed:

`$ bm mydir`

Tab completion is available when you need to enter a bookmark name in a command, such as when using *bm -g*

Easily list all bookmarks you have setup using the *bm -l* command.  

## Commands

**bm -h** Print short help text

**bm -a bookmarkname** Save the current directory as bookmarkname

**bm [-g] bookmarkname** Go to the specified bookmark

**bm -p bookmarkname** Print the bookmark 

**bm -d bookmarkname** Delete a bookmark

**bm -l** List all bookmarks

## Valid bookmark names

A bookmark name can contain lower and upper case characters (A-Z), numbers and underscore characters. No periods, semicolons, spaces or other characters are allowed in a bookmark name.
