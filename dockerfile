# FROM node:24-alpine

# WORKDIR /app

# COPY package.json ./

# RUN npm install

# COPY . .

# # EXPOSE 3000

# CMD ["npm", "start"]

FROM node:20-alpine3.21

WORKDIR /app

RUN apk update && apk upgrade --no-cache

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm","start"]