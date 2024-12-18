#!/bin/sh
eval `dbus export wangxinyun_`
source /koolshare/scripts/base.sh
MODULE=wangxinyun
cd /tmp
killall wangxinyun || true
rm -rf /koolshare/init.d/S71wangxinyun.sh
rm -rf /koolshare/bin/wangxinyun
rm -rf /koolshare/res/icon-wangxinyun.png
rm -rf /koolshare/res/wangxinyun_check.html
rm -rf /koolshare/scripts/wangxinyun_check.sh
rm -rf /koolshare/scripts/wangxinyun_config.sh
rm -rf /koolshare/scripts/wangxinyun_status.sh
rm -rf /koolshare/webs/Module_wangxinyun.asp
rm -fr /tmp/wangxinyun*
cru d wangxinyun_check >/dev/null 2>&1
dbus remove __event__onnatstart_wangxinyun
values=`dbus list wangxinyun_ | cut -d "=" -f 1`

for value in $values
do
dbus remove $value
done
rm -f /koolshare/scripts/uninstall_wangxinyun.sh
