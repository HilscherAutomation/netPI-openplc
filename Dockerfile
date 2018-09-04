#use latest armv7hf compatible debian version from group resin.io as base image
FROM resin/armv7hf-debian:stretch

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry) 
RUN [ "cross-build-start" ]

#labeling
LABEL maintainer="netpi@hilscher.com" \
      version="V1.0.0" \
      description="Open-PLC - IEC 61131-3 compatible open source PLC"

#version
ENV HILSCHERNETPI_OPENPLC 1.0.0

#copy files
COPY "./init.d/*" /etc/init.d/

#install ssh, give user "root" a password
RUN apt-get update  \
    && apt-get install wget \
    && wget https://archive.raspbian.org/raspbian.public.key -O - | apt-key add - \
    && echo 'deb http://raspbian.raspberrypi.org/raspbian/ stretch main contrib non-free rpi' | tee -a /etc/apt/sources.list \
    && wget -O - http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | sudo apt-key add - \
    && echo 'deb http://archive.raspberrypi.org/debian/ stretch main ui' | tee -a /etc/apt/sources.list.d/raspi.list \
    && apt-get update \
    && apt-get install -y openssh-server \
    && echo 'root:root' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && mkdir /var/run/sshd 

#install tools
RUN apt-get install git \
                    autotools-dev \
                    autoconf \
                    automake \
                    cmake \
                    bison \
                    flex \
                    build-essential \
                    python-dev \
                    python-pip \
                    wget \
                    libtool \
                    pkg-config \
                    binutils 

#install needed python software
RUN python -m pip install --upgrade pip \
    && pip install --upgrade setuptools 
#    && pip install flask \
#    && pip install flask_login 

#get OpenPLC source
RUN git clone https://github.com/thiagoralves/OpenPLC_v3.git

#copy netPI raspberry hardware layer
COPY "./hardware_layer/*" "./OpenPLC_v3/webserver/core/hardware_layers/"

#compile OpenPLC
RUN cd OpenPLC_v3 \
    && ./install.sh rpi

#SSH port and default OpenPLC port
EXPOSE 22 8080

#set the entrypoint
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#set STOPSGINAL
STOPSIGNAL SIGTERM

#stop processing ARM emulation (comment out next line if built on Raspberry)
RUN [ "cross-build-end" ]
