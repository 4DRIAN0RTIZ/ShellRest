FROM alpine:3.20

RUN apk add --no-cache bash socat sqlite jq

WORKDIR /app
COPY . /app

RUN chmod +x /app/*.sh /app/shellrest/*.sh /app/routes/*.sh /app/migrations/*.sh

ENV API_PORT=8082
EXPOSE 8082

CMD ["/bin/bash", "-c", "./migrate.sh && exec ./server.sh"]
