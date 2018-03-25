#!/bin/bash

# set
PARAM_SSR_PORT=""
if [ "${SSR_PORT}" ]
then
    PARAM_SSR_PORT=${SSR_PORT}
else
    PARAM_SSR_PORT=36000
fi
PARAM_SSR_PASSWORD=""
if [ "${SSR_PASSWORD}" ]
then
    PARAM_SSR_PASSWORD="${SSR_PASSWORD}"
else
    PARAM_SSR_PASSWORD="`head -n 4096 /dev/urandom | tr -cd '[:alnum:]!@$%^&*_' | head -c 16`"
fi
PARAM_SSR_METHOD=""
if [ "${SSR_METHOD}" ]
then
    PARAM_SSR_METHOD="${SSR_METHOD}"
else
    PARAM_SSR_METHOD="chacha20"
fi
PARAM_SSR_PROTOCOL=""
if [ "${SSR_PROTOCOL}" ]
then
    PARAM_SSR_PROTOCOL="${SSR_PROTOCOL}"
else
    PARAM_SSR_PROTOCOL="auth_sha1_v4"
fi
PARAM_SSR_OBFS=""
if [ "${SSR_OBFS}" ]
then
    PARAM_SSR_OBFS="${SSR_OBFS}"
else
    PARAM_SSR_OBFS="http_simple"
fi
PARAM_NS_DEVICE=""
ETH=$(eval "ifconfig | grep 'eth0'| wc -l")
if [ "$ETH"  ==  '1' ]
then
    PARAM_NS_DEVICE="eth0"
else
    PARAM_NS_DEVICE="venet0"
fi

# output
echo "----- ----- ----- ----- -----"
echo "----- ----- ----- ----- -----"
echo "----- ----- ----- ----- -----"
if [ "${SSR_PORT}" ]
then
    echo "ssr port: ${PARAM_SSR_PORT} (created by env)"
else
    echo "ssr port: ${PARAM_SSR_PORT}"
fi
if [ "${SSR_PASSWORD}" ]
then
    echo "ssr password: ${PARAM_SSR_PASSWORD} (created by env)"
else
    echo "ssr password: ${PARAM_SSR_PASSWORD}"
fi
if [ "${SSR_METHOD}" ]
then
    echo "ssr method: ${PARAM_SSR_METHOD} (created by env)"
else
    echo "ssr method: ${PARAM_SSR_METHOD}"
fi
if [ "${SSR_PROTOCOL}" ]
then
    echo "ssr protocol: ${PARAM_SSR_PROTOCOL} (created by env)"
else
    echo "ssr protocol: ${PARAM_SSR_PROTOCOL}"
fi
if [ "${SSR_OBFS}" ]
then
    echo "ssr obfs: ${PARAM_SSR_OBFS} (created by env)"
else
    echo "ssr obfs: ${PARAM_SSR_OBFS}"
fi
echo "----- ----- ----- ----- -----"
echo "----- ----- ----- ----- -----"
echo "----- ----- ----- ----- -----"

# run
if [ "${NS_OFF}" != "true" ]
then
    echo "net-speeder ${PARAM_NS_DEVICE} [enabled]"
    echo "----- ----- ----- ----- -----"
    nohup /usr/local/bin/net_speeder ${PARAM_NS_DEVICE} "ip" >/dev/null 2>&1 &
    ip a
    ping yahoo.com -c 5
    echo "----- ----- ----- ----- -----"
    echo "----- ----- ----- ----- -----"
    echo "----- ----- ----- ----- -----"
fi

if [ "${FRP_CONFIG}" ]
then
    wget -O /frp/frps.ini "${FRP_CONFIG}"
    nohup ./frps -c ./frps.ini > /frp/frp.log 2>&1 &
fi

# run
/usr/bin/python /root/ssr/shadowsocks/server.py -p ${PARAM_SSR_PORT} -k ${PARAM_SSR_PASSWORD} -m ${PARAM_SSR_METHOD} -O ${PARAM_SSR_PROTOCOL} -o ${PARAM_SSR_OBFS}
