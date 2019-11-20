FROM ubuntu:bionic
MAINTAINER shasha.zhou@hotmail.com

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Add locales after locale-gen as needed
# Upgrade packages on image
# Preparations for sshd
RUN apt-get -q update &&\
    apt-get install -y locales
RUN locale-gen en_US.UTF-8 &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q upgrade -y -o Dpkg::Options::="--force-confnew" --no-install-recommends &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openssh-server &&\
    apt-get -q autoremove &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin &&\
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd &&\
    mkdir -p /var/run/sshd

# Install JDK 8 (latest edition)
RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends software-properties-common &&\
    add-apt-repository -y ppa:openjdk-r/ppa &&\
    apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openjdk-8-jre-headless &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# remove openjdk
RUN apt remove -y openjdk*

# install git, curl, wget
RUN apt-get update
RUN apt-get install -y git curl wget

# Install Oracle JDK 8
RUN wget --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    http://download.oracle.com/otn-pub/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/jdk-8u172-linux-x64.tar.gz  && \
    mkdir /opt/jdk && \
    tar -zxf jdk-8u172-linux-x64.tar.gz -C /opt/jdk && \
    rm jdk-8u172-linux-x64.tar.gz && \
    update-alternatives --install /usr/bin/java  java  /opt/jdk/jdk1.8.0_172/bin/java 100 && \
    update-alternatives --install /usr/bin/javac javac /opt/jdk/jdk1.8.0_172/bin/javac 100 && \
    update-alternatives --install /usr/bin/jar   jar   /opt/jdk/jdk1.8.0_172/bin/jar 100 && \
    ln -s /opt/jdk/jdk1.8.0_172 /opt/jdk/latest

# Install maven 3.3.9
RUN wget http://mirrors.sonic.net/apache/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz && \
    tar -zxf apache-maven-3.5.3-bin.tar.gz && \
    mv apache-maven-3.5.3 /usr/local && \
    rm -f apache-maven-3.5.3-bin.tar.gz && \
    ln -s /usr/local/apache-maven-3.5.3/bin/mvn /usr/bin/mvn && \
    ln -s /usr/local/apache-maven-3.5.3 /usr/local/apache-maven
    
# install docker-compose
RUN curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose
    
# install python3
RUN apt-get install python3.4
COPY /usr/bin/python3 /usr/bin/python

# Set user jenkins to the image
RUN useradd -m -d /home/jenkins -s /bin/sh jenkins &&\
    echo "jenkins:jenkins" | chpasswd

# Standard SSH port
EXPOSE 22

# Default command
CMD ["/usr/sbin/sshd", "-D"]
