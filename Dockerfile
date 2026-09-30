FROM eclipse-temurin:17.0.13_11-jre-noble
LABEL org.opencontainers.image.authors="Maksym Bryzhko <maxim.bryzhko@gmail.com>"

ARG JAR_FILE

WORKDIR /app
ADD target/${JAR_FILE} /app/elbot.jar

ENTRYPOINT ["java", "-jar", "/app/elbot.jar"]
