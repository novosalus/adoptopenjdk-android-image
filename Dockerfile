FROM novosalus/amc-adopt-open-jdk-base:latest

ARG BUILD_DATE
ARG BUILD_VERSION
ARG VCS_REF

LABEL maintainer="Ritesh Chaudhari <ritesh@novosalus.com>" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.version=$BUILD_VERSION \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0" \
      org.label-schema.vcs-url="https://github.com/novosalus/adoptopenjdk-android-image.git" \
      org.label-schema.name="novosalus/adoptopenjdk-android-image" \
      org.label-schema.vendor="Ritesh Chaudhari (Novosalus)" \
      org.label-schema.description="AdoptOpenJDK android docker image" \
      org.label-schema.url="https://novosalus.com/" \
      org.label-schema.license="" \
      org.opencontainers.image.title="novosalus/adoptopenjdk-android-image" \
      org.opencontainers.image.description="AdoptOpenJDK android docker image" \
      org.opencontainers.image.licenses="" \
      org.opencontainers.image.authors="Ritesh Chaudhari" \
      org.opencontainers.image.vendor="Ritesh Chaudhari" \
      org.opencontainers.image.url="https://hub.docker.com/r/novosalus/adoptopenjdk-android-image" \
      org.opencontainers.image.documentation="" \
      org.opencontainers.image.source="https://github.com/novosalus/adoptopenjdk-android-image.git"

# https://developer.android.com/studio/#downloads
ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip" \
    ANDROID_BUILD_TOOLS_VERSION=29.0.3 \
    ANT_HOME="/usr/share/ant" \
    MAVEN_HOME="/usr/share/maven" \
    GRADLE_HOME="/usr/share/gradle" \
    ANDROID_HOME="/opt/android"

ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin

WORKDIR /opt

RUN apt-get -qq update && \
    apt-get -qq install -y wget curl maven ant gradle

# Installs Android SDK
RUN mkdir android && cd android && \
    wget -O tools.zip ${ANDROID_SDK_URL} && \
    unzip tools.zip && rm tools.zip

ENV PATH=/opt/jdk8u272-b10/bin:${PATH}
ENV JAVA_HOME=/opt/jdk8u272-b10

RUN mkdir /root/.android && touch /root/.android/repositories.cfg && \
    while true; do echo 'y'; sleep 2; done | sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" && \
    while true; do echo 'y'; sleep 2; done | sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-22" "platforms;android-23" "platforms;android-24" "platforms;android-25" "platforms;android-26" "platforms;android-27" && \
    while true; do echo 'y'; sleep 2; done | sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-28" "platforms;android-29" "platforms;android-30"

RUN while true; do echo 'y'; sleep 2; done | sdkmanager --sdk_root=${ANDROID_HOME} "extras;android;m2repository" "extras;google;google_play_services" "extras;google;instantapps" "extras;google;m2repository"
RUN while true; do echo 'y'; sleep 2; done | sdkmanager --sdk_root=${ANDROID_HOME} "add-ons;addon-google_apis-google-22" "add-ons;addon-google_apis-google-23" "add-ons;addon-google_apis-google-24"

RUN chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME && \
    rm -rf /opt/android/licenses && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get -y autoremove && \
    apt-get -y clean

#smoke test after apt-get cleaning
RUN java -version
