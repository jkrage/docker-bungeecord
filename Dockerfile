FROM debian:testing
MAINTAINER Joshua Krage <jkrage@guisarme.us>
### Image customization:
###   BUNGEE_OPTS provides options to Spigot runtime (default: <none>)
###   JVM_OPTS sets the JVM options, such as memory size and garbage collection
###     Default:
###       -Xms256M -Xmx256M -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:+AggressiveOpts
###   BUNGEE_BASE is the top-level directory for the rest (default: /minecraft)
###   BUNGEE_JAR directory for newly-built Spigot jar files (default: /minecraft/jar)
###   BUNGEE_SERVER directory for Spigot configuration files (default: /minecraft/server)
###
###   BUNGEE_JAR_FILE sets the server .jar file to run (default: ${BUNGEE_JAR}/BungeeCord.jar)
###   BUNGEE_URL is the download URL for the BungeeCord.jar file
###       (default: http://ci.md-5.net/job/BungeeCord/lastStableBuild/artifact/bootstrap/target/BungeeCord.jar)
###
ENV JVM_OPTS="-Xms256M -Xmx256M -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:+AggressiveOpts"
ENV BUNGEE_OPTS=""
#
ENV BUNGEE_BASE /minecraft
ENV BUNGEE_JAR ${BUNGEE_BASE}/jar
ENV BUNGEE_SERVER ${BUNGEE_BASE}/server
#
ENV BUNGEE_JAR_FILE="${BUNGEE_JAR}/BungeeCord.jar"
ENV BUNGEE_URL="http://ci.md-5.net/job/BungeeCord/lastStableBuild/artifact/bootstrap/target/BungeeCord.jar"

# System setup
RUN apt-get update && apt-get -y install \
        git \
        tar \
        wget \
        openjdk-17-jre-headless \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r minecraft \
    && useradd -m -g minecraft -d ${BUNGEE_BASE} minecraft \
    && mkdir -p ${BUNGEE_JAR} ${BUNGEE_SERVER} \
    && chown minecraft:minecraft ${BUNGEE_JAR} ${BUNGEE_SERVER}

# BungeeCord download and setup
USER minecraft
WORKDIR ${BUNGEE_SERVER}
RUN wget -O ${BUNGEE_JAR_FILE} ${BUNGEE_URL}

# Allow jars and server files to be accessed via volumes
VOLUME ${BUNGEE_JAR}
VOLUME ${BUNGEE_SERVER}

# Expose the standard Minecraft service port and query port
EXPOSE 25565
EXPOSE 25577/udp

# Need to use "sh -c" to interpret the ENV values
CMD [ "/bin/sh", "-c", "/usr/bin/java ${JVM_OPTS} -jar ${BUNGEE_JAR_FILE} ${BUNGEE_OPTS}" ]
