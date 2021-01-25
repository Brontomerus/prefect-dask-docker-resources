#!/bin/sh

set -x

# We start by adding extra apt packages, since pip modules may required library
if [ "$EXTRA_APK_PACKAGES" ]; then
    echo "EXTRA_APK_PACKAGES environment variable found.  Installing."
    apk update -y
    apk install -y $EXTRA_APK_PACKAGES
fi

if [ "$EXTRA_PIP_PACKAGES" ]; then
    echo "EXTRA_PIP_PACKAGES environment variable found.  Installing."
    pip install --no-cache $EXTRA_PIP_PACKAGES
fi




# Harden the Image

# remove pip cache, followed by removing pip
pip cache purge
apk del py-pip



# The user the app should run as
APP_USER=app
# The home directory
APP_DIR="/$APP_USER"
# Where persistent data (volume) should be stored
DATA_DIR="$APP_DIR/data"
# Where configuration should be stored
CONF_DIR="$APP_DIR/conf"


# Add custom user and setup home directory
adduser -s /bin/true -u 1000 -D -h $APP_DIR $APP_USER 
mkdir "$DATA_DIR" "$CONF_DIR" 
chown -R "$APP_USER" "$APP_DIR" "$CONF_DIR" 
chmod 700 "$APP_DIR" "$DATA_DIR" "$CONF_DIR"

# Update base system
# hadolint ignore=DL3018
apk add --no-cache ca-certificates

# setting timezone before bullying apk into oblivion
ls /usr/share/zoneinfo
cp /usr/share/zoneinfo/US/Eastern /etc/localtime
echo "US/Eastern" >  /etc/timezone
date

# remove some unneeded apk's - the list will grow as I expirement
apk del tzdata ifconfig watchdog


# Remove existing crontabs, if any.
rm -fr /var/spool/cron
rm -fr /etc/crontabs
rm -fr /etc/periodic

# Remove all but a handful of admin commands.
find /sbin /usr/sbin \
    ! -type d -a ! -name apk -a ! -name ln \
    -delete

# # Remove world-writeable permissions except for /tmp/
# find / -xdev -type d -perm +0002 -exec chmod o-w {} + \
#     find / -xdev -type f -perm +0002 -exec chmod o-w {} + \
#     chmod 777 /tmp/ \
# chown $APP_USER:root /tmp/


# Remove unnecessary accounts, excluding current app user and root
sed -i -r "/^($APP_USER|root|nobody)/!d" /etc/group 
sed -i -r "/^($APP_USER|root|nobody)/!d" /etc/passwd


# Remove interactive login shell for everybody
sed -i -r 's#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd


# Disable password login for everybody
while IFS=: read -r username _; do passwd -l "$username"; done < /etc/passwd || true



# Remove apk configs. -> Commented out because we need apk to install other stuff
#RUN find /bin /etc /lib /sbin /usr \
#  -xdev -type f -regex '.*apk.*' \
#  ! -name apk \
#  -exec rm -fr {} +

# Remove temp shadow,passwd,group
find /bin /etc /lib /sbin /usr -xdev -type f -regex '.*-$' -exec rm -f {} +

# Ensure system dirs are owned by root and not writable by anybody else.
find /bin /etc /lib /sbin /usr -xdev -type d \
  -exec chown root:root {} \; \
  -exec chmod 0755 {} \;

# Remove suid & sgid files
find /bin /etc /lib /sbin /usr -xdev -type f -a \( -perm +4000 -o -perm +2000 \) -delete

# Remove dangerous commands
find /bin /etc /lib /sbin /usr -xdev \( \
  -iname hexdump -o \
  -iname chgrp -o \
  -iname ln -o \
  -iname od -o \
  -iname strings -o \
  -iname su -o \
  -iname sudo \
  \) -delete

# Remove init scripts since we do not use them.
rm -fr /etc/init.d /lib/rc /etc/conf.d /etc/inittab /etc/runlevels /etc/rc.conf /etc/logrotate.d

# Remove kernel tunables
rm -fr /etc/sysctl* /etc/modprobe.d /etc/modules /etc/mdev.conf /etc/acpi

# Remove root home dir
rm -fr /root

# Remove fstab
rm -f /etc/fstab

# Remove any symlinks that we broke during previous steps
find /bin /etc /lib /sbin /usr -xdev -type l -exec test ! -e {} \; -delete

# remove apk jazz
rm -f /sbin/apk
rm -rf /etc/apk
rm -rf /lib/apk
rm -rf /usr/share/apk
rm -rf /var/lib/apk


if [ "$PREFECT_BACKEND" ]; then
    echo "PREFECT_BACKEND environment variable found.  Setting backend."
    prefect backend $PREFECT_BACKEND
else
    echo "No PREFECT_BACKEND environment variable found.  Running server backend."
    prefect backend server
fi


if [ "$PREFECT_AGENT" ] && [ "$PREFECT_CLOUD_TOKEN" ]; then
    echo "PREFECT_AGENT environment variable found.  Starting Agent on PID1."
    prefect agent $PREFECT_AGENT start \
        --name container-agent \
        -t $PREFECT_CLOUD_TOKEN \
        $LABELS
else
    echo "PREFECT_AGENT  environment variable found but no cloud token.  Running additional diagnostics."

    if [ "$PREFECT_AGENT" ]; then
        echo "PREFECT_AGENT environment variable found.  Starting Agent on PID1." 
        prefect agent $PREFECT_AGENT start \
            --name container-agent \
            $LABELS
    else
        echo "No PREFECT_AGENT  environment variable found.  Assuming Local -> starting local"
        prefect backend server
        prefect agent local start \
            --name local-container-agent
    fi

    echo "Environment variables are not set correctly."
fi
