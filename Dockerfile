# Builds docker image for subsonic
FROM debian:latest

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Update Debian
RUN apt-get update && apt-get -qy dist-upgrade 
RUN apt-get -q update && apt-get -qy install --no-install-recommends --no-install-suggests wget locales lame flac ffmpeg nano openjdk-7-jre-headless
RUN apt-get clean
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# Set locale to UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Version
ENV SUBSONIC_VERSION 5.2.1

# Install subsonic
RUN wget http://downloads.sourceforge.net/project/subsonic/subsonic/$SUBSONIC_VERSION/subsonic-$SUBSONIC_VERSION.deb -O /tmp/subsonic.deb
RUN dpkg -i /tmp/subsonic.deb && rm /tmp/subsonic.deb

# Set user nobody to uid and gid of unRAID
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody
RUN chown -R nobody:users /var/subsonic
RUN mkdir /subsonic && chown -R nobody:users /subsonic

# Transcoders
#RUN ln /var/subsonic/transcode/ffmpeg /subsonic/transcode \ 
#   ln /var/subsonic/transcode/lame /subsonic/transcode

# Ports
EXPOSE 4050

# Mount volume
VOLUME [/subsonic]

USER nobody 

# Command setting subsonic
CMD /usr/bin/subsonic \
    --home=/subsonic \
    --host=0.0.0.0 \
    --https-port=4050 \
    --max-memory=200 \
    --default-music-folder=/music \
    --default-playlist-folder=/playlist \
    && sleep 5 && tail -f /subsonic/subsonic_sh.log


