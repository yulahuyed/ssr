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
if [ "${NS_DEVICE}" ]
then
    PARAM_NS_DEVICE="${NS_DEVICE}"
else
    PARAM_NS_DEVICE="eth0"
fi

# supervisor
sed -i 's#nodaemon=false#nodaemon=true#' /etc/supervisord.conf
sed -i 's#\[unix_http_server\]#;\[unix_http_server\]#' /etc/supervisord.conf
sed -i 's#file=/tmp/supervisor.sock#;file=/tmp/supervisor.sock#' /etc/supervisord.conf
sed -i 's#\[rpcinterface:supervisor\]#;\[rpcinterface:supervisor\]#' /etc/supervisord.conf
sed -i 's#supervisor.rpcinterface_f#;supervisor.rpcinterface_f#' /etc/supervisord.conf
sed -i 's#\[supervisorctl\]#;\[supervisorctl\]#' /etc/supervisord.conf
sed -i 's#serverurl=unix:///tmp/superv#;serverurl=unix:///tmp/superv#' /etc/supervisord.conf
echo "
[program:ssr]
command=/usr/bin/python /shadowsocksr/shadowsocks/server.py -p ${PARAM_SSR_PORT} -k ${PARAM_SSR_PASSWORD} -m ${PARAM_SSR_METHOD} -O ${PARAM_SSR_PROTOCOL} -o ${PARAM_SSR_OBFS} --fast-open -qq --user nobody
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0" \
>> /etc/supervisord.conf

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
    echo "
[program:netspeeder]
command=/net-speeder/net_speeder ${PARAM_NS_DEVICE} \"ip\"
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0" \
>> /etc/supervisord.conf
    ip a
    #ping yahoo.com -c 5
    echo "----- ----- ----- ----- -----"
    echo "----- ----- ----- ----- -----"
    echo "----- ----- ----- ----- -----"
fi

# run
/usr/bin/supervisord
