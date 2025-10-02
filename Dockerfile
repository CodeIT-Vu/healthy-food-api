# ---------- Stage 1: Build ----------
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Copy Maven wrapper (nếu có) và pom trước để cache dependency
COPY mvnw mvnw.cmd pom.xml ./
COPY .mvn .mvn

# tải dependency để tận dụng cache docker
RUN ./mvnw -q -e -DskipTests dependency:go-offline

# copy source và build
COPY src src
RUN ./mvnw -q -DskipTests clean package

# ---------- Stage 2: Run ----------
FROM eclipse-temurin:21-jre
WORKDIR /app

# Copy jar từ stage build
# Tự động tìm file jar duy nhất trong target
COPY --from=build /app/target/*.jar /app/app.jar

# JVM tối ưu cho RAM nhỏ (Render Free 512MB)
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:InitialRAMPercentage=25 -XX:+UseContainerSupport"
# Kích hoạt profile production nếu cần
ENV SPRING_PROFILES_ACTIVE=prod

# Render cấp biến PORT động -> Spring Boot đọc từ PORT nếu có
# (nhớ thêm cấu hình ở application.yml: server.port=${PORT:8080})
EXPOSE 8080

ENTRYPOINT ["java","-jar","/app/app.jar"]
