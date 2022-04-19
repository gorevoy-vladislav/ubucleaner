#!/bin/bash
#
# Andrew Pennebaker
# 9 Mar 2011
#
# Vladislav Gorevoy
# 2 Jul 2016
#
# From openDesktop
# http://opendesktop.org/content/show.php/Ubucleaner?content=71529

OLDCONF=$(dpkg -l|grep "^rc"|awk '{print $2}')
CURKERNEL=$(uname -r|sed 's/-*[a-z]//g'|sed 's/-386//g')
LINUXPKG="linux-(image|headers|ubuntu-modules|restricted-modules|modules-extra|modules)"
METALINUXPKG="linux-(image|headers|restricted-modules|modules-extra|modules)-(generic|i386|server|common|rt|xen)"
OLDKERNELS=$(dpkg -l|awk '{print $2}'|grep -E $LINUXPKG |grep -vE $METALINUXPKG|grep -v $CURKERNEL)
YELLOW="\033[1;33m"
RED="\033[0;31m"
ENDCOLOR="\033[0m"

if [ $USER != root ]; then
  echo -e $RED"Error: You must be root"
  echo -e $YELLOW"Exiting..."$ENDCOLOR
  exit 0
fi

echo -e $YELLOW"Removing old config files..."$ENDCOLOR

if [ "$1" = "-auto" ]; then
  apt-get purge -y $OLDCONF
else
  apt-get purge $OLDCONF
fi

echo -e $YELLOW"Removing old kernels..."$ENDCOLOR

if [ "$1" = "-auto" ]; then
  apt-get purge -y $OLDKERNELS
else
  apt-get purge $OLDKERNELS
fi

echo -e $YELLOW"Cleaning apt cache..."$ENDCOLOR
apt-get autoclean && apt-get clean

echo -e $YELLOW"Emptying trash..."$ENDCOLOR
rm -rf /home/*/.local/share/Trash/*/** &> /dev/null
rm -rf /root/.local/share/Trash/*/** &> /dev/null

echo -e $YELLOW"Autoremove old packets..."$ENDCOLOR

apt-get autoremove -y

if [ "$1" != "-auto" ]; then

  if which deborphan; then

    echo -e $YELLOW"Cleaning with deborphan..."$ENDCOLOR

    read -r -p "Are you sure you want to clean with Deborphan? [Y/n]" response
    response=${response,,}
    if [[ $response =~ ^(yes|y| ) ]]; then

      deborphan | xargs apt-get -y remove --purge
      deborphan --guess-data | xargs apt-get -y remove --purge

    fi

  else echo -e $RED"Deborphan is not installed! If you want to clean with it, install it with: sudo apt-get install deborphan!"$ENDCOLOR

  fi

fi

echo -e $YELLOW"Script Finished!"$ENDCOLOR
df -h
