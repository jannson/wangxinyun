#!/bin/sh
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export wangxinyun)

disk_path=${wangxinyun_feat_disk_path_selected}
if [ -z "${wangxinyun_feat_disk_path_selected}" ];then
    disk_path="/"
fi
bin_path=/koolshare/bin/wangxinyun/wxinit
config_path=/koolshare/bin/wangxinyun/config/config.yaml
case $ACTION in
start)
    if [ "${wangxinyun_enable}" == "1" ];then 
        killall -9 wxinit
        /koolshare/bin/wangxinyun/wxinit run --config ${config_path} --profilePath /koolshare/configs/wangxinyun --storagePath ${wangxinyun_feat_disk_path_selected}   --programPath ${bin_path}  --enableShareplan &
    fi
    ;;
*)
    if [ "${wangxinyun_enable}" == "1" ];then
        killall -9 wxinit
       /koolshare/bin/wangxinyun/wxinit run --config ${config_path} --profilePath /koolshare/configs/wangxinyun --storagePath ${wangxinyun_feat_disk_path_selected}   --programPath ${bin_path}  --enableShareplan &
    else
        killall -9 wxinit
    fi
    http_response "$1"
    ;;
esac