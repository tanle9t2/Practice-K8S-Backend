# ---------- Stage 1: Build the JAR ----------
FROM maven:3.8.8-eclipse-temurin-17 AS build

# Set working directory
WORKDIR /app

# Copy Maven files
COPY pom.xml .
COPY src ./src

# Package the JAR without tests
RUN mvn clean package -DskipTests


# ---------- Stage 2: Run the JAR ----------
FROM eclipse-temurin:17-jdk

# Set working directory
WORKDIR /app

# Copy JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the port your Spring Boot app runs on (default 8080)
EXPOSE 8080

# Run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]
