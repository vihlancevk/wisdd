FROM eclipse-temurin:21-jdk

COPY ./target/DemoApplication-1.0-SNAPSHOT.jar /demo-application/demo-application.jar

WORKDIR /demo-application

ENTRYPOINT ["java", "-jar", "demo-application.jar"]
