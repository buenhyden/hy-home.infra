#
# Create the installation layer
FROM node:latest

WORKDIR /usr/app

# Install Dependencies
COPY ./package.json ./package-lock.json ./

RUN npm i --silent

COPY . .

CMD npm run storybook