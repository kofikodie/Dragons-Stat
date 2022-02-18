FROM node:16-alpine AS build-node
WORKDIR /home/node/app
COPY ./package*.json ./
RUN npm install
COPY . .

#FROM gcr.io/distroless/nodejs:16
#COPY --from=build-node ./home/node/app ./home/node/app
#WORKDIR /home/node/app