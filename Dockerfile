FROM maven:3.9.6-eclipse-temurin-17

# Install Google Chrome (stable)
RUN apt-get update && apt-get install -y --no-install-recommends \
        wget \
        gnupg \
        curl \
        unzip \
        ca-certificates \
        fonts-liberation \
    && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
        | gpg --dearmor -o /usr/share/keyrings/google-linux-signing-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

ENV CHROME_BIN=/usr/bin/google-chrome-stable

WORKDIR /app

# Copy pom first so dependencies are cached
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the rest of the project
COPY testng.xml .
COPY webpage ./webpage
COPY src ./src

RUN mvn test-compile -B

CMD ["mvn", "test", "-B"]
