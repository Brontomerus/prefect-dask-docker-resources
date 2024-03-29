#!/bin/sh

set -x

# We start by adding extra apt packages, since pip modules may required library
if [ "$EXTRA_APT_PACKAGES" ]; then
    echo "EXTRA_APT_PACKAGES environment variable found.  Installing."
    apt-get update -y
    apt-get install -y $EXTRA_APT_PACKAGES
fi

if [ "$EXTRA_PIP_PACKAGES" ]; then
    echo "EXTRA_PIP_PACKAGES environment variable found.  Installing."
    pip install --no-cache $EXTRA_PIP_PACKAGES
fi

# if [ "$INFRASTRUCTURE" ]; then
#   case "$INFRASTRUCTURE" in
#     "aws")
#         export PREFECT__CONTEXT__SECRETS__AWS_CREDENTIALS='{"ACCESS_KEY": "$AWS_ACCESS_KEY_ID", "SECRET_ACCESS_KEY": "$AWS_SECRET_ACCESS_KEY"}'
#         ;;
#     "azure")
#         Statement(s) to be executed if pattern2 matches
#         ;;
#     "google")
#         Statement(s) to be executed if pattern3 matches
#         ;;
#     *)
#       Default condition to be executed
#       ;;
#   esac
# fi

# Harden the Image

# remove pip cache, followed by removing pip
pip cache purge
apt-get remove py-pip



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


# Remove all but a handful of admin commands.
find /sbin /usr/sbin ! -type d \
  -a ! -name nologin \
  -a ! -name dotnet \
  -delete


# # Remove world-writeable permissions except for /tmp/
# find / -xdev -type d -perm +0002 -exec chmod o-w {} + \
#     find / -xdev -type f -perm +0002 -exec chmod o-w {} + \
#     chmod 777 /tmp/ \
# chown $APP_USER:root /tmp/


# Remove interactive login shell for everybody
sed -i -r 's#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd


# Disable password login for everybody
while IFS=: read -r username _; do passwd -l "$username"; done < /etc/passwd || true



# Remove temp shadow,passwd,group
find /bin /etc /lib /sbin /usr -xdev -type f -regex '.*-$' -exec rm -f {} +

# Ensure system dirs are owned by root and not writable by anybody else.
find /bin /etc /lib /sbin /usr -xdev -type d \
  -exec chown root:root {} \; \
  -exec chmod 0755 {} \;

# Remove suid & sgid files
find /bin /etc /lib /sbin /usr -xdev -type f -a \( -perm +4000 -o -perm +2000 \) -delete



# Remove init scripts since we do not use them.
rm -fr /etc/init.d /lib/rc /etc/conf.d /etc/inittab /etc/runlevels /etc/rc.conf /etc/logrotate.d

# Remove kernel tunables
rm -fr /etc/sysctl* /etc/modprobe.d /etc/modules /etc/mdev.conf /etc/acpi

# Remove root home dir
rm -fr /root

# Remove fstab
rm -f /etc/fstab


# Remove unnecessary user accounts.
sed -i -r '/^(appuser|root)/!d' /etc/group
sed -i -r '/^(appuser|root)/!d' /etc/passwd
sed -i -r '/^(appuser|root)/!d' /etc/shadow


# Removing files generated by sed commands above (group-, passwd- and shadow-)
find $sysdirs -xdev -type f -regex '.*-$' -exec rm -f {} +

sysdirs="
  /bin
  /etc
  /lib
  /sbin
  /usr
"

# Remove existing crontabs, if any.
rm -fr /var/spool/cron
rm -fr /etc/crontabs
rm -fr /etc/periodic
  
# Remove init scripts since we do not use them.
rm -fr /etc/init.d
rm -fr /lib/rc
rm -fr /etc/conf.d
rm -fr /etc/inittab
rm -fr /etc/runlevels
rm -fr /etc/rc.conf

# Remove kernel tunables since we do not need them.
rm -fr /etc/sysctl*
rm -fr /etc/modprobe.d
rm -fr /etc/modules

# Remove fstab since we do not need them.
rm -f /etc/fstab

# Remove all but a handful of admin commands.
find /sbin /usr/sbin ! -type d \
  -a ! -name nologin \
  -a ! -name dotnet \
  -delete

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

# Remove all but a handful of executable commands.
find /bin /usr/bin ! -type d \
  -a ! -name cd \
  -a ! -name ls \
  -a ! -name sh \
  -a ! -name bash \
  -a ! -name dir \
  -a ! -name rm \
  -a ! -name dotnet \
  -a ! -name find \
  -a ! -name test \
  -delete

# Remove broken symlinks (because we removed the targets above).
find $sysdirs -xdev -type l -exec test ! -e {} \; -delete

# delete some other crap
rm -rf usr/local/games
# ...





if [ "$PREFECT_AGENT_NAME" ]; then
    echo "PREFECT_AGENT_NAME environment variable found."
else
    echo "No PREFECT_AGENT_NAME environment variable found.  Setting default: container-agent."
    export PREFECT_AGENT_NAME=container-agent
fi

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
        --name $PREFECT_AGENT_NAME \
        --token $PREFECT_CLOUD_TOKEN \
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