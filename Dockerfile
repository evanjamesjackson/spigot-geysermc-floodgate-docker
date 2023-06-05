FROM ubuntu:20.04

# Set timezone so installing tzdata doesn't cause things to hang
ARG TZ
ENV TZ=$TZ
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update and install software
RUN apt-get update
RUN apt-get install --no-install-recommends git openjdk-17-jdk -y

# Build Spigot
ARG MINECRAFT_VERSION
ENV MINECRAFT_VERSION=$MINECRAFT_VERSION
ADD https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar /minecraft/BuildTools.jar
RUN cd /minecraft && java -jar /minecraft/BuildTools.jar --rev $MINECRAFT_VERSION
RUN echo eula=true > /minecraft/eula.txt

# Add GeyserMC and Floodgate plugins
ADD https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot /minecraft/plugins/Geyser-Spigot.jar
ADD https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot /minecraft/plugins/floodgate-spigot.jar

# Copy entrypoint script into the container
COPY ./docker-entrypoint.sh /minecraft/docker-entrypoint.sh

WORKDIR /minecraft

ENTRYPOINT ["./docker-entrypoint.sh"]
