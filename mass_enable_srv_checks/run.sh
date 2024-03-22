#!/usr/local/bin/bash
# ksubhani@globeandmail.com

now=`date +%s`
commandfile='/usr/local/nagios/var/rw/nagios.cmd'

hostsrvs="$(wget -q -O - https://nagios.theglobeandmail.com/cgi/status.cgi?host=all | grep "Active checks of the service have been disabled" | sed -n "s/.*host=\([^&]*\)&srv=\([^']*\).*/\1 - \2/p")"

printresult() {
    fmt="%9s: %s \n%9s: %s \n%9s: %s\n\n"
    printf "$fmt" "HOST" "$1" "SERVICE" "$2" "SRV_CHECK" "ENABLED"
}

enablesvc() {
        $(/bin/printf "[%lu] ENABLE_SVC_CHECK;$1;$2\n" $now > $commandfile)
}

main() {
  IFS=$'\n'
  if [[ ! -z ${hostsrvs} ]]; then
    for line in ${hostsrvs} ; do
      host="$(echo $line | awk -F ' - ' '{print $1}')"
      service="$(echo $line | awk -F ' - ' '{sub(/^[^-]+ - /, ""); print}')"
      enablesvc "$host" "$service"
      printresult "$host" "$service"
    done
  else
    echo "All hosts are enabled... nothing to do"
  fi
}

main