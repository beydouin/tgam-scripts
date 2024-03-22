#!/usr/local/bin/bash
# ksubhani@globeandmail.com
# 20240321
# This script was created to enable service checks in mass

now=`date +%s`
commandfile='/usr/local/nagios/var/rw/nagios.cmd'

userinput="$1"

nagiosurl="https://nagios.theglobeandmail.com/cgi/status.cgi?host=all"
hostsrvs="$(wget -q -O - $nagiosurl | grep "Active checks of the service have been disabled" | sed -n "s/.*host=\([^&]*\)&srv=\([^']*\).*/\1 - \2/p")"

runhelp() {
  cat << EOF
usage: $0 [-l|--list] [-c|--change] [-h|--help]
EOF
}

printresult() {
    fmt="%9s: %s \n%9s: %s \n%9s: %s\n\n"
    printf "$fmt" "HOST" "$1" "SERVICE" "$2" "SRV_CHECK" "ENABLED"
}

enablesvc() {
        $(/bin/printf "[%lu] ENABLE_SVC_CHECK;$1;$2\n" $now > $commandfile)
}

check() {
  if [[ ! -z ${hostsrvs} ]]; then
    IFS=$'\n'
    for line in ${hostsrvs} ; do
      host="$(echo $line | awk -F ' - ' '{print $1}')"
      service="$(echo $line | awk -F ' - ' '{sub(/^[^-]+ - /, ""); print}')"
      if [[ $userinput == "-c" ]] || [[ $userinput == "--change" ]]; then
        enablesvc "$host" "$service"
      fi
      printresult "$host" "$service"
    done
  else
    echo "nothing to do... all hosts are already enabled."
  fi
}

main() {
  case $userinput in

    -l | --list)
      check "$userinput"
      ;;

    -c | --change)
      check "$userinput"
      ;;

    -h | --help)
      runhelp
      ;;

    *)
      printf "[I]nvalid input: try using -h flag for help\n"
      ;;
  esac
  shift
}

main