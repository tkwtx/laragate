FROM node:14.11.0 as node-build

WORKDIR /var/www/app

COPY . ./

RUN apt-get update && \
	npm install && \
	npm run prod

FROM nginx:1.19.2

WORKDIR /var/www/app

RUN apt-get update

COPY ./docker/nginx/ecs/conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY --from=node-build /var/www/app/public /var/www/app/public/

EXPOSE 80
