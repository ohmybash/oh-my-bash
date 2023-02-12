#! bash oh-my-bash.module
#------------------------------------------------------------------------------
# Note on copyright (2022-08-23): The aliases defined in this file seems to
# originally come from a blog post [1].  See also the comments in lib/base.sh.
#
# [1] Nathaniel Landau, "My Mac OSX Bash Profile",
#     https://natelandau.com/my-mac-osx-bash_profile/, 2013-07-02.
#
#------------------------------------------------------------------------------
#  Description:  This file holds many useful BASH aliases and save our lives!
#
#  Sections:
#  1.   File and Folder Management
#  2.   Searching
#  3.   Process Management
#  4.   Networking
#  5.   System Operations & Information
#  6.   Date & Time Management
#  7.   Web Development
#  8.   <your_section>
#
#  X.   Reminders & Notes
#
#------------------------------------------------------------------------------

#   -------------------------------
#   1.  FILE AND FOLDER MANAGEMENT
#   -------------------------------

alias numFiles='echo $(ls -1 | wc -l)'       # numFiles:     Count of non-hidden files in current dir
alias make1mb='truncate -s 1m ./1MB.dat'     # make1mb:      Creates a file of 1mb size (all zeros)
alias make5mb='truncate -s 5m ./5MB.dat'     # make5mb:      Creates a file of 5mb size (all zeros)
alias make10mb='truncate -s 10m ./10MB.dat'  # make10mb:     Creates a file of 10mb size (all zeros)


#   ---------------------------
#   2.  SEARCHING
#   ---------------------------

alias qfind="find . -name "                 # qfind:    Quickly search for file


#   ---------------------------
#   3.  PROCESS MANAGEMENT
#   ---------------------------

#   memHogsTop, memHogsPs:  Find memory hogs
#   -----------------------------------------------------
    alias memHogsTop='top -l 1 -o rsize | head -20'
    alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'

#   cpuHogs:  Find CPU hogs
#   -----------------------------------------------------
    alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'

#   topForever:  Continual 'top' listing (every 10 seconds)
#   -----------------------------------------------------
    alias topForever='top -l 9999999 -s 10 -o cpu'

#   ttop:  Recommended 'top' invocation to minimize resources
#   ------------------------------------------------------------
#       Taken from this macosxhints article
#       http://www.macosxhints.com/article.php?story=20060816123853639
#   ------------------------------------------------------------
    alias ttop="top -R -F -s 10 -o rsize"


#   ---------------------------
#   4.  NETWORKING
#   ---------------------------

alias netCons='lsof -i'                         # netCons:      Show all open TCP/IP sockets
alias lsock='sudo lsof -i -P'                   # lsock:        Display open sockets
alias lsockU='sudo lsof -nP | grep UDP'         # lsockU:       Display only open UDP sockets
alias lsockT='sudo lsof -nP | grep TCP'         # lsockT:       Display only open TCP sockets
alias openPorts='sudo lsof -i | grep LISTEN'    # openPorts:    All listening connections
alias showBlocked='sudo ipfw list'              # showBlocked:  All ipfw rules inc/ blocked IPs
if _omb_util_binary_exists ifconfig; then
  alias ipInfo0='ifconfig getpacket en0'          # ipInfo0:      Get info on connections for en0
  alias ipInfo1='ifconfig getpacket en1'          # ipInfo1:      Get info on connections for en1
fi


#   ---------------------------------------
#   5.  SYSTEMS OPERATIONS & INFORMATION
#   ---------------------------------------

alias mountReadWrite='mount -uw /'    # mountReadWrite:   For use when booted into single-user


#   ---------------------------------------
#   6.  DATE & TIME MANAGEMENT
#   ---------------------------------------

alias bdate="date '+%a, %b %d %Y %T %Z'"
alias cal3='cal -3'
alias da='date "+%Y-%m-%d %A    %T %Z"'
alias daysleft='echo "There are $(($(date +%j -d"Dec 31, $(date +%Y)")-$(date +%j))) left in year $(date +%Y)."'
alias epochtime='date +%s'
alias mytime='date +%H:%M:%S'
alias secconvert='date -d@1234567890'
alias stamp='date "+%Y%m%d%a%H%M"'
alias timestamp='date "+%Y%m%dT%H%M%S"'
alias today='date +"%A, %B %-d, %Y"'
alias weeknum='date +%V'


#   ---------------------------------------
#   8.  WEB DEVELOPMENT
#   ---------------------------------------

alias editHosts='sudo edit /etc/hosts'                  # editHosts:        Edit /etc/hosts file

if _omb_util_binary_exists apachectl; then
  alias apacheEdit='sudo edit /etc/httpd/httpd.conf'      # apacheEdit:       Edit httpd.conf
  alias apacheRestart='sudo apachectl graceful'           # apacheRestart:    Restart Apache
  alias herr='tail /var/log/httpd/error_log'              # herr:             Tails HTTP error logs
  alias apacheLogs="less +F /var/log/apache2/error_log"   # Apachelogs:       Shows apache error logs
fi

#   ---------------------------------------
#   9.  OTHER ALIASES
#   ---------------------------------------

# Aliases by Jacob Hrbek
# Outputs List of Loadable Modules (llm) for current kernel
alias llm="find /lib/modules/$(uname -r) -type f -name '*.ko*'"
# Used for piping to remote pastebin from cmdline to generate a url
_omb_util_binary_exists curl && ix() { curl -n -F 'f:1=<-' http://ix.io ; }
# Used for piping to clipboard
_omb_util_binary_exists xclip && alias xcopy="xclip -se c"
