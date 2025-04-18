# External Tools
chmod -R 0755 $MODPATH/addon/Volume-Key-Selector/tools

chooseport_legacy() {
    [ "$1" ] && local delay=$1 || local delay=3
    local error=false
    while true; do
        timeout 0 $MODPATH/addon/Volume-Key-Selector/tools/$ARCH32/keycheck
        timeout $delay $MODPATH/addon/Volume-Key-Selector/tools/$ARCH32/keycheck
        local sel=$?
        if [ $sel -eq 42 ]; then
            return 0
        elif [ $sel -eq 41 ]; then
            return 1
        elif $error; then
    		abort "- ❌ No version selected, please restart installation"
        else
            error=true
        fi
    done
}

chooseport() {
    [ "$1" ] && local delay=$1 || local delay=3
    local error=false 
    while true; do
        local count=0
        while true; do
            timeout $delay /system/bin/getevent -lqc 1 2>&1 > $TMPDIR/events &
            sleep 0.5; count=$((count + 1))
            if (`grep -q 'KEY_VOLUMEUP *DOWN' $TMPDIR/events`); then
                return 0
            elif (`grep -q 'KEY_VOLUMEDOWN *DOWN' $TMPDIR/events`); then
                return 1
            fi
            [ $count -gt 30  ] && break
        done
        if $error; then
            export chooseport=chooseport_legacy VKSEL=chooseport_legacy
            chooseport_legacy $delay
            return $?
        else
            error=true
   		 echo " "
            echo "- ❌ Volume key not detected, reflash this module"
            echo " "
        fi
    done
}

VKSEL=chooseport