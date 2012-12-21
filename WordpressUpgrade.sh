#!/bin/bash

LIVE_SITE="$1"
BACKUP_DIR="old-site"

##
# Error checking
##

if [ "$LIVE_SITE" == "" ]; then
    echo "error! requires one argument"
    exit
fi

if [ ! -d "$LIVE_SITE" ]; then
    echo "$LIVE_SITE is not a directory!"
    exit
fi

if [ ! -f "$LIVE_SITE/wp-config.php" ]; then
    echo "$LIVE_SITE is not a wordpress installation!"
    exit
fi

if [ ! -d "wordpress" ]; then
    echo "wordpress directory does not exist!"
    exit
fi

if [ -d "$BACKUP_DIR" ]; then
    echo "refusing to upgrade since './$BACKUP_DIR' still exists"
    exit
fi

##
# Real work begins...
##

echo "beginning wordpress upgrade..."

mkdir $BACKUP_DIR

files=`cat diff -Nqr "$LIVE_SITE" wordpress | grep -v wp-content | grep -v favicon | grep -v htaccess | grep -v wp-config.php | grep -v wp-admin | grep -v wp-includes | awk '{ print $4 }' | sed "s/^wordpress\///"`

echo "copying over wp-includes..."
mv "$LIVE_SITE/wp-includes" $BACKUP_DIR/wp-includes && mv wordpress/wp-includes "$LIVE_SITE/wp-includes"
echo "copying over wp-admin..."
mv "$LIVE_SITE/wp-admin" $BACKUP_DIR/wp-admin && mv wordpress/wp-admin "$LIVE_SITE/wp-admin"

for f in $files; do
    subdir=`dirname $f`  # also ${f%/*}

    if [ -f "wordpress/$f" ]; then
        if [ -f "$LIVE_SITE/$f" ]; then
            echo "Upgrading: $f"
            mkdir -p "$BACKUP_DIR/$subdir"
            mv "$LIVE_SITE/$f" "$BACKUP_DIR/$f" && mv "wordpress/$f" "$LIVE_SITE/$f"
        else
            echo "Installing: $f"
            mkdir -p "$LIVE_SITE/$subdir"
            cp "wordpress/$f" "$LIVE_SITE/$f"
        fi
    else
        echo "Removing: $f"
        mkdir -p "$BACKUP_DIR/$subdir"
        mv "$LIVE_SITE/$f" "$BACKUP_DIR/$f"
    fi
done
