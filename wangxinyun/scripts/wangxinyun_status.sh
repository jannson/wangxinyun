#! /bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval $(dbus export wangxinyun)
wangxinyun_status=`ps | grep -w wxinit | grep -cv grep`
wangxinyun_pid=`pidof wxinit`
wangxinyun_version=`/koolshare/bin/wangxinyun/wxinit version | grep "Build Version" | cut -d ' ' -f 3`
curr_path=`pwd`
jffs_size=`df /jffs | awk 'NR==2 {print $4}'`
if [ "$wangxinyun_status" != "0" ];then
    is_running=1  
else
    is_running=0 
fi
if [ "$is_running" = "1" ]; then 
    qrcode_info=$(curl --unix-socket /koolshare/bin/wangxinyun/.wxsock http://localhost/v1.0/device/get_qrcode_info)
    if [ $? -eq 0 ]; then
        qrcode_content=$(echo "$qrcode_info" | sed -n 's/.*"qrcodeContent":"\([^"]*\)".*/\1/p')
    else
        qrcode_content=""
    fi


    device_status_info=$(curl --unix-socket /koolshare/bin/wangxinyun/.wxsock http://localhost/v1.0/device/get_device_status)
    if [ $? -eq 0 ]; then
        sn=$(echo "$device_status_info" | sed -n 's/.*"sn":"\([^"]*\)".*/\1/p')
    else
        sn=""
    fi

    phone_info=$(curl --unix-socket /koolshare/bin/wangxinyun/.wxsock -X POST http://localhost/v1.0/device/query)
    if [ $? -eq 0 ]; then
        phone=$(echo "$phone_info" | sed -n 's/.*"wxAccount":"\([^"]*\)".*/\1/p')
    else
        phone=""
    fi 
else
    qrcode_content=""
    sn=""
    phone=""
fi

 
RESP="{\\\"version\\\": \\\"$wangxinyun_version\\\",\\\"status\\\": \\\"$is_running\\\",\\\"pid\\\":\\\"$curr_path\\\",\\\"qrcode\\\":\\\"$qrcode_content\\\",\\\"sn\\\":\\\"$sn\\\",\\\"phone\\\":\\\"$phone\\\",\\\"jffs_size\\\":\\\"$jffs_size\\\"}"
http_response "${RESP}"
