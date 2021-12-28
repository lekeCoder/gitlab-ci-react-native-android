#
# GitLab CI react-native-android v0.1
#
# https://hub.docker.com/r/lekedocker/gitlab_ci_react_native_image
# https://github.com/lekecoder/gitlab-ci-react-native-android 
#
FROM ubuntu:20.04
LABEL Description="This image provides a base Android development environment for React Native, and may be used to run tests."
ENV DEBIAN_FRONTEND=noninteractive
# set default build arguments
ARG SDK_VERSION=commandlinetools-linux-6609375_latest.zip
ARG ANDROID_BUILD_VERSION=30
ARG ANDROID_TOOLS_VERSION=30.0.3
ARG BUCK_VERSION=2020.10.21.01
ARG NDK_VERSION=20.1.5948944
ARG NODE_VERSION=14.x
ARG WATCHMAN_VERSION=4.9.0
ARG JAVA_VERION=11
# set default environment variables
ENV GRADLE_HOME /opt/gradle
ENV GRADLE_VERSION 6.9.1
ENV VERSION_SDK_TOOLS "4333796"
ENV ADB_INSTALL_TIMEOUT=10
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_HOME=${ANDROID_HOME}
ENV ANDROID_NDK=${ANDROID_HOME}/ndk/$NDK_VERSION
ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERION}-openjdk-amd64
ENV PATH=${ANDROID_NDK}:${ANDROID_HOME}/cmdline-tools/tools/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:/opt/buck/bin/:${PATH}
# Install system dependencies
RUN apt update -qq && apt install -qq -y --no-install-recommends \
  apt-transport-https \
  curl \
  file \
  gcc \
  git \
  g++ \
  gnupg2 \
  libc++1-10 \
  libgl1 \
  libtcmalloc-minimal4 \
  make \
  openjdk-${JAVA_VERION}-jdk-headless \
  openssh-client \
  python3 \
  python3-distutils \
  rsync \
  ruby \
  ruby-dev \
  tzdata \
  unzip \
  sudo \
  ninja-build \
  zip \
  && gem install bundler -v 2.2.22 \
  && rm -rf /var/lib/apt/lists/*;
# Refresh keys to prevent invalid signature
RUN apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com
# install nodejs and yarn packages from nodesource and yarn apt sources
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && apt-get update -qq \
  && apt-get install -qq -y --no-install-recommends nodejs yarn \
  && rm -rf /var/lib/apt/lists/*
# # download and install buck using debian package
# # https://jitpack.io/com/github/facebook/buck/v2020.10.21.01/buck-v2020.10.21.01-java11.pex
# RUN curl -sS -L https://github.com/facebook/buck/releases/download/v${BUCK_VERSION}/buck.${BUCK_VERSION}_all.deb -o /tmp/buck.deb \
#     && dpkg -i /tmp/buck.deb \
#     && rm /tmp/buck.deb
# Full reference at https://dl.google.com/android/repository/repository2-1.xml

RUN mkdir -p $ANDROID_HOME

# download and unpack android
RUN curl -sS https://dl.google.com/android/repository/${SDK_VERSION} -o /tmp/sdk.zip \
  && mkdir -p ${ANDROID_HOME}/cmdline-tools \
  && unzip -q -d ${ANDROID_HOME}/cmdline-tools /tmp/sdk.zip \
  && rm /tmp/sdk.zip \
  && yes | sdkmanager --licenses \
  && yes | sdkmanager "platform-tools" \
  "emulator" \
  "platforms;android-$ANDROID_BUILD_VERSION" \
  "build-tools;$ANDROID_TOOLS_VERSION" \
  "cmake;3.10.2.4988404" \
  "system-images;android-21;google_apis;armeabi-v7a" \
  "ndk;$NDK_VERSION" \
  && rm -rf ${ANDROID_HOME}/.android

ENV BUILD_PACKAGES git yarn build-essential imagemagick librsvg2-bin ruby ruby-dev wget libcurl4-openssl-dev
RUN echo "Installing Additional Libraries" \
  && rm -rf /var/lib/gems \
  && apt-get update && apt-get install $BUILD_PACKAGES -qqy --no-install-recommends

RUN echo "Installing Fastlane 2.61.0" \
  && gem install fastlane badge -N \
  && gem cleanup

RUN echo "Downloading Gradle" \
  && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"

RUN echo "Installing Gradle" \
  && unzip gradle.zip \
  && rm gradle.zip \
  && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
  && ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle


RUN echo "Install zlib1g-dev for Bundler" \
  && apt-get install -qqy --no-install-recommends \
  zlib1g-dev