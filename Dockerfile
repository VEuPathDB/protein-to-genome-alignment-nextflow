FROM ubuntu:22.04

MAINTAINER rdemko2332@gmail.com

WORKDIR /usr/bin/

RUN apt-get update --fix-missing

#Installing Software
RUN apt-get install -y \
  perl \
  default-jre \
  default-jdk \
  tabix \
  exonerate \
  libgtk2.0-dev \
  libglib2.0-dev 
  
RUN chmod +x *  

WORKDIR /work
