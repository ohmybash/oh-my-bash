#! bash oh-my-bash.module
#  ---------------------------------------------------------------------------

alias perm='stat --printf "%a %n \n "'      # perm: Show permission of target in number
alias 000='chmod 000'                       # ---------- (nobody)
alias 640='chmod 640'                       # -rw-r----- (user: rw, group: r)
alias 644='chmod 644'                       # -rw-r--r-- (user: rw, group: r, other: r)
alias 755='chmod 755'                       # -rwxr-xr-x (user: rwx, group: rx, other: rx)
alias 775='chmod 775'                       # -rwxrwxr-x (user: rwx, group: rwx, other: rx)
alias mx='chmod a+x'                        # ---x--x--x (user: --x, group: --x, other: --x)
alias ux='chmod u+x'                        # ---x------ (user: --x, group: -, other: -)
