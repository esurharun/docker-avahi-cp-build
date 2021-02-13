FROM openjdk:8-jdk

MAINTAINER Harun Esur  <harun.esur@sceptive.com>

ENV ANDROID_COMPILE_SDK="27"        \
    ANDROID_BUILD_TOOLS="28.0.3"    \
    ANDROID_SDK_TOOLS_REV="4333796" \
    ANDROID_CMAKE_REV="3.6.4111459" \
    ANDROID_CMAKE_REV_3_10="3.10.2.4988404"

ENV ANDROID_HOME=/opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/platform-tools/:${ANDROID_NDK_HOME}:${ANDROID_HOME}/ndk-bundle:${ANDROID_HOME}/tools/bin/

RUN apt-get update && \
    apt-get install -y file build-essential gcc-multilib g++-multilib libxcursor-dev libxrandr-dev libx11-dev libxext-dev libxinerama-dev libssl-dev libfreetype6 libfreetype6-dev cmake intltool pkg-config libglib2.0-dev libdbus-1-dev libexpat-dev libgdbm-dev  && \
    rm -rf /var/lib/apt/lists/*

RUN    mkdir -p ${ANDROID_HOME} \
    && wget --quiet --output-document=${ANDROID_HOME}/android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS_REV}.zip \
    && unzip -qq ${ANDROID_HOME}/android-sdk.zip -d ${ANDROID_HOME} \
    && rm ${ANDROID_HOME}/android-sdk.zip \
    && mkdir -p $HOME/.android \
    && echo 'count=0' > $HOME/.android/repositories.cfg

RUN    yes | sdkmanager --licenses > /dev/null \ 
    && yes | sdkmanager --update \
    && yes | sdkmanager 'tools' \
    && yes | sdkmanager 'platform-tools' \
    && yes | sdkmanager 'build-tools;'$ANDROID_BUILD_TOOLS \
    && yes | sdkmanager 'platforms;android-'$ANDROID_COMPILE_SDK \
    && yes | sdkmanager 'platforms;android-28' \
    && yes | sdkmanager 'extras;android;m2repository' \
    && yes | sdkmanager 'extras;google;google_play_services' \
    && yes | sdkmanager 'extras;google;m2repository' 

RUN    yes | sdkmanager 'cmake;'$ANDROID_CMAKE_REV \
    && yes | sdkmanager --channel=3 --channel=1 'cmake;'$ANDROID_CMAKE_REV_3_10 \
    && yes | sdkmanager 'ndk-bundle'

RUN    cd /tmp \
    && wget http://0pointer.de/lennart/projects/libdaemon/libdaemon-0.14.tar.gz \
    && tar zxvf libdaemon-0.14.tar.gz \
    && cd libdaemon-0.14 \
    && ./configure \
    && make -j 8 \
    && make install \ 
    && cd / \ 
    && rm -rf /tmp/libdaemon*

RUN    cd /tmp \
    && wget http://avahi.org/download/avahi-0.7.tar.gz \ 
    && tar zxvf avahi-0.7.tar.gz \
    && cd avahi-0.7 \
    && PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/ ./configure --disable-qt3 \
       --disable-qt4 --disable-gtk --disable-gtk3 --with-distro=none --disable-libdaemon \
       --disable-python --disable-mono --enable-compat-libdns_sd --enable-libdaemon \
    && make -j 8 \
    && make install \ 
    && cd / \
    && rm -rf /tmp/avahi*


