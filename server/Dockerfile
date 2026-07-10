# Estágio 1: Build (Compilação do código Java)
FROM maven:3.9-eclipse-temurin-17-alpine AS builder
WORKDIR /build

# Copia as dependências e o código fonte do microsserviço específico
COPY pom.xml .
COPY src ./src

# Compila gerando o arquivo .jar (pula os testes para o build ser rápido)
RUN mvn clean package -DskipTests

# Estágio 2: Run (Imagem final super leve)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copia o .jar gerado no estágio anterior
COPY --from=builder /build/target/*.jar app.jar

# Baixa o agente do Elastic APM para monitorar o comportamento interno da JVM
RUN wget -O elastic-apm-agent.jar https://repo1.maven.org/maven2/co/elastic/apm/elastic-apm-agent/1.50.0/elastic-apm-agent-1.50.0.jar

# Inicia a aplicação Java injetando o agente do Elastic APM
ENTRYPOINT ["java", "-javaagent:/app/elastic-apm-agent.jar", "-jar", "app.jar"]