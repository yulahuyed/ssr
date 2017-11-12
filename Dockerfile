# shadowsocksr-net-speeder 
FROM ubuntu:14.04.5
MAINTAINER YHIBLOG [shui.azurewebsites.net]
RUN apt-get update && \
    apt-get install -y pwgen wget python python-pip python-m2crypto libnet1-dev libpcap0.8-dev git gcc openssh-server && \
    apt-get clean all

#install libsodium support chacha20
RUN wget --no-check-certificate -O libsodium-1.0.11.tar.gz https://github.com/jedisct1/libsodium/releases/download/1.0.11/libsodium-1.0.11.tar.gz &&\
    tar zxf libsodium-1.0.11.tar.gz && rm -rf libsodium-1.0.11.tar.gz
WORKDIR libsodium-1.0.11
RUN ./configure && make && make install
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf
RUN ldconfig && cd .. && rm -rf libsodium-1.0.11

RUN git clone -b manyuser https://github.com/shadowsocksr-backup/shadowsocksr.git /root/ssr

RUN git clone https://github.com/snooda/net-speeder.git net-speeder
WORKDIR net-speeder
RUN sh build.sh
RUN mv net_speeder /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/net_speeder

EXPOSE 80 443 36000 8080 8989 8888 8090 10000 5000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
