#!/usr/bin/env bash

# this script aims to simplify the process of updating the theme examples page
# in the GitHub Wiki.
#
# it is built with the assumption that the relevant wiki is cloned with Git
# alongside this repo, but with the understanding that this may not always be
# true.
#
# it also assumes the associated `Themes.md` file exists at the root of the
# wiki, and contains the relevant "start" and "end" markers for a safe space to
# re-render the theme examples.
#
# runtime overrides, where CLI args override env vars:
#
# - set OMB Wiki project folder path
#   - `OMB_WIKI_PATH` variable
#   - `-p | --wiki-path` argument
# - set OMB Wiki "themes" page path
#   - `OMB_WIKI_THEMES_FILE` variable
#   - `-f | --themes-file` argument
# - set OMB Wiki "themes" page "start" marker
#   - `OMB_WIKI_THEMES_START_MARKER` variable
#   - `-s | --start-marker` argument
# - set OMB Wiki "themes" page "end" marker
#   - `OMB_WIKI_THEMES_END_MARKER` variable
#   - `-e | --end-marker` argument

# first process current env vars, with some sensible default fallback values...

SCRIPT_WIKI_PATH="${OMB_WIKI_PATH:-../oh-my-bash.wiki}"
SCRIPT_WIKI_THEMES_FILE="${OMB_WIKI_THEMES_FILE:-Themes.md}"
SCRIPT_WIKI_THEMES_START_MARKER="${OMB_WIKI_THEMES_START_MARKER:-<!-- THEME_GEN_START_MARKER -->}"
SCRIPT_WIKI_THEMES_END_MARKER="${OMB_WIKI_THEMES_END_MARKER:-<!-- THEME_GEN_END_MARKER -->}"

# then process any cli args, if provided...

VALID_ARGS=$(getopt -o p:f:s:e: --long wiki-path:,themes-file:,start-marker:,end-marker: -- "$@")
if [[ $? -ne 0 ]]; then
  exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
  -p | --wiki-path)
    # echo "Processing 'wiki-path' option. Input argument is '$2'"
    SCRIPT_WIKI_PATH="$2"
    shift 2
    ;;
  -f | --themes-file)
    # echo "Processing 'themes-file' option. Input argument is '$2'"
    SCRIPT_WIKI_THEMES_FILE="$2"
    shift 2
    ;;
  -s | --start-marker)
    # echo "Processing 'start-marker' option. Input argument is '$2'"
    SCRIPT_WIKI_THEMES_START_MARKER="$2"
    shift 2
    ;;
  -e | --end-marker)
    # echo "Processing 'end-marker' option. Input argument is '$2'"
    SCRIPT_WIKI_THEMES_END_MARKER="$2"
    shift 2
    ;;
  --) shift;
      break
      ;;
  esac
done

# debug: this will either be adapted for the final script, or removed entirely..
echo "current SCRIPT_WIKI_PATH: $SCRIPT_WIKI_PATH"
echo "current SCRIPT_WIKI_THEMES_FILE: $SCRIPT_WIKI_THEMES_FILE"
echo "current SCRIPT_WIKI_THEMES_START_MARKER: $SCRIPT_WIKI_THEMES_START_MARKER"
echo "current SCRIPT_WIKI_THEMES_END_MARKER: $SCRIPT_WIKI_THEMES_END_MARKER"

# verify that the OMB Wiki project exists...
if [[ ! -d "$SCRIPT_WIKI_PATH" ]]; then
  echo "ERROR: Wiki project path '$SCRIPT_WIKI_PATH' does not exist."
  exit 1;
fi

# verify that the OMB Wiki contains the expected themes file...
if [[ ! -f "$SCRIPT_WIKI_PATH/$SCRIPT_WIKI_THEMES_FILE" ]]; then
  echo "ERROR: Wiki project has no themes file called '$SCRIPT_WIKI_THEMES_FILE'."
  exit 1;
fi

# verify that the OMB Wiki contains the expected start and end markers...
if ! (grep -q "$SCRIPT_WIKI_THEMES_START_MARKER" "$SCRIPT_WIKI_PATH/$SCRIPT_WIKI_THEMES_FILE"); then
  echo "ERROR: Wiki themes file does not contain start marker '$SCRIPT_WIKI_THEMES_START_MARKER'."
  exit 1
fi
if ! (grep -q "$SCRIPT_WIKI_THEMES_END_MARKER" "$SCRIPT_WIKI_PATH/$SCRIPT_WIKI_THEMES_FILE"); then
  echo "ERROR: Wiki themes file does not contain end marker '$SCRIPT_WIKI_THEMES_END_MARKER'."
  exit 1
fi

# now we get onto the fun stuff, lets get a list of all current themes...

# find all themes in the current themes directory...
theme_list=$(find "./themes" -mindepth 1 -maxdepth 1 -type d -print | sort | xargs -n1 basename)

# prepare a variable to hold generated content, starting with with the "start" marker for next run...
markdown_text="$SCRIPT_WIKI_THEMES_START_MARKER\n\n"

# now we can loop through the list and find all images in each theme directory...
for theme in $theme_list; do
  theme_dir="./themes/${theme}"
  image_list=$(find "$theme_dir" -type f -name "*.png" -o -name "*.jpg")

  # start preparing a theme example markdown block...
  markdown_text="${markdown_text}## \`${theme}\`\n\n"

  # loop through the image list and add each image to the theme example entry...
  if [[ ! -z "$image_list" ]]; then
    for image in $image_list; do
      # Extract filename and construct image URL
      image_filename=$(basename "$image")
      image_url="https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/themes/$theme/$image_filename"

      # append image to theme example markdown block...
      markdown_text="${markdown_text}![](${image_url})\n"
    done
  else
    markdown_text="${markdown_text}WARNING: theme contains no example images.\n"
  fi

  # add one more newline before moving on...
  markdown_text="$markdown_text\n"
done

# inject the "end" marker for next run...
markdown_text="$markdown_text$SCRIPT_WIKI_THEMES_END_MARKER"

# now we can update the OMB Wiki "Themes" page directly...
sed -i "/$SCRIPT_WIKI_THEMES_START_MARKER/,/$SCRIPT_WIKI_THEMES_END_MARKER/c\\
$markdown_text" "$SCRIPT_WIKI_PATH/$SCRIPT_WIKI_THEMES_FILE"
