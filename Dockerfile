FROM node:lts-alpine

ENV SERVER_PORT=8080
EXPOSE 8080

COPY . /app
WORKDIR /app

RUN npm install node-sass
RUN npm install
RUN npm run build

USER node

CMD ["node","/app/src/server/index.js"]