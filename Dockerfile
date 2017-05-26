# Version 2 1/2017
# Changes:
# * added volumedata2.sh - extracts  data from a tgz when using empty host volumes
# * added superivsord config for fhem running foreground 
# * supervisor web at port 9001 export
# * added service sshd  to supervisord

#FROM jsurf/rpi-raspbian
FROM resin/armv7hf-debian

MAINTAINER VCR

RUN [ "cross-build-start" ]

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# Install dependencies
# RUN apt-get -y --force-yes install apt-utils
RUN apt-get update \
 && apt-get -y --force-yes upgrade \
 && apt-get -y --force-yes install \
    bash apt-utils wget git nano make gcc g++ apt-transport-https libavahi-compat-libdnssd-dev sudo nodejs \
    etherwake mc vim htop snmp lsof libssl-dev telnet-ssl imagemagick dialog curl usbutils unzip xterm \
 && apt-get clean

# Firmware flash
RUN apt-get -y --force-yes install \
    avrdude gcc-avr avr-libc \
 && apt-get clean

# Install perl packages
RUN apt-get -y --force-yes install \
    libalgorithm-merge-perl libclass-isa-perl libcommon-sense-perl libdpkg-perl liberror-perl \
    libfile-copy-recursive-perl libfile-fcntllock-perl libio-socket-ip-perl libjson-perl \
    libjson-xs-perl libmail-sendmail-perl libsocket-perl libswitch-perl libsys-hostname-long-perl \
    libterm-readkey-perl libterm-readline-perl-perl libsnmp-perl libnet-telnet-perl libmime-lite-perl \
    libxml-simple-perl libdigest-crc-perl libcrypt-cbc-perl libio-socket-timeout-perl libmime-lite-perl \
    libdevice-serialport-perl libwww-perl libcgi-pm-perl libtext-diff-perl \
 && apt-get clean

# dbi, svg, sound
RUN apt-get -y --force-yes install \
    libdbd-pg-perl libdbi-perl libdbd-sqlite3-perl sqlite3 libclass-dbi-mysql-perl \
    mysql-client libdbd-mysql libdbd-mysql-perl libimage-librsvg-perl libav-tools \
 && apt-get clean

# whatsapp Python yowsup
RUN apt-get -y --force-yes install \
    python-soappy python-dateutil python-pip python-dev build-essential libgmp10 \
 && apt-get clean
# whatsapp images
RUN apt-get -y --force-yes install \
    libtiff5-dev libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.5-dev tk8.5-dev python-tk \
 && apt-get clean

# Pyhton stuff
RUN pip install --upgrade pip \
 && pip install python-axolotl --upgrade \
 && pip install pillow --upgrade \
 && pip install yowsup2 --upgrade

# install yowsup-client
WORKDIR /opt
RUN mkdir /opt/yowsup-config \
 && wget -N https://github.com/tgalal/yowsup/archive/master.zip \
 && unzip -o master.zip \
 && rm master.zip

WORKDIR /opt
# install fhem (debian paket)
# wiringPi
RUN git clone git://git.drogon.net/wiringPi \
 && cd wiringPi \
 && git pull origin \
 && ./build

# RCswitch
RUN git clone https://github.com/r10r/rcswitch-pi.git \
 && cd rcswitch-pi \
 && make

RUN wget https://fhem.de/fhem-5.8.deb \
 && dpkg -i fhem-5.8.deb
# RUN rm fhem.deb
RUN echo 'fhem    ALL = NOPASSWD:ALL' >>/etc/sudoers \
 && echo 'attr global pidfilename /var/run/fhem/fhem.pid' >> /opt/fhem/fhem.cfg

RUN apt-get -y --force-yes install supervisor \
 && mkdir -p /var/log/supervisor

# Do some stuff
RUN echo Europe/Berlin > /etc/timezone \
 && dpkg-reconfigure tzdata  \
 && apt-get -y --force-yes install at cron \
 && apt-get clean

# sshd on port 2222 and allow root login / password = fhem!
RUN apt-get -y --force-yes install openssh-server \
 && apt-get clean   \
 && sed -i 's/Port 22/Port 2222/g' /etc/ssh/sshd_config  \
 && sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config \
 && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config \
 && echo "root:fhem!" | chpasswd \
 && /bin/rm /etc/ssh/ssh_host_*
# RUN dpkg-reconfigure openssh-server



# NFS client / autofs
RUN apt-get  -y --force-yes install nfs-common autofs \
 && apt-get clean \
 && apt-get autoremove \
 && echo "/net /etc/auto.net --timeout=60" >> /etc/auto.master

ENV RUNVAR fhem
WORKDIR /root

# SSH / Fhem ports 
EXPOSE 2222 7072 8083 8084 8085 8086 9001

ADD run.sh /root/
ADD runfhem.sh /root/
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir /_cfg  
ADD volumedata2.sh /_cfg/
RUN chmod +x /root/run.sh \
 && chmod +x /_cfg/*.sh \
 && /_cfg/volumedata2.sh create /opt/fhem \
 && /_cfg/volumedata2.sh create /opt/yowsup-config \
 && touch /opt/yowsup-config/empty.txt

ENTRYPOINT ["./run.sh"]
#CMD ["arg1"]

# last add volumes
VOLUME /opt/fhem   /opt/yowsup-config

RUN [ "cross-build-end" ]
# End Dockerfile