# Dockerfile for building Lisan APK
FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    wget \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set Java environment
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter -b stable --depth 1
ENV PATH=$PATH:/flutter/bin
ENV PATH=$PATH:/flutter/bin/cache/dart-sdk/bin

# Pre-download Flutter dependencies
RUN flutter doctor && flutter precache

# Accept Android licenses (we'll install SDK separately)
RUN yes | flutter doctor --android-licenses || true

# Install Android SDK
RUN mkdir -p /android-sdk/cmdline-tools && \
    cd /android-sdk/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip commandlinetools-linux-11076708_latest.zip && \
    mv cmdline-tools latest && \
    rm commandlinetools-linux-11076708_latest.zip

ENV ANDROID_HOME=/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Install required Android SDK components
RUN sdkmanager --install "platform-tools" "platforms;android-34" "build-tools;34.0.0" "cmdline-tools;latest"

# Verify Flutter setup
RUN flutter config --android-sdk $ANDROID_HOME && \
    flutter doctor

# Set working directory
WORKDIR /app

# Copy project files (will be mounted or copied at build time)
COPY . /app/

# Install dependencies and build APK
RUN flutter pub get && \
    flutter build apk --release

# Output APK location
# /app/build/app/outputs/flutter-apk/app-release.apk
