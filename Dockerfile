# --- build pigpio ---
FROM eclipse-temurin:17.0.13_11-jre-noble AS pigpio-build
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential wget unzip ca-certificates \
 && wget -q https://github.com/joan2937/pigpio/archive/refs/heads/master.zip \
 && unzip master.zip && cd pigpio-master \
 && make && make install


FROM eclipse-temurin:17.0.13_11-jre-noble
LABEL org.opencontainers.image.authors="Maksym Bryzhko <maxim.bryzhko@gmail.com>"

COPY --from=pigpio-build /usr/local/lib/libpigpio.so* /usr/local/lib/

ARG JAR_FILE

WORKDIR /app
ADD target/${JAR_FILE} /app/elbot.jar

ENTRYPOINT ["java", "-jar", "/app/elbot.jar"]
