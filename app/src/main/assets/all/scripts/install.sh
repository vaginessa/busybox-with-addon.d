#!/system/bin/sh
# BusyBox installer
# (c) 2015 Anton Skshidlevsky <meefik@gmail.com>, GPLv3

SYSTEM_REMOUNT=$(busybox printf "$INSTALL_DIR" | busybox grep -c "^/system/")

if busybox test "$SYSTEM_REMOUNT" -ne 0
then
    busybox printf "Remounting /system to rw ... "
    busybox mount -o rw,remount /system
    if busybox test $? -eq 0
    then
        busybox printf "done\n"
    else
        busybox printf "fail\n"
        exit 1
    fi
fi

busybox printf "Copying busybox to $INSTALL_DIR ... "
BB_BIN=$(busybox which busybox)
if busybox test -e "$INSTALL_DIR/busybox"
then
    busybox rm "$INSTALL_DIR/busybox"
fi

if busybox test "$SYSTEM_REMOUNT" -ne 0 -a -d /system/addon.d
then
    busybox cp "$ENV_DIR/scripts/addon.d.sh" /system/addon.d/99-busybox.sh
    echo "$INSTALL_DIR" > /system/addon.d/busybox-install-dir
fi

busybox cp $BB_BIN $INSTALL_DIR/busybox
if busybox test $? -eq 0
then
    busybox printf "done\n"
else
    busybox printf "fail\n"
fi

busybox printf "Setting permissions ... "

if busybox test "$SYSTEM_REMOUNT" -ne 0 -a -d /system/addon.d
then
    busybox chown 0:0 /system/addon.d/99-busybox.sh
    busybox chmod 755 /system/addon.d/99-busybox.sh
    busybox chmod 644 /system/addon.d/busybox-install-dir
fi

busybox chown 0:0 $INSTALL_DIR/busybox
busybox chmod 755 $INSTALL_DIR/busybox

if busybox test $? -eq 0
then
    busybox printf "done\n"
else
    busybox printf "fail\n"
fi

if busybox test "$REPLACE_APPLETS" = "true"
then
    busybox printf "Removing old applets ... "
    #busybox --list | busybox xargs -I APPLET busybox rm $INSTALL_DIR/APPLET
    busybox --list | while read f
    do
        if busybox test -e "$INSTALL_DIR/$f" -o -L "$INSTALL_DIR/$f"
        then
            busybox rm "$INSTALL_DIR/$f"
        fi
    done
    if busybox test $? -eq 0
    then
        busybox printf "done\n"
    else
        busybox printf "fail\n"
    fi
fi

if busybox test "$INSTALL_APPLETS" = "true"
then
    busybox printf "Installing new applets ... "
    $INSTALL_DIR/busybox --install -s $INSTALL_DIR
    if busybox test $? -eq 0
    then
        busybox printf "done\n"
    else
        busybox printf "fail\n"
    fi
fi

if busybox test "$SYSTEM_REMOUNT" -ne 0
then
    busybox printf "Remounting /system to ro ... "
    busybox mount -o ro,remount /system
    if busybox test $? -eq 0
    then
        busybox printf "done\n"
    else
        busybox printf "skip\n"
        exit 1
    fi
fi
