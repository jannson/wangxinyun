#!/bin/sh
eval `dbus export wangxinyun`
source /koolshare/scripts/base.sh

if [ "${wangxinyun_enable}"x = "1"x ];then
    wangxinyun_status=`ps | grep -w wangxinyun | grep -cv grep`
    if [ "${wangxinyun_status}" -lt "1" ];then
        sh /koolshare/scripts/wangxinyun_config.sh
    fi
fi
