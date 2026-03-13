# FROM node:24-alpine

# WORKDIR /app

# COPY package.json ./

# RUN npm install

# COPY . .

# # EXPOSE 3000

# CMD ["npm", "start"]

FROM node:18

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm","start"]