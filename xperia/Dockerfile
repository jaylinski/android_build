FROM ubuntu:focal

ARG GIT_USER
ARG GIT_EMAIL

ENV DEBIAN_FRONTEND=noninteractive

# Set directories
ENV WORK_DIR=/root/aosp
ENV PATCH_DIR=/root/patches
ENV KEYS_DIR=/root/keys

# Set Java path
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Set build config
ENV ANDROID_HOME=/opt/android
ENV USE_CCACHE=1
ENV CCACHE_EXEC=/usr/bin/ccache
ENV CCACHE_DIR=/root/ccache
ENV CCACHE_COMPRESS=1
ENV CC="ccache clang"
ENV CXX="ccache clang++"
ENV USER=root
ENV GRADLE_OPTS=-Xmx32768m
ENV SIGN_BUILDS=false
ENV REBUILD_KERNEL=false
ENV PREPARE_SOURCES=true
ENV CLEAN_BUILD=false

# Set device info
ENV DEVICE_FLAVOUR=aosp_f5121-userdebug
ENV PLATFORM=loire
ENV DEVICE=suzu

# Install packages needed for building
RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    bc \
    bison \
    ccache \
    curl \
    flex \
    g++-multilib \
    git \
    gnupg2 \
    gperf \
    kmod \
    liblz4-tool \
    libncurses5 \
    libssl-dev \
    libxml2-utils \
    make \
    openjdk-11-jdk \
    openssh-client \
    python3 \
    rsync \
    software-properties-common \
    unzip \
    wget \
    zlib1g-dev:i386 \
    zip

# Link Python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Download Repo Tool
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
RUN chmod a+x /usr/local/bin/repo

# Create Git config
RUN git config --global user.name "$GIT_USER"
RUN git config --global user.email "$GIT_EMAIL"
RUN git config --global color.ui "auto"
RUN git config --global merge.renameLimit 10000

# Link ccache
RUN ln -s /usr/bin/ccache /usr/local/bin/gcc
RUN ln -s /usr/bin/ccache /usr/local/bin/g++
RUN ln -s /usr/bin/ccache /usr/local/bin/cc
RUN ln -s /usr/bin/ccache /usr/local/bin/c++

# Install tools for flashing image
RUN apt-get install -y \
    android-tools-adb \
    android-tools-fastboot

# Mount points for persistent data
VOLUME "$WORK_DIR"
RUN mkdir -p "$WORK_DIR"
VOLUME "$CCACHE_DIR"
RUN mkdir -p "$CCACHE_DIR"
VOLUME "$KEYS_DIR"
RUN mkdir -p "$KEYS_DIR"
RUN mkdir -p "$PATCH_DIR"

# Add files
COPY ./build-10-4.9.sh /root/build-10-4.9.sh
RUN chmod a+x /root/build-10-4.9.sh

WORKDIR /root

CMD ["bash"]
