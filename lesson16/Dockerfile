FROM openjdk:17 AS build
WORKDIR /opt/webbooks
COPY ./webbooks/pom.xml .
COPY ./webbooks .
RUN ./mvnw clean package -DskipTests

FROM openjdk:17
WORKDIR /opt/webbooks
COPY --from=build /opt/webbooks/target/*.jar /opt/webbooks/app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/opt/webbooks/app.jar"]