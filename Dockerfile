FROM debian:bookworm-slim

# JDK, Maven, Chromium and its matching driver
RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-17-jdk \
        maven \
        chromium \
        chromium-driver \
        fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

ENV CHROME_BIN=/usr/bin/chromium

WORKDIR /app

# Copy pom first so the dependency layer is cached
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the rest of the project
COPY testng.xml .
COPY webpage ./webpage
COPY src ./src

RUN mvn test-compile -B

CMD ["mvn", "test", "-B"]