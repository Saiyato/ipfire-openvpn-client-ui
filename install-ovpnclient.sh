#! /bin/bash

# Locations of settings files
updatedir="/var/ipfire/ovpnclient"
temp_dir="$TMP"

phase2="no"

if [[ ! -d $updatedir ]]; then mkdir -p $updatedir; fi

while getopts ":2hH" opt; do
  case $opt in
  2) phase2="yes";;

  *) echo "Usage: $0 [-2]"; exit 1;;
  esac
done

if [[ $phase2 == "no" ]]; then

# Download the manifest

  wget "https://github.com/Saiyato/ipfire-openvpn-client-ui/raw/master/MANIFEST"

  # Download and move files to their destinations

  echo Downloading files

  if [[ ! -r MANIFEST ]]; then
    echo "Can't find MANIFEST file"
    exit 1
  fi

  while read -r name path owner mode || [[ -n "$name" ]]; do
    echo --
    echo Download $name
    echo $path
    if [[ ! -d $path ]]; then mkdir -p $path; fi
    if [[ $name != "." ]];
    then
      wget "https://github.com/Saiyato/ipfire-openvpn-client-ui/raw/master/$name" -O $path/$name
      chown $owner $path/$name
      chmod $mode $path/$name;
    else
      chown $owner $path
      chmod $mode $path;
    fi
  done < "MANIFEST"

  # Tidy up

  rm MANIFEST

  # Run the second phase of the new install file
  exec $0 -2

  echo Failed to exec $0
fi

# Update language cache

update-lang-cache

# Add link to startup

if [[ ! -e /etc/rc.d/rcsysinit.d/S93ovpnclient ]]; then
  ln -s /etc/init.d/startovpnclient  /etc/rc.d/rcsysinit.d/S93ovpnclient;
fi
