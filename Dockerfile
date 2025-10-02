# Stage 1: build
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# copy file cấu hình maven trước để cache dependency
COPY pom.xml .
RUN apt-get update && apt-get install -y maven
RUN mvn dependency:go-offline -B

# copy source code
COPY src src

# build project
RUN mvn clean package -DskipTests

# Stage 2: runtime
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

ENTRYPOINT ["java","-jar","app.jar"]
