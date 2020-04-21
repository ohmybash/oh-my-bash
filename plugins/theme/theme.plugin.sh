#!/usr/bin/env bash

theme () {
	THEME_TO_SWITCH=$(shuf <(ls -1 ~/.oh-my-bash/themes/ | grep -v THEMES.md) | head -1)
	printf "%s\n" "Switching to >>> ${THEME_TO_SWITCH} <<< theme..."
	sed -i "s/^OSH_THEME=\".*\"$/OSH_THEME=\"${THEME_TO_SWITCH}\"/" ~/.bashrc
	source ~/.bashrc
	bash -i
}
