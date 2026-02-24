FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN echo "deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
	echo "deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
	dbus-x11 \
    ninja-build \
	"^libxcb.*" libx11-dev libx11-xcb-dev libxext-dev libxi-dev libxfixes-dev libglu1-mesa-dev libfreetype6-dev libxrender-dev libfontconfig1-dev libxkbcommon-dev libxkbcommon-x11-dev libdbus-1-dev libasound2-dev libpulse-dev libudev-dev libwayland-dev libatspi2.0-dev libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev zlib1g-dev libssl-dev libpng-dev libjpeg-dev libgbm-dev libdrm-dev libmtdev-dev unixodbc-dev libinput-dev libicu-dev libproxy-dev libdouble-conversion-dev libharfbuzz-dev freetds-dev libcups2-dev libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

ADD gcc-15.1.0-linux-x86_64.tar.xz .
ADD cmake-4.2.3.tar.xz .
ADD qt5.7.1-gcc5.4.0-linux-x86_64.tar.xz .

RUN ls -F /opt

ENV TOOL_ROOT=/opt
ENV PATH=${TOOL_ROOT}/gcc-15.1.0/bin:${TOOL_ROOT}/cmake-4.2.3-linux-x86_64/bin:${TOOL_ROOT}/qt-5.7.1/bin:$PATH
ENV LD_LIBRARY_PATH=${TOOL_ROOT}/gcc-15.1.0/lib64:${TOOL_ROOT}/qt-5.7.1/lib:$LD_LIBRARY_PATH

RUN ln -s ${TOOL_ROOT}/gcc-15.1.0/bin/gcc-15 ${TOOL_ROOT}/gcc-15.1.0/bin/gcc && \
    ln -s ${TOOL_ROOT}/gcc-15.1.0/bin/g++-15 ${TOOL_ROOT}/gcc-15.1.0/bin/g++
	
# 验证
RUN gcc -v && cmake --version && qmake -version

WORKDIR /workspace