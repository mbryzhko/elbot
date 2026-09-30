FROM bellsoft/liberica-openjdk-alpine:21
LABEL org.opencontainers.image.authors="Maksym Bryzhko <maxim.bryzhko@gmail.com>"

ARG JAR_FILE

WORKDIR /app
ADD target/${JAR_FILE} /app/elbot.jar

ENTRYPOINT ["java", "-jar", "/app/elbot.jar"]
