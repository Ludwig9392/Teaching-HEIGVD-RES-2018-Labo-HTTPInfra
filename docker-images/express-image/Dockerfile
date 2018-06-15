FROM node:8

RUN apt-get update && apt-get install -y nano

COPY src /opt/app

WORDIR /opt/app

RUN npm install --save chance
RUN npm install --save express

CMD ["node", "/opt/app/index.js"]
