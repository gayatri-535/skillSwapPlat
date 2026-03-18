FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

COPY backend/SSA/pom.xml .
RUN mvn -B -q -e -DskipTests dependency:go-offline

COPY backend/SSA/src ./src
RUN mvn -B -DskipTests package

FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
CMD ["java", "-jar", "app.jar"]