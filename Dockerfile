FROM node:22-alpine AS build
WORKDIR /app

ARG VITE_BASE_PATH=/react/
ENV VITE_BASE_PATH=${VITE_BASE_PATH}

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginxinc/nginx-unprivileged:alpine

ARG VITE_BASE_PATH=/react/
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf.template

RUN sed -e "s#__BASE_PATH_NOSLASH__#${VITE_BASE_PATH%/}#g" \
        -e "s#__BASE_PATH__#${VITE_BASE_PATH}#g" \
        /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && \
    rm /etc/nginx/conf.d/default.conf.template

EXPOSE 8080
