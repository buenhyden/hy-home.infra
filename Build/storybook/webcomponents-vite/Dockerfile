#
# Create the installation layer
FROM node:latest

RUN apt-get update && apt-get install -y xdg-utils

WORKDIR /usr/app
ENV PATH /usr/app/node_modules/.bin:$PATH
# Install Dependencies
COPY ./package.json ./package-lock.json ./

RUN npm cache clean --force
RUN npm i --silent

COPY . .

CMD npm run storybook