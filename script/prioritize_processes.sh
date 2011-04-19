#!/bin/sh
#
# This script manages Linux process priorities and OOM tunables.
#
# It is suitable for running on startup or anytime there are new
# rails processes run.  This script is light-weight enough to run
# minutely from cron, too.
#
# Depends on: renice, pgrep

LOW_PRIORITY='snmpd|ntpd'
HIGH_PRIORITY='ccsd|cman|dlm|fenced|gfs|sshd'
OOM_IMMUNE="${HIGH_PRIORITY}|${LOW_PRIORITY}|init|cron|nginx|syslog|klogd|monit|nrpe"
OOM_SACRIFICIAL='ruby|ruby18|java|rake|memcached'


# Play nice(2)
[ ! -z "${LOW_PRIORITY}" ] && renice  5 `pgrep ${LOW_PRIORITY}` > /dev/null

# These processes are important
[ ! -z "${HIGH_PRIORITY}" ] && renice -5 `pgrep ${HIGH_PRIORITY}` > /dev/null

# Dear OOM_KILLER, please harvest these worthless souls.
if [ ! -z "${OOM_SACRIFICIAL}" ] ; then
  for PID in `pgrep ${OOM_SACRIFICIAL}` ; do
    [ -f /proc/${PID}/oom_adj ] && echo 15 > /proc/${PID}/oom_adj
  done
fi

# The Untouchables
if [ ! -z "${OOM_IMMUNE}" ] ; then
  for PID in `pgrep ${OOM_IMMUNE}` ; do
    [ -f /proc/${PID}/oom_adj ] && echo -17 > /proc/${PID}/oom_adj
  done
fi
