#!/usr/bin/env bash

# this script aims to simplify the process of updating the theme examples page
# in the GitHub Wiki.
#
# it is built with the assumption that the relevant wiki is cloned with Git
# alongside this repo, but with the understanding that this may not always be
# true.
#
# it also assumes the associated `Themes.md` file contains the relevant "start"
# and "end" markers for a safe space to re-render the theme examples.
#
# Another assumption is that the OMB working tree contains the subdirectory
# "themes", which contain the directories of themes.

function print_usage {
  printf '%s\n' \
         'usage: tools/update-wiki-themes.sh [[-f|--themes-file] FILE |' \
         '            [-s|--start-marker] START | [-e|--end-marker] END]' \
         ''
}

function print_help {
  print_usage
  printf '%s\n' \
         'OPTIONS' \
         '' \
         '    When both the CLI argument and the environment variable are specified, the' \
         '    CLI argument overrides the envrionment variable.' \
         '' \
         '    -p, --omb-working-tree DIRECTORY' \
         '        Set the path to the OMB working tree.  This can also be specified' \
         '        through the environment variable "OMB_WORKING_TREE".  The default is' \
         '        determined based on the path of this script.' \
         '' \
         '    -f, --themes-file FILE' \
         '        Set OMB Wiki "themes" page path.  This can also be specified through' \
         '        the environment variable "OMB_WIKI_THEMES_FILE".  The default is' \
         '        "./wiki/Themes.md"' \
         '' \
         '    -s | --start-marker START' \
         '        Set OMB Wiki "themes" page "start" marker.  This can also be specified' \
         '        through the environment variable "OMB_WIKI_THEMES_START_MARKER".  The' \
         '        default is "<!-- OMB_WIKI_THEMES_START_MARKER -->"' \
         '' \
         '    -e | --end-marker END' \
         '        Set OMB Wiki "themes" page "end" marker.  This can also be specified' \
         '        through the environment variable "OMB_WIKI_THEMES_END_MARKER".  The' \
         '        default is "<!-- OMB_WIKI_THEMES_END_MARKER -->"' \
         '' \
         '    --help' \
         '        Print this help.' \
         ''
}

# first process current env vars, with some sensible default fallback values...

if [[ ! ${OMB_WORKING_TREE:-} ]]; then
  # Determine the default location of the working tree of Oh My Bash based on
  # ${BASH_SOURCE[0]}.
  path=${BASH_SOURCE[0]-}
  if [[ $path != */tools/* ]]; then
    resolved_path=$(realpath "$path" 2>/dev/null || readlink -f "$path" 2>/dev/null) &&
      [[ -e $resolved_path ]] &&
      path=$resolved_path
  fi
  if [[ $path == */tools/* ]]; then
    path=${path%/tools/*}
  elif [[ $path == */* ]]; then
    path=${path%/*}/..
  else
    path=..
  fi
  [[ -d $path ]] || path=.
  OMB_WORKING_TREE=$path
fi

OMB_WIKI_THEMES_FILE=${OMB_WIKI_THEMES_FILE:-../oh-my-bash.wiki/Themes.md}
OMB_WIKI_THEMES_START_MARKER=${OMB_WIKI_THEMES_START_MARKER:-'<!-- OMB_WIKI_THEMES_START_MARKER -->'}
OMB_WIKI_THEMES_END_MARKER=${OMB_WIKI_THEMES_END_MARKER:-'<!-- OMB_WIKI_THEMES_END_MARKER -->'}
OMB_WIKI_FLAG_HELP=

declare -A OMB_THEME_SUBTITLE=(
  [font]='(default theme)'
)

# then process any cli args, if provided...

if ! VALID_ARGS=$(getopt -o p:f:s:e: --long help,omb-working-tree:themes-file:,start-marker:,end-marker: -- "$@"); then
  exit 2
fi

eval "set -- $VALID_ARGS"
while (($#)); do
  case $1 in
  --help)
    OMB_WIKI_FLAG_HELP=set
    shift
    ;;
  -p | --omb-working-tree)
    OMB_WORKING_TREE=$2
    shift 2
    ;;
  -f | --themes-file)
    # echo "Processing 'themes-file' option. Input argument is '$2'"
    OMB_WIKI_THEMES_FILE=$2
    shift 2
    ;;
  -s | --start-marker)
    # echo "Processing 'start-marker' option. Input argument is '$2'"
    OMB_WIKI_THEMES_START_MARKER=$2
    shift 2
    ;;
  -e | --end-marker)
    # echo "Processing 'end-marker' option. Input argument is '$2'"
    OMB_WIKI_THEMES_END_MARKER=$2
    shift 2
    ;;
  --)
    shift
    break
    ;;
  *)
    break
    ;;
  esac
done

if (($#)); then
  printf '%s\n' 'unrecognized arguments are specified.' >&2
  print_usage >&2
  exit 2
fi

if [[ $OMB_WIKI_FLAG_HELP ]]; then
  print_help
  exit 0
fi

# debug: this will either be adapted for the final script, or removed entirely..
printf '%s\n' "current OMB_WORKING_TREE: $OMB_WORKING_TREE"
printf '%s\n' "current OMB_WIKI_THEMES_FILE: $OMB_WIKI_THEMES_FILE"
printf '%s\n' "current OMB_WIKI_THEMES_START_MARKER: $OMB_WIKI_THEMES_START_MARKER"
printf '%s\n' "current OMB_WIKI_THEMES_END_MARKER: $OMB_WIKI_THEMES_END_MARKER"

# verify the existence of the OMB working tree (which contains "themes"
# subdirectory).
if [[ ! -d $OMB_WORKING_TREE ]]; then
  printf '%s\n' "ERROR: The OMB working tree '$OMB_WORKING_TREE' is not found."
  exit 1
fi

# verify that the themes file exists...
if [[ ! -f $OMB_WIKI_THEMES_FILE ]]; then
  printf '%s\n' "ERROR: The themes file called '$OMB_WIKI_THEMES_FILE' does not exist."
  exit 1
fi

# verify that the OMB Wiki contains the expected start and end markers...
if ! grep -q "$OMB_WIKI_THEMES_START_MARKER" "$OMB_WIKI_THEMES_FILE"; then
  printf '%s\n' "ERROR: Wiki themes file does not contain start marker '$OMB_WIKI_THEMES_START_MARKER'."
  exit 1
fi
if ! grep -q "$OMB_WIKI_THEMES_END_MARKER" "$OMB_WIKI_THEMES_FILE"; then
  printf '%s\n' "ERROR: Wiki themes file does not contain end marker '$OMB_WIKI_THEMES_END_MARKER'."
  exit 1
fi

# now we get onto the fun stuff, lets get a list of all current themes...

# find all themes in the current themes directory...
theme_list=$(find "$OMB_WORKING_TREE/themes" -mindepth 1 -maxdepth 1 -type d -print | sort | xargs -n1 basename)

# prepare a variable to hold generated content, starting with with the "start" marker for next run...
markdown_text="$OMB_WIKI_THEMES_START_MARKER\n\n"
markdown_text="$markdown_text<!-- DO NOT EDIT THIS SECTION MANUALLY!\n     This section will be automatically overwritten. -->\n\n"

# now we can loop through the list and find all images in each theme directory...
for theme in $theme_list; do
  theme_dir=$OMB_WORKING_TREE/themes/$theme

  # Note: We skip the theme directories that do not have the actual theme file.
  # The directory of renamed/removed themes may remain in the working tree when
  # there are untracked files.
  [[ -s $theme_dir/$theme.theme.sh || -s $theme_dir/$theme.theme.bash ]] || continue

  image_list=$(find "$theme_dir" -type f -name "*.png" -o -name "*.jpg")

  # start preparing a theme example markdown block...
  title="\`$theme\`${OMB_THEME_SUBTITLE[$theme]:+ ${OMB_THEME_SUBTITLE[$theme]}}"
  markdown_text="$markdown_text## $title\n\n"

  # loop through the image list and add each image to the theme example entry...
  if [[ ! -z $image_list ]]; then
    for image in $image_list; do
      # Extract filename and construct image URL
      image_filename=$(basename "$image")
      image_url=https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/themes/$theme/$image_filename

      # append image to theme example markdown block...
      markdown_text="$markdown_text![$theme]($image_url)\n"
    done
  else
    markdown_text="${markdown_text}WARNING: theme contains no example images.\n"
    printf '\e[1;31m%s\e[m\n' "WARNING: theme '$theme' contains no example images." >&2
  fi

  # add one more newline before moving on...
  markdown_text="$markdown_text\n"
done

# inject the "end" marker for next run...
markdown_text=$markdown_text$OMB_WIKI_THEMES_END_MARKER

# now we can update the OMB Wiki "Themes" page directly...
sed "/$OMB_WIKI_THEMES_START_MARKER/,/$OMB_WIKI_THEMES_END_MARKER/c\\
$markdown_text" "$OMB_WIKI_THEMES_FILE" > "$OMB_WIKI_THEMES_FILE.part" &&
  mv -f "$OMB_WIKI_THEMES_FILE.part" "$OMB_WIKI_THEMES_FILE"
