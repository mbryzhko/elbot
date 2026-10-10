FROM eclipse-temurin:17.0.13_11-jre-noble
LABEL org.opencontainers.image.authors="Maksym Bryzhko <maxim.bryzhko@gmail.com>"

# Pi4J's bundled libpi4j-pigpio.so links against the system libpigpio.so.1
RUN apt-get update \
    && apt-get install -y --no-install-recommends libpigpio1 \
    && rm -rf /var/lib/apt/lists/*

ARG JAR_FILE

WORKDIR /app
ADD target/${JAR_FILE} /app/elbot.jar

ENTRYPOINT ["java", "-jar", "/app/elbot.jar"]
