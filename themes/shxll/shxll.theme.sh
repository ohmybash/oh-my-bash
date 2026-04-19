#! bash oh-my-bash.module

OSH_THEME_GIT_PROMPT_DIRTY="*"
OSH_THEME_GIT_PROMPT_CLEAN=""

__omb_theme_cmd_started=0
__omb_theme_cmd_start=0
__omb_theme_ignore_next_debug=1

_omb_theme_now() {
	if [[ -n ${EPOCHREALTIME-} ]]; then
		printf '%s' "${EPOCHREALTIME//[.,]/}"
	else
		date +%s%3N
	fi
}

_omb_theme_debug_trap() {
	if [[ $__omb_theme_ignore_next_debug -eq 1 ]]; then
		__omb_theme_ignore_next_debug=0
		return
	fi

	if [[ $__omb_theme_cmd_started -eq 0 ]]; then
		__omb_theme_cmd_start=$(_omb_theme_now)
		__omb_theme_cmd_started=1
	fi
}

trap '_omb_theme_debug_trap' DEBUG

function _omb_theme_shxll_way_prompt_scm {
	local CHAR=$(scm_char)
	if [[ $CHAR != "$SCM_NONE_CHAR" ]]; then
		local branch=$(git_current_branch)
		local dirty=$(parse_git_dirty)
		local color

		if [[ -n "$dirty" ]]; then
			color="${_omb_prompt_yellow}"
		else
			color="${_omb_prompt_blue}"
		fi

		printf '%s' " ϟ ${color}${branch}${dirty}${_omb_prompt_normal}"
	fi
}

function _omb_theme_PROMPT_COMMAND {
	local exit_code=$?

	trap - DEBUG

	local time_str=""
	if [[ $__omb_theme_cmd_started -eq 1 ]]; then
		local now elapsed_ms
		now=$(_omb_theme_now)
		elapsed_ms=$(((now - __omb_theme_cmd_start) / 1000))

		if ((elapsed_ms > 500)); then
			time_str="${_omb_theme_gray}${elapsed_ms}ms\[\e[0m\] "
		fi
	fi

	__omb_theme_cmd_started=0

	local ps_username="${_omb_prompt_purple}\u${_omb_prompt_normal}"
	local ps_path="${_omb_prompt_green}\w${_omb_prompt_normal}"
	local ps_user_mark="${_omb_prompt_red}ホ${_omb_prompt_normal}"

	local status=""
	if [[ $exit_code -ne 0 ]]; then
		status="${_omb_prompt_red}(${exit_code})${_omb_prompt_normal} "
	fi

	local python_venv
	_omb_prompt_get_python_venv

	PS1="$ps_username:$python_venv$ps_path$(_omb_theme_shxll_way_prompt_scm) $time_str$status$ps_user_mark "

	__omb_theme_ignore_next_debug=1
	trap '_omb_theme_debug_trap' DEBUG
}

OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:-false}
OMB_PROMPT_VIRTUALENV_FORMAT="${_omb_prompt_olive}(%s)${_omb_prompt_reset_color} "

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
