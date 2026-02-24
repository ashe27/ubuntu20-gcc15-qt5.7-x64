ARG BASE_IMAGE=ghcr.io/ashe27/ubuntu20-base-x64:latest

FROM ${BASE_IMAGE}

# 默认设为 0（代表不使用国内源，供 GitHub 使用）
ARG USE_CHINA_MIRROR=0

# 根据传入的参数决定是否替换源
RUN echo "当前 USE_CHINA_MIRROR 的值为: ${USE_CHINA_MIRROR}" && \
    if [ "${USE_CHINA_MIRROR}" = "1" ]; then \
        echo "deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list && \
        echo "deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
        echo "deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
        echo "deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list && \
        mkdir -p /root/.pip && \
        echo "[global]" > /root/.pip/pip.conf && \
        echo "index-url = https://mirrors.aliyun.com/pypi/simple/" >> /root/.pip/pip.conf; \
    fi

RUN apt-get update && apt-get install -y --no-install-recommends \
    git-lfs \
    && git lfs install \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# 注意：这些 .tar.xz 文件需要放在该镜像仓库的根目录下
# 且在 GitHub Actions 构建时，checkout 必须开启 lfs: true
ADD gcc-15.1.0-linux-x86_64.tar.xz .
ADD cmake-4.2.3.tar.xz .
ADD qt5.7.1-gcc5.4.0-linux-x86_64.tar.xz .

# 配置环境变量
ENV TOOL_ROOT=/opt
ENV PATH=${TOOL_ROOT}/gcc-15.1.0/bin:${TOOL_ROOT}/cmake-4.2.3-linux-x86_64/bin:${TOOL_ROOT}/qt-5.7.1/bin:$PATH
ENV LD_LIBRARY_PATH=${TOOL_ROOT}/gcc-15.1.0/lib64:${TOOL_ROOT}/qt-5.7.1/lib

# 创建软链接（方便直接使用 gcc/g++）
RUN ln -s ${TOOL_ROOT}/gcc-15.1.0/bin/gcc-15 ${TOOL_ROOT}/gcc-15.1.0/bin/gcc && \
    ln -s ${TOOL_ROOT}/gcc-15.1.0/bin/g++-15 ${TOOL_ROOT}/gcc-15.1.0/bin/g++ && \
	ln -s ${TOOL_ROOT}/gcc-15.1.0/bin/gcov-15 ${TOOL_ROOT}/gcc-15.1.0/bin/gcov
	
# 最终验证（构建时报错即停止）
RUN gcc -v && cmake --version && qmake -version

# 设置最终默认工作路径
WORKDIR /workspace
