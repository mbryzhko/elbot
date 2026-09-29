FROM bellsoft/liberica-openjdk-alpine:21

WORKDIR /app
COPY target/elbot-1.0-SNAPSHOT-jar-with-dependencies.jar /app/elbot.jar

ENTRYPOINT ["java", "-jar", "/app/elbot.jar"]
