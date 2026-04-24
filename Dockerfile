FROM node:latest

ENV DB_PASSWORD="SuperSecret123!"
ENV AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
ENV AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

ADD . /app

WORKDIR /app

RUN npm install

RUN apt-get update && apt-get install -y curl sudo wget

EXPOSE 3000

CMD ["node", "server.js"]
